#include <cmath>
#include <vector>

#include "Subdivision.h"

Subdivision::Subdivision(int option, float volume) : option(option), volume(volume) {}

std::vector<float> Subdivision::getLocations() const {
    std::vector<float> startFrames(option - 1, 1);

    for (int i = 0; i < startFrames.size(); i++) {
        float fullLocation =
                startFrames[i] / option * // NOLINT(cppcoreguidelines-narrowing-conversions)
                (i + 1); // NOLINT(cppcoreguidelines-narrowing-conversions)
        startFrames[i] =
                std::round(fullLocation *// NOLINT(cppcoreguidelines-narrowing-conversions)
                           std::pow(10, locationPrecision)) /
                std::pow(10, locationPrecision);
    }

    return startFrames;
}
