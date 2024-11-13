package com.lvnlx.metronomic

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val metronome = Metronome()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "audio"
        ).setMethodCallHandler { call, result ->
            run {
                var arguments: ArrayList<String> = arrayListOf()
                try {
                    arguments.addAll(call.arguments as ArrayList<String>)
                } catch (_: Exception) {}
                when (call.method) {
                    "addSubdivision" -> {
                        val key: String = arguments[0]
                        val option: Int = arguments[1].toInt()
                        val volume: Float = arguments[2].toFloat()
                        metronome.addSubdivision(key, option, volume)
                        result.success("Added subdivision")
                    }

                    "removeSubdivision" -> {
                        val key: String = arguments[0]
                        metronome.removeSubdivision(key)
                        result.success("Removed subdivision")
                    }

                    "setBpm" -> {
                        val bpm: Int = arguments[0].toInt()
                        metronome.setBpm(bpm)
                        result.success("Set BPM")
                    }

                    "setSubdivisionOption" -> {
                        val key: String = arguments[0]
                        val option: Int = arguments[1].toInt()
                        metronome.setSubdivisionOption(key, option)
                        result.success("Set subdivision option")
                    }

                    "setSubdivisionVolume" -> {
                        val key: String = arguments[0]
                        val volume: Float = arguments[1].toFloat()
                        metronome.setSubdivisionVolume(key, volume)
                        result.success("Set subdivision volume")
                    }

                    "setVolume" -> {
                        val volume: Float = arguments[0].toFloat()
                        metronome.setVolume(volume)
                        result.success("Set volume")
                    }

                    "startPlayback" -> {
                        metronome.startPlayback()
                        result.success("Started playback")
                    }

                    "stopPlayback" -> {
                        metronome.stopPlayback()
                        result.success("Stopped playback")
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}
