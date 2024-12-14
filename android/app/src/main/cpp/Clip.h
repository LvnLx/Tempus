#ifndef ANDROID_CLIP_H
#define ANDROID_CLIP_H


#include "Sample.h"

class Clip {
public:
    Clip(const Sample& sample, int startFrame, float volume);
    virtual ~Clip() = default;

    bool isPlaying = false;
    bool isActive = true;
    int nextFrame = 0;
    Sample sample;
    int startFrame;
    float volume;
};


#endif //ANDROID_CLIP_H
