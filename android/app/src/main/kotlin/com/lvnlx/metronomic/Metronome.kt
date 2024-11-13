package com.lvnlx.metronomic

class Metronome {
    var subdivisions: MutableMap<String, Subdivision> = mutableMapOf()
    var volume: Float? = null

    init {
        initializeBuffer()
    }

    fun addSubdivision(key: String, option: Int, volume: Float) {
        subdivisions[key] = Subdivision(option, volume)
        writeBuffer()
    }

    fun removeSubdivision(key: String) {
        subdivisions.remove(key)
        writeBuffer()
    }

    fun setBpm(bpm: Int) {
        val bps: Double = bpm.toDouble() / 60
        val beatDurationSeconds: Double = 1 / bps
        // TODO: Update buffer size

        writeBuffer()
    }

    fun setSubdivisionOption(key: String, option: Int) {
        subdivisions[key]!!.option = option
        writeBuffer()
    }

    fun setSubdivisionVolume(key: String, volume: Float) {
        subdivisions[key]!!.volume = volume
        writeBuffer()
    }

    fun setVolume(volume: Float) {
        this.volume = volume
        writeBuffer()
    }

    fun startPlayback() {
        // TODO: Start buffer playback
    }

    fun stopPlayback() {
        // TODO: Stop buffer playback
    }

    private fun initializeBuffer() {
        val bps: Double = (120 / 60).toDouble()
        val beatDurationSeconds: Double = 1 / bps
    }

    private fun writeBuffer() {
        // TODO: Write buffer
    }
}