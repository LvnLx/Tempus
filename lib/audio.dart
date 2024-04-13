import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Audio {
  static MethodChannel methodChannel = MethodChannel('audio_method_channel');

  static Future<void> postFlutterInit(int bpm) async {
    await setBpm(bpm);
    await writeDownbeat();
  }

  static Future<void> addSubdivision(Key key, String subdivisionOption, double volume) async {
    final result = await methodChannel
        .invokeMethod('addSubdivision', [key.toString(), subdivisionOption, volume.toString()]);
    print(result);
  }

  static Future<void> removeSubdivision(Key key) async {
    final result = await methodChannel.invokeMethod('removeSubdivision', [key.toString()]);
    print(result);
  }

  static Future<void> setBpm(int bpm) async {
    final result = await methodChannel.invokeMethod('setBpm', [bpm.toString()]);
    print(result);
  }

  static Future<void> setSubdivisionOption(
      Key key, String subdivisionOption) async {
    final result = await methodChannel.invokeMethod('setSubdivisionOption', [key.toString(), subdivisionOption]);
    print(result);
  }

  static Future<void> setSubdivisionVolume(Key key, double volume) async {
    final result = await methodChannel.invokeMethod('setSubdivisionVolume', [key.toString(), volume.toString()]);
    print(result);
  }

  static Future<void> setVolume(double volume) async {
    final result = await methodChannel.invokeMethod('setVolume', [volume.toString()]);
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

  static Future<void> writeDownbeat() async {
    final result = await methodChannel.invokeMethod('writeDownbeat');
    print(result);
  }
}
