#ifndef ANDROID_METRONOME_H
#define ANDROID_METRONOME_H


#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "Subdivision.h"
#include "MetronomeBuffer.h"

class Metronome : public oboe::AudioStreamDataCallback {
public:
    Metronome();
    ~Metronome() override = default;

    void addSubdivision(std::string key, int32_t option, float volume);
    void removeSubdivision(std::string key);
    void setBpm(int32_t bpm);
    void setSubdivisionOption(std::string key, int32_t option);
    void setSubdivisionVolume(std::string key, float volume);
    void setVolume(float volume);
    void startPlayback();
    void stopPlayback();

private:
    int32_t sampleRate = 44100;

    std::shared_ptr<oboe::AudioStream> audioStream;
    MetronomeBuffer buffer = MetronomeBuffer(sampleRate * 60);
    std::unordered_map<std::string, Subdivision> subdivisions;
    float volume{};

    void initializeBuffer();
    oboe::DataCallbackResult onAudioReady(oboe::AudioStream *oboeAudioStream, void *audioData, int32_t numFrames) override;
    void setupAudioStream();
    void setupCallbacks();
    void writeBuffer();
};


#endif //ANDROID_METRONOME_H
