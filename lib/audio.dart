import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Action {
  addSubdivision,
  removeSubdivision,
  setBpm,
  setSample,
  setSampleNames,
  setState,
  setSubdivisionOption,
  setSubdivisionVolume,
  setVolume,
  startPlayback,
  stopPlayback,
  writeBuffer
}

class SamplePair {
  String name;

  late String downbeatSample;
  late String subdivisionSample;

  SamplePair({required this.name}) {
    downbeatSample = "audio/$name/downbeat.wav";
    subdivisionSample = "audio/$name/subdivision.wav";
  }
}

late List<SamplePair> samplePairs;

class Audio {
  static MethodChannel methodChannel = MethodChannel('audio');
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

  static Future<void> addSubdivision(Key key, int option, double volume) async {
    final result = await methodChannel.invokeMethod(Action.addSubdivision.name,
        [key.toString(), option.toString(), volume.toString()]);
    print(result);
  }

  static Future<void> removeSubdivision(Key key) async {
    final result = await methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  static Future<void> setBpm(int bpm) async {
    final result =
        await methodChannel.invokeMethod(Action.setBpm.name, [bpm.toString()]);
    print(result);
  }

  static Future<void> setSample(bool isDownbeat, String sampleName) async {
    final result = await methodChannel.invokeMethod(
        Action.setSample.name, [isDownbeat.toString(), sampleName]);
    print(result);
  }

  static Future<void> setSampleNames(Set<String> sampleNames) async {
    final result = await methodChannel.invokeMethod(
        Action.setSampleNames.name, sampleNames.toList());
    print(result);
  }

  static Future<void> setState(
      int bpm,
      String downbeatSampleName,
      String subdivisionSampleName,
      String subdivisionsAsJsonString,
      double volume) async {
    final result = await methodChannel.invokeMethod(Action.setState.name, [
      bpm.toString(),
      downbeatSampleName,
      subdivisionSampleName,
      subdivisionsAsJsonString,
      volume.toString()
    ]);
    print(result);
  }

  static Future<void> setSubdivisionOption(Key key, int option) async {
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionOption.name, [key.toString(), option.toString()]);
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

  static Future<void> writeBuffer() async {
    final result = await methodChannel.invokeMethod(Action.writeBuffer.name);
    print(result);
  }
}
