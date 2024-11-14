#ifndef ANDROID_METRONOMEBUFFER_H
#define ANDROID_METRONOMEBUFFER_H


#include <vector>

class MetronomeBuffer {
public:
    explicit MetronomeBuffer(int maxFrames);
    virtual ~MetronomeBuffer() = default;

    std::vector<std::function<void(std::vector<float>&)>> callbacks;
    std::vector<float> frames;
    int validFrames{};
};


#endif //ANDROID_METRONOMEBUFFER_H
