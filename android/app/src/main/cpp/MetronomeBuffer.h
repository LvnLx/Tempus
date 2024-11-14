#ifndef ANDROID_METRONOMEBUFFER_H
#define ANDROID_METRONOMEBUFFER_H


#include <cstdint>
#include <vector>

class MetronomeBuffer {
public:
    explicit MetronomeBuffer(int32_t maxFrames);
    virtual ~MetronomeBuffer() = default;

    std::vector<std::function<void(std::vector<float>&)>> callbacks;
    std::vector<float> frames;
    int32_t validFrames{};

private:
    int32_t maxFrames;
};


#endif //ANDROID_METRONOMEBUFFER_H
