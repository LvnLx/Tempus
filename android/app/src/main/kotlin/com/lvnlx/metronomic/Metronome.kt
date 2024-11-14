package com.lvnlx.metronomic

class Metronome {
    companion object {
        init {
            System.loadLibrary("metronomic")
        }
    }

    external fun addSubdivision(key: String, option: Int, volume: Float)
    external fun removeSubdivision(key: String)
    external fun setBpm(bpm: Int)
    external fun setSubdivisionOption(key: String, option: Int)
    external fun setSubdivisionVolume(key: String, volume: Float)
    external fun setVolume(volume: Float)
    external fun startPlayback()
    external fun stopPlayback()
}
