#ifndef ANDROID_METRONOME_H
#define ANDROID_METRONOME_H


#include <oboe/Oboe.h>
#include <unordered_map>
#include <vector>

#include "Subdivision.h"
#include "Sample.h"
#include "Clip.h"

class Metronome : public oboe::AudioStreamDataCallback {
public:
    Metronome();

    ~Metronome() override = default;

    std::unordered_map<std::string, Sample> audioFrames;

    void addSubdivision(const std::string &key, int option, float volume);

    void removeSubdivision(const std::string &key);

    void setBpm(int bpm);

    void setSample(bool isDownbeat, const std::string &sampleName);

    void setState(int bpm, const std::string &downbeatSampleName,
                  const std::string &subdivisionSampleName,
                  float volume);

    void setSubdivisionOption(const std::string &key, int option);

    void setSubdivisionVolume(const std::string &key, float volume);

    void setVolume(float volume);

    void startPlayback();

    void stopPlayback();

private:
    int sampleRate = 44100;

    std::shared_ptr<oboe::AudioStream> audioStream;
    std::vector<Clip> clips;
    Sample *downbeatSample{};
    std::mutex mutex;
    int nextFrame = 0;
    std::unordered_map<std::string, Subdivision> subdivisions;
    Sample *subdivisionSample{};
    int validFrameCount{};
    float volume{};

    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *oboeAudioStream, void *audioData, int numFrames) override;

    void updateClips();
};


#endif //ANDROID_METRONOME_H
