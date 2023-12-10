import 'package:flutter/services.dart';

class Audio {
  static const MethodChannel methodChannel = MethodChannel('audio_method_channel');

  static Future<void> startPlayback() async {
    final result = await methodChannel.invokeMethod('startPlayback');
    print(result);
  }

  static Future<void> stopPlayback() async {
    final result = await methodChannel.invokeMethod('stopPlayback');
    print(result);
  }
}