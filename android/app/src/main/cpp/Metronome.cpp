#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "Subdivision.h"
#include "Metronome.h"

Metronome::Metronome() {
    initializeBuffer();
    setupAudioStream();
    setupCallbacks();
}

void Metronome::addSubdivision(std::string key, int option, float subdivisionVolume) {
    subdivisions.emplace(key, Subdivision(option, subdivisionVolume));
    writeBuffer();
}

void Metronome::removeSubdivision(std::string key) {
    subdivisions.erase(key);
    writeBuffer();
}

void Metronome::setBpm(int bpm) {
    float beatsPerSecond = bpm / 60;
    float beatDurationSeconds = 1 / beatsPerSecond;
    buffer.validFrames = round(beatDurationSeconds * sampleRate);
    writeBuffer();
}

void Metronome::setSubdivisionOption(std::string key, int option) {
    subdivisions.at(key).option = option;
    writeBuffer();
}

void Metronome::setSubdivisionVolume(std::string key, float subdivisionVolume) {
    subdivisions.at(key).volume = subdivisionVolume;
    writeBuffer();
}

void Metronome::setVolume(float volume) {
    this->volume = volume;
    writeBuffer();
}

void Metronome::startPlayback() {
    audioStream->start();
}

void Metronome::stopPlayback() {
    audioStream->stop();
}

void Metronome::initializeBuffer() {
    float beatsPerSecond = 120 / 60;
    float beatDurationSeconds = 1 / beatsPerSecond;
    buffer.validFrames = round(beatDurationSeconds * sampleRate);
    writeBuffer();
}

oboe::DataCallbackResult Metronome::onAudioReady(oboe::AudioStream *oboeAudioStream, void *audioData, int numFrames) {
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
    buffer.callbacks.emplace_back([](std::vector<float>& buffer) {
        // TODO: Write downbeat
    });
    buffer.callbacks.emplace_back([](std::vector<float>& buffer) {
        // TODO: Write subdivisions
    });
}

void Metronome::writeBuffer() {
    std::vector<float> updatedFrames(buffer.validFrames, 0);

    for (auto& callback : buffer.callbacks) {
        callback(updatedFrames);
    }

    std::copy(updatedFrames.begin(), updatedFrames.begin() + buffer.validFrames, buffer.frames.begin());
}
