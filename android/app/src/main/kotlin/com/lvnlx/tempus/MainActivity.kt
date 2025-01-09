package com.lvnlx.tempus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        init {
            System.loadLibrary("tempus")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val fileHandler = FileHandler(assets)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, "audio"
        ).setMethodCallHandler { call, result ->
            run {
                val arguments: ArrayList<String> = arrayListOf()
                try {
                    arguments.addAll(call.arguments as ArrayList<String>)
                } catch (_: Exception) {
                }
                when (call.method) {
                    "addSubdivision" -> {
                        val key: String = arguments[0]
                        val option: Int = arguments[1].toInt()
                        val volume: Float = arguments[2].toFloat()
                        addSubdivision(key, option, volume)
                        result.success("Added subdivision")
                    }

                    "removeSubdivision" -> {
                        val key: String = arguments[0]
                        removeSubdivision(key)
                        result.success("Removed subdivision")
                    }

                    "setBpm" -> {
                        val bpm: Int = arguments[0].toInt()
                        setBpm(bpm)
                        result.success("Set BPM")
                    }

                    "setSample" -> {
                        val isDownbeat: Boolean = arguments[0].toBoolean()
                        val sampleName: String = arguments[1]
                        setSample(isDownbeat, sampleName)
                        result.success("Set sample")
                    }

                    "setSampleNames" -> {
                        for (sampleName in arguments) {
                            loadAudioFrames(sampleName, fileHandler.loadAudioFrames(sampleName))
                        }
                        result.success("Set sample names")
                    }

                    "setState" -> {
                        val bpm: Int = arguments[0].toInt()
                        val downbeatSampleName: String = arguments[1]
                        val subdivisionSampleName: String = arguments[2]
                        val volume: Float = arguments[3].toFloat()
                        setState(bpm, downbeatSampleName, subdivisionSampleName, volume)
                        result.success("Set state")
                    }

                    "setSubdivisionOption" -> {
                        val key: String = arguments[0]
                        val option: Int = arguments[1].toInt()
                        setSubdivisionOption(key, option)
                        result.success("Set subdivision option")
                    }

                    "setSubdivisionVolume" -> {
                        val key: String = arguments[0]
                        val volume: Float = arguments[1].toFloat()
                        setSubdivisionVolume(key, volume)
                        result.success("Set subdivision volume")
                    }

                    "setVolume" -> {
                        val volume: Float = arguments[0].toFloat()
                        setVolume(volume)
                        result.success("Set volume")
                    }

                    "startPlayback" -> {
                        startPlayback()
                        result.success("Started playback")
                    }

                    "stopPlayback" -> {
                        stopPlayback()
                        result.success("Stopped playback")
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    private external fun addSubdivision(key: String, option: Int, volume: Float)
    private external fun loadAudioFrames(fileName: String, audioFrames: FloatArray)
    private external fun removeSubdivision(key: String)
    private external fun setBpm(bpm: Int)
    private external fun setSample(isDownbeat: Boolean, sampleName: String)
    private external fun setState(
        bpm: Int, downbeatSampleName: String, subdivisionSampleName: String, volume: Float
    )

    private external fun setSubdivisionOption(key: String, option: Int)
    private external fun setSubdivisionVolume(key: String, volume: Float)
    private external fun setVolume(volume: Float)
    private external fun startPlayback()
    private external fun stopPlayback()
}
