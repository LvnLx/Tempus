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

    std::unordered_map<std::string, std::vector<float>> audioFrames;

    void addSubdivision(const std::string& key, int option, float volume);
    void removeSubdivision(const std::string& key);
    void setBpm(int bpm);
    void setSubdivisionOption(const std::string& key, int option);
    void setSubdivisionVolume(const std::string& key, float volume);
    void setVolume(float volume);
    void startPlayback();
    void stopPlayback();

private:
    int sampleRate = 44100;

    std::shared_ptr<oboe::AudioStream> audioStream;
    MetronomeBuffer buffer = MetronomeBuffer(sampleRate * 60);
    int nextFrameToCopy = 0;
    std::unordered_map<std::string, Subdivision> subdivisions;
    float volume{};

    void initializeBuffer();
    oboe::DataCallbackResult onAudioReady(oboe::AudioStream* oboeAudioStream, void* audioData, int numFrames) override;
    void setupAudioStream();
    void setupCallbacks();
    void writeBuffer();
};


#endif //ANDROID_METRONOME_H
