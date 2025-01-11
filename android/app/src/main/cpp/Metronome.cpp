#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "json.hpp"
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

void Metronome::addSubdivision(const std::string &key, int option, float subdivisionVolume) {
    subdivisions.emplace(key, Subdivision(option, subdivisionVolume));
    updateClips();
}

void Metronome::removeSubdivision(const std::string &key) {
    subdivisions.erase(key);
    updateClips();
}

void Metronome::setBpm(int bpm) {
    double beatsPerSecond = bpm / (double) 60;
    double beatDurationSeconds = 1 / beatsPerSecond;
    validFrameCount = round( // NOLINT(cppcoreguidelines-narrowing-conversions)
            beatDurationSeconds * sampleRate);
    updateClips();
}

void Metronome::setSample(bool isDownbeat, const std::string &sampleName) {
    if (isDownbeat) downbeatSample = &audioFrames[sampleName];
    else subdivisionSample = &audioFrames[sampleName];
    updateClips();
}

void Metronome::setState(int bpm, const std::string &downbeatSampleName,
                         const std::string &subdivisionSampleName,
                         const std::string &subdivisionsAsJsonString, float updatedVolume) {
    double beatsPerSecond = bpm / (double) 60;
    double beatDurationSeconds = 1 / beatsPerSecond;
    validFrameCount = round( // NOLINT(cppcoreguidelines-narrowing-conversions)
            beatDurationSeconds * sampleRate);

    downbeatSample = &audioFrames[downbeatSampleName];
    subdivisionSample = &audioFrames[subdivisionSampleName];

    subdivisions.clear();
    nlohmann::json subdivisionsAsJson = nlohmann::json::parse(subdivisionsAsJsonString);
    for (auto &keyValuePair: subdivisionsAsJson.items()) {
        int subdivisionOption = keyValuePair.value()["option"].get<int>();
        float subdivisionVolume = keyValuePair.value()["volume"].get<float>();
        subdivisions.emplace(keyValuePair.key(), Subdivision(subdivisionOption, subdivisionVolume));
    }

    this->volume = updatedVolume;

    updateClips();
}

void Metronome::setSubdivisionOption(const std::string &key, int option) {
    subdivisions.at(key).option = option;
    updateClips();
}

void Metronome::setSubdivisionVolume(const std::string &key, float subdivisionVolume) {
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

oboe::DataCallbackResult
Metronome::onAudioReady(oboe::AudioStream *oboeAudioStream, void *audioData, int numFrames) {
    auto *floatData = (float *) audioData;

    std::lock_guard<std::mutex> lock(mutex);

    for (int i = 0; i < numFrames; i++) {
        nextFrame = nextFrame % validFrameCount;

        floatData[i] = 0;

        for (Clip &clip: clips) {
            if (clip.isActive && !clip.isPlaying && clip.startFrame == nextFrame) {
                clip.isPlaying = true;
            }

            if (clip.isPlaying) {
                if (clip.nextFrame < clip.sample.length) {
                    floatData[i] += clip.sample.data[clip.nextFrame] * clip.volume;
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
    for (const auto &keyValuePair: subdivisions) {
        for (float location: keyValuePair.second.getLocations()) {
            if (keyValuePair.second.volume >=
                (subdivisionLocationVolumes.find(location) == subdivisionLocationVolumes.end() ? 0
                                                                                               : subdivisionLocationVolumes[location])) {
                subdivisionLocationVolumes[location] = keyValuePair.second.volume;
            }
        }
    }

    std::vector<std::tuple<int, float>> subdivisionClipData;
    subdivisionClipData.reserve(subdivisions.size());
    for (const auto &keyValuePair: subdivisionLocationVolumes) {
        float exactLocation = validFrameCount * // NOLINT(cppcoreguidelines-narrowing-conversions)
                              keyValuePair.first;
        subdivisionClipData.emplace_back(std::round(exactLocation / sizeof(float)) * sizeof(float),
                                         keyValuePair.second);
    }

    Clip downbeatClip = Clip(*downbeatSample, 0, volume);

    std::vector<Clip> subdivisionClips;
    subdivisionClips.reserve(subdivisionClipData.size());
    for (const auto &keyValuePair: subdivisionClipData) {
        subdivisionClips.emplace_back(*subdivisionSample, std::get<0>(keyValuePair),
                                      std::get<1>(keyValuePair));
    }

    std::lock_guard<std::mutex> lock(mutex);

    std::vector<Clip> updatedClips;
    for (Clip clip: clips) {
        if (clip.isPlaying) {
            clip.isActive = false;
            updatedClips.emplace_back(clip);
        }
    }

    updatedClips.emplace_back(downbeatClip);
    updatedClips.insert(updatedClips.end(), subdivisionClips.begin(), subdivisionClips.end());

    clips = updatedClips;
}
