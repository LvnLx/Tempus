import 'dart:async';

import 'package:flutter/services.dart';

class Audio {
  static const MethodChannel methodChannel = MethodChannel('audio_method_channel');

  static Future<void> postFlutterInit() async {
    final result = await methodChannel.invokeMethod('postFlutterInit');
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

  static Future<void> configureBuffer(int bpm) async {
    final result = await methodChannel.invokeMethod('configureAudioBuffer', [bpm.toString()]);
    print(result);
  }
}