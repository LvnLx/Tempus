import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Audio {
  static MethodChannel methodChannel = MethodChannel('audio_method_channel');

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
    final result =
        await methodChannel.invokeMethod('setBpm', [bpm.toString()]);
    print(result);
  }

  static Future<void> addSubdivision(Key key) async {
    final result = await methodChannel.invokeMethod('addSubdivision');
    print(result);
  }

  static Future<void> removeSubdivision(Key key) async {
    final result = await methodChannel.invokeMethod('removeSubdivision');
    print(result);
  }

  static Future<void> setSubdivisionOption(
      Key key, String subdivisionOption) async {
    final result = await methodChannel.invokeMethod('setSubdivisionOption');
    print(result);
  }

  static Future<void> setSubdivisionVolume(Key key, double volume) async {
    final result = await methodChannel.invokeMethod('setSubdivisionVolume');
    print(result);
  }
}
