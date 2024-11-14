#include "MetronomeBuffer.h"

MetronomeBuffer::MetronomeBuffer(int maxFrames) {
    this->maxFrames = maxFrames;
    frames.reserve(maxFrames);
}