#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "Metronome.h"
#include "Subdivision.h"

Metronome::Metronome() {
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

void Metronome::addSubdivision(const std::string& key, int option, float subdivisionVolume) {
    subdivisions.emplace(key, Subdivision(option, subdivisionVolume));
    updateClips();
}

void Metronome::removeSubdivision(const std::string& key) {
    subdivisions.erase(key);
    updateClips();
}

void Metronome::setBpm(int bpm) {
    double beatsPerSecond = bpm / (double) 60;
    double beatDurationSeconds = 1 / beatsPerSecond;
    validFrameCount = round(beatDurationSeconds * sampleRate); // NOLINT(cppcoreguidelines-narrowing-conversions)
    updateClips();
}

void Metronome::setSubdivisionOption(const std::string& key, int option) {
    subdivisions.at(key).option = option;
    updateClips();
}

void Metronome::setSubdivisionVolume(const std::string& key, float subdivisionVolume) {
    subdivisions.at(key).volume = subdivisionVolume;
    updateClips();
}

void Metronome::setVolume(float updatedVolume) {
    this->volume = updatedVolume;
    updateClips();
}

void Metronome::startPlayback() {
    audioStream->start();
}

void Metronome::stopPlayback() {
    nextFrame = 0;

    audioStream->stop();
}

oboe::DataCallbackResult Metronome::onAudioReady(oboe::AudioStream* oboeAudioStream, void* audioData, int numFrames) {
    auto* floatData = (float*) audioData;

    std::lock_guard<std::mutex> lock(mutex);

    for (int i = 0; i < numFrames; i++) {
        nextFrame = nextFrame % validFrameCount;

        floatData[i] = 0;

        for (Clip &clip : clips) {
            if (clip.isActive && !clip.isPlaying && clip.startFrame == nextFrame) {
                clip.isPlaying = true;
            }

            if (clip.isPlaying) {
                if (clip.nextFrame < clip.sample.length) {
                    floatData[i] += clip.sample.data[clip.nextFrame] * volume;
                    clip.nextFrame++;
                } else {
                    clip.isPlaying = false;
                    clip.nextFrame = 0;
                }
            }
        }

        nextFrame++;
    }

    return oboe::DataCallbackResult::Continue;
}

void Metronome::updateClips() {
    std::unordered_map<float, float> subdivisionLocationVolumes;
    subdivisionLocationVolumes.reserve(subdivisions.size());
    for (const auto& keyValuePair : subdivisions) {
        for (float location : keyValuePair.second.getLocations()) {
            if (keyValuePair.second.volume >= (subdivisionLocationVolumes.find(location) == subdivisionLocationVolumes.end() ? 0 : subdivisionLocationVolumes[location])) {
                subdivisionLocationVolumes[location] = keyValuePair.second.volume;
            }
        }
    }

    std::vector<std::tuple<int, float>> subdivisionClipData;
    subdivisionClipData.reserve(subdivisions.size());
    for (const auto& keyValuePair : subdivisionLocationVolumes) {
        float exactLocation = validFrameCount * keyValuePair.first; // NOLINT(cppcoreguidelines-narrowing-conversions)
        subdivisionClipData.emplace_back(std::round(exactLocation / sizeof(float)) * sizeof(float), keyValuePair.second);
    }

    Clip downbeatClip = Clip(audioFrames["downbeat"], 0, volume);

    std::vector<Clip> subdivisionClips;
    subdivisionClips.reserve(subdivisionClipData.size());
    for (const auto& keyValuePair : subdivisionClipData) {
        subdivisionClips.emplace_back(audioFrames["sample"], std::get<0>(keyValuePair), std::get<1>(keyValuePair));
    }

    std::lock_guard<std::mutex> lock(mutex);

    std::vector<Clip> updatedClips;
    for (Clip clip : clips) {
        if (clip.isPlaying) {
            clip.isActive = false;
            updatedClips.emplace_back(clip);
        }
    }

    updatedClips.emplace_back(downbeatClip);
    updatedClips.insert(updatedClips.end(), subdivisionClips.begin(), subdivisionClips.end());

    clips = updatedClips;
}
