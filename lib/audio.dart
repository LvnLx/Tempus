import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Action {
  addSubdivision,
  removeSubdivision,
  setBpm,
  setSubdivisionOption,
  setSubdivisionVolume,
  setVolume,
  startPlayback,
  stopPlayback,
  writeDownbeat
}

class Audio {
  static MethodChannel methodChannel = MethodChannel('audio_method_channel');
  static Map<Action, bool> throttles =
      Map.fromEntries(Action.values.map((action) => MapEntry(action, false)));

  static bool isThrottled(Action action) {
    if (throttles[action] ?? false) {
      return true;
    } else {
      throttles[action] = true;
      Future.delayed(
          Duration(milliseconds: 100), () => throttles[action] = false);
      return false;
    }
  }

  static Future<void> postFlutterInit(int bpm) async {
    await setBpm(bpm);
    await writeDownbeat();
  }

  static Future<void> addSubdivision(
      Key key, String subdivisionOption, double volume) async {
    final result = await methodChannel.invokeMethod(Action.addSubdivision.name,
        [key.toString(), subdivisionOption, volume.toString()]);
    print(result);
  }

  static Future<void> removeSubdivision(Key key) async {
    final result = await methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  static Future<void> setBpm(int bpm) async {
    final result = await methodChannel.invokeMethod(Action.setBpm.name, [bpm.toString()]);
    print(result);
  }

  static Future<void> setSubdivisionOption(
      Key key, String subdivisionOption) async {
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionOption.name, [key.toString(), subdivisionOption]);
    print(result);
  }

  static Future<void> setSubdivisionVolume(Key key, double volume,
      [bool useThrottling = true]) async {
    if (useThrottling && isThrottled(Action.setSubdivisionVolume)) return;
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionVolume.name, [key.toString(), volume.toString()]);
    print(result);
  }

  static Future<void> setVolume(double volume,
      [bool useThrottling = true]) async {
    if (useThrottling && isThrottled(Action.setVolume)) return;
    final result = await methodChannel
        .invokeMethod(Action.setVolume.name, [volume.toString()]);
    print(result);
  }

  static Future<void> startPlayback() async {
    final result = await methodChannel.invokeMethod(Action.startPlayback.name);
    print(result);
  }

  static Future<void> stopPlayback() async {
    final result = await methodChannel.invokeMethod(Action.stopPlayback.name);
    print(result);
  }

  static Future<void> writeDownbeat() async {
    final result = await methodChannel.invokeMethod(Action.writeDownbeat.name);
    print(result);
  }
}
