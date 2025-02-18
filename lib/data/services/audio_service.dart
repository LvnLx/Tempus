import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/domain/models/sample_pair.dart';

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

late List<SamplePair> samplePairs;

class AudioService {
  static MethodChannel methodChannel = MethodChannel('audio');

  static Future<void> addSubdivision(Key key, int option, double volume) async {
    await HapticFeedback.mediumImpact();
    final result = await methodChannel.invokeMethod(Action.addSubdivision.name,
        [key.toString(), option.toString(), pow(volume, 2).toString()]);
    print(result);
  }

  static Future<void> removeSubdivision(Key key) async {
    await HapticFeedback.mediumImpact();
    final result = await methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  static Future<void> setBpm(int bpm) async {
    await HapticFeedback.lightImpact();
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
      pow(volume, 2).toString()
    ]);
    print(result);
  }

  static Future<void> setSubdivisionOption(Key key, int option) async {
    await HapticFeedback.lightImpact();
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionOption.name, [key.toString(), option.toString()]);
    print(result);
  }

  static Future<void> setSubdivisionVolume(Key key, double volume) async {
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionVolume.name,
        [key.toString(), pow(volume, 2).toString()]);
    print(result);
  }

  static Future<void> setVolume(double volume) async {
    final result = await methodChannel
        .invokeMethod(Action.setVolume.name, [pow(volume, 2).toString()]);
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
