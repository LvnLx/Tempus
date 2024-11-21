#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "Metronome.h"
#include "Subdivision.h"

Metronome::Metronome() {
    initializeBuffer();
    setupAudioStream();
    setupCallbacks();
}

void Metronome::addSubdivision(const std::string& key, int option, float subdivisionVolume) {
    subdivisions.emplace(key, Subdivision(option, subdivisionVolume));
    writeBuffer();
}

void Metronome::removeSubdivision(const std::string& key) {
    subdivisions.erase(key);
    writeBuffer();
}

void Metronome::setBpm(int bpm) {
    double beatsPerSecond = bpm / (double) 60;
    double beatDurationSeconds = 1 / beatsPerSecond;
    buffer.validFrames = round(beatDurationSeconds * sampleRate); // NOLINT(cppcoreguidelines-narrowing-conversions)
    writeBuffer();
}

void Metronome::setSubdivisionOption(const std::string& key, int option) {
    subdivisions.at(key).option = option;
    writeBuffer();
}

void Metronome::setSubdivisionVolume(const std::string& key, float subdivisionVolume) {
    subdivisions.at(key).volume = subdivisionVolume;
    writeBuffer();
}

void Metronome::setVolume(float updatedVolume) {
    this->volume = updatedVolume;
    writeBuffer();
}

void Metronome::startPlayback() {
    audioStream->start();
}

void Metronome::stopPlayback() {
    audioStream->stop();
}

void Metronome::initializeBuffer() {
    double beatsPerSecond = 120 / (double) 60;
    double beatDurationSeconds = 1 / beatsPerSecond;
    buffer.validFrames = round(beatDurationSeconds * sampleRate); // NOLINT(cppcoreguidelines-narrowing-conversions)
    writeBuffer();
}

oboe::DataCallbackResult Metronome::onAudioReady(oboe::AudioStream* oboeAudioStream, void* audioData, int numFrames) {
    auto* floatData = (float*) audioData;
    int offset = nextFrameToCopy;
    for (int i = 0; i < numFrames; i++) {
        if (nextFrameToCopy + i > buffer.validFrames) {
            nextFrameToCopy = 0;
        }

        floatData[i] = buffer.frames[offset + i];

        nextFrameToCopy++;
    }

    return oboe::DataCallbackResult::Continue;
}

void Metronome::setupAudioStream() {
    oboe::AudioStreamBuilder builder;
    builder.setChannelConversionAllowed(true)
        ->setChannelCount(1)
        ->setDataCallback(this)
        ->setFormatConversionAllowed(true)
        ->setSampleRate(sampleRate)
        ->setSampleRateConversionQuality(oboe::SampleRateConversionQuality::Best)
        ->setFormat(oboe::AudioFormat::Float)
        ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
        ->openStream(audioStream);
}

void Metronome::setupCallbacks() {
    buffer.callbacks.emplace_back([this](std::vector<float>& metronomeBufferFrames) {
        std::vector<float> downbeatAudioFrames = audioFrames["downbeat"];
        for (int i = 0; i < downbeatAudioFrames.size(); i ++) {
            metronomeBufferFrames[i] += downbeatAudioFrames[i] * volume;
        }
    });

    buffer.callbacks.emplace_back([this](std::vector<float>& metronomeBufferFrames) {
        std::vector<Subdivision> subdivisionsValues;
        subdivisionsValues.reserve(subdivisions.size());

        for (const auto& keyValuePair : subdivisions) {
            subdivisionsValues.push_back(keyValuePair.second);
        }

        std::unordered_map<float, float> locationVolumes;
        for (const auto& subdivision : subdivisionsValues) {
            for (auto location : subdivision.getLocations()) {
                auto locationVolume = locationVolumes.find(location);
                if (locationVolume != locationVolumes.end() && locationVolume->second > subdivision.volume) {
                    continue;
                } else {
                    locationVolumes[location] = subdivision.volume;
                }
            }
        }

        std::vector<float> subdivisionAudioFrames = audioFrames["subdivision"];
        for (auto keyValuePair : locationVolumes) {
            double exactLocation = (double) metronomeBufferFrames.size() * keyValuePair.first;
            int startFrame = std::round(exactLocation / sizeof(float)) * sizeof(float); // NOLINT(cppcoreguidelines-narrowing-conversions)

            for (int i = 0; i < subdivisionAudioFrames.size(); i++) {
                if (startFrame + i < metronomeBufferFrames.size())
                    metronomeBufferFrames[startFrame + i] += subdivisionAudioFrames[i] * keyValuePair.second * volume;
            }
        }
    });
}

void Metronome::writeBuffer() {
    std::vector<float> updatedFrames(buffer.validFrames, 0);

    for (auto& callback : buffer.callbacks) {
        callback(updatedFrames);
    }

    std::copy(updatedFrames.begin(), updatedFrames.begin() + buffer.validFrames, buffer.frames.begin());
}
