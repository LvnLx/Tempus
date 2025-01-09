#ifndef ANDROID_SAMPLE_H
#define ANDROID_SAMPLE_H


#include "vector"

class Sample {
public:
    Sample() = default;

    Sample(const std::vector<float> &data, int length);

    virtual ~Sample() = default;

    std::vector<float> data;
    int length{};
};


#endif //ANDROID_SAMPLE_H
