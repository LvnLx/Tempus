import 'dart:async';

import 'package:flutter/services.dart';

class Audio {
  static const MethodChannel methodChannel = MethodChannel('audio_method_channel');

  static Future<void> postFlutterInit(int bpm) async {
    final result = await methodChannel.invokeMethod('postFlutterInit');
    print(result);
    await updateBpm(bpm);
    await configureBuffer();
  }

  static Future<void> configureBuffer() async {
    final result = await methodChannel.invokeMethod('configureAudioBuffer');
    print(result);
  }

  static Future<void> startPlayback() async {
    final result = await methodChannel.invokeMethod('startPlayback');
    print(result);
  }

  static Future<void> stopPlayback() async {
    final result = await methodChannel.invokeMethod('stopPlayback');
    print(result);
  }

  static Future<void> updateBpm(int bpm) async {
    final result = await methodChannel.invokeMethod('updateBpm', [bpm.toString()]);
    print(result);
  }
}