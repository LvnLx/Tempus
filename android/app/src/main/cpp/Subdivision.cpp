#include <cmath>
#include <vector>

#include "Subdivision.h"

Subdivision::Subdivision(int option, float volume) : option(option), volume(volume) {}

std::vector<float> Subdivision::getLocations() const {
    std::vector<float> startFrames(option - 1, 1);

    for (int i = 0; i < startFrames.size(); i++) {
        float fullLocation = startFrames[i] / option * (i + 1); // NOLINT(cppcoreguidelines-narrowing-conversions)
        startFrames[i] = std::round(fullLocation * std::pow(10, locationPrecision)) / std::pow(10, locationPrecision); // NOLINT(cppcoreguidelines-narrowing-conversions)
    }

    return startFrames;
};
