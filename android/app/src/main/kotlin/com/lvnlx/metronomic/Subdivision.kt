package com.lvnlx.metronomic

import kotlin.math.pow
import kotlin.math.roundToInt

class Subdivision(var option: Int, var volume: Float) {
    val locationPrecision: Double = 2.0

    override fun toString(): String {
        return "Subdivision(option: ${option}, volume ${volume})"
    }

    fun getLocations(): Array<Float> {
        var startFrames: Array<Float> = Array(option - 1) { 1f }

        for ((index, startFrame) in startFrames.withIndex()) {
            val fullLocation: Float = startFrame / option * (index + 1)
            startFrames[index] = (fullLocation * 10.0.pow(locationPrecision)).roundToInt() / 10.0.pow(locationPrecision).toFloat()
        }

        return startFrames
    }
}