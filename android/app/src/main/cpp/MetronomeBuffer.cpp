#include "MetronomeBuffer.h"

MetronomeBuffer::MetronomeBuffer(int32_t maxFrames) {
    this->maxFrames = maxFrames;
    frames.reserve(maxFrames);
}