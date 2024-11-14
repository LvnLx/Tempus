#include <cmath>
#include <cstdint>
#include <vector>

#include "Subdivision.h"

Subdivision::Subdivision(int32_t option, float volume) : option(option), volume(volume) {}

std::vector<float> Subdivision::getLocations() const {
    std::vector<float> startFrames(option - 1, 1);

    for (uint8_t i = 0; i < startFrames.size(); i++) {
        float fullLocation = startFrames[i] / option * (i + 1);
        startFrames[i] = std::round(fullLocation * std::pow(10, locationPrecision)) / std::pow(10, locationPrecision);
    }

    return startFrames;
};
