import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/domain/models/sample_pair.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';
import 'package:tempus/util.dart';

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
}

class AudioService {
  final AssetService _assetService;
  final PreferenceService _preferenceService;

  final MethodChannel methodChannel = MethodChannel('audio');

  late ValueNotifier<int> _bpmValueNotifier;
  late ValueNotifier<SamplePair> _samplePairValueNotifier;
  late final ValueNotifier<Map<Key, SubdivisionData>>
      _subdivisionsValueNotifier;
  late ValueNotifier<double> _volumeValueNotifier;

  AudioService(this._assetService, this._preferenceService);

  Future<void> init() async {
    _bpmValueNotifier = ValueNotifier(await _preferenceService.getBpm());
    _samplePairValueNotifier =
        ValueNotifier(await _preferenceService.getSamplePair());
    _subdivisionsValueNotifier =
        ValueNotifier(await _preferenceService.getSubdivisions());
    _volumeValueNotifier = ValueNotifier(await _preferenceService.getVolume());

    await setSampleNames(_assetService.samplePairs.fold<Set<String>>(
        {},
        (accumulator, samplePair) => {
              ...accumulator,
              samplePair.getDownbeatSamplePath(),
              samplePair.getSubdivisionSamplePath()
            }));

    SamplePair samplePair = await _preferenceService.getSamplePair();
    await setState(
        await _preferenceService.getBpm(),
        samplePair.getDownbeatSamplePath(),
        samplePair.getSubdivisionSamplePath(),
        jsonEncodeSubdivisions(subdivisions),
        await _preferenceService.getVolume());
  }

  int get bpm => _bpmValueNotifier.value;
  ValueNotifier<int> get bpmValueNotifier => _bpmValueNotifier;
  SamplePair get samplePair => _samplePairValueNotifier.value;
  ValueNotifier<SamplePair> get samplePairValueNotifier =>
      _samplePairValueNotifier;
  Map<Key, SubdivisionData> get subdivisions =>
      _subdivisionsValueNotifier.value;
  ValueNotifier<Map<Key, SubdivisionData>> get subdivisionsValueNotifier =>
      _subdivisionsValueNotifier;
  double get volume => _volumeValueNotifier.value;
  ValueNotifier<double> get volumeValueNotifier => _volumeValueNotifier;

  Future<void> addSubdivision() async {
    UniqueKey key = UniqueKey();
    _subdivisionsValueNotifier.value = {
      ...subdivisions,
      key: SubdivisionData(option: subdivisionOptions[0], volume: 0.0)
    };

    await _addSubdivision(
        key, subdivisions[key]!.option, subdivisions[key]!.volume);
    _preferenceService.setSubdivisions(subdivisions);
  }

  Future<void> removeSubdivision(Key key) async {
    _subdivisionsValueNotifier.value = {...subdivisions}..remove(key);

    await _removeSubdivision(key);
    _preferenceService.setSubdivisions(subdivisions);
  }

  Future<void> setSamplePair(SamplePair samplePair) async {
    _samplePairValueNotifier.value = samplePair;

    await _setSample(true, samplePair.getDownbeatSamplePath());
    await _setSample(false, samplePair.getSubdivisionSamplePath());

    _preferenceService.setSamplePair(samplePair);
  }

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async {
    late int validatedBpm;

    if (bpm < 1) {
      validatedBpm = 1;
    } else if (bpm > 999) {
      validatedBpm = 999;
    } else {
      validatedBpm = bpm;
    }

    if (skipUnchanged && validatedBpm == bpmValueNotifier.value) {
      return;
    } else {
      _bpmValueNotifier.value = validatedBpm;
    }

    await _setBpm(validatedBpm);
    _preferenceService.setBpm(validatedBpm);
  }

  Future<void> setSampleNames(Set<String> sampleNames) async {
    final result = await methodChannel.invokeMethod(
        Action.setSampleNames.name, sampleNames.toList());
    print(result);
  }

  Future<void> setState(
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

  Future<void> setSubdivisionOption(Key key, int option) async {
    _subdivisionsValueNotifier.value = {...subdivisions}..update(
        key,
        (subdivisionData) =>
            SubdivisionData(option: option, volume: subdivisionData.volume));

    await _setSubdivisionOption(key, option);
    _preferenceService.setSubdivisions(subdivisions);
  }

  Future<void> setSubdivisionVolume(Key key, double volume) async {
    _subdivisionsValueNotifier.value = {...subdivisions}..update(
        key,
        (subdivisionData) =>
            SubdivisionData(option: subdivisionData.option, volume: volume));

    await _setSubdivisionVolume(key, volume);
    _preferenceService.setSubdivisions(subdivisions);
  }

  Future<void> setVolume(double volume) async {
    _volumeValueNotifier.value = volume;

    await _setVolume(volume);
    _preferenceService.setVolume(volume);
  }

  Future<void> startPlayback() async {
    final result = await methodChannel.invokeMethod(Action.startPlayback.name);
    print(result);
  }

  Future<void> stopPlayback() async {
    final result = await methodChannel.invokeMethod(Action.stopPlayback.name);
    print(result);
  }

  Future<void> _addSubdivision(Key key, int option, double volume) async {
    await HapticFeedback.mediumImpact();
    final result = await methodChannel.invokeMethod(Action.addSubdivision.name,
        [key.toString(), option.toString(), pow(volume, 2).toString()]);
    print(result);
  }

  Future<void> _removeSubdivision(Key key) async {
    await HapticFeedback.mediumImpact();
    final result = await methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  Future<void> _setBpm(int bpm) async {
    await HapticFeedback.lightImpact();
    final result =
        await methodChannel.invokeMethod(Action.setBpm.name, [bpm.toString()]);
    print(result);
  }

  Future<void> _setSample(bool isDownbeat, String sampleName) async {
    final result = await methodChannel.invokeMethod(
        Action.setSample.name, [isDownbeat.toString(), sampleName]);
    print(result);
  }

  Future<void> _setSubdivisionOption(Key key, int option) async {
    await HapticFeedback.lightImpact();
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionOption.name, [key.toString(), option.toString()]);
    print(result);
  }

  Future<void> _setSubdivisionVolume(Key key, double volume) async {
    final result = await methodChannel.invokeMethod(
        Action.setSubdivisionVolume.name,
        [key.toString(), pow(volume, 2).toString()]);
    print(result);
  }

  Future<void> _setVolume(double volume) async {
    final result = await methodChannel
        .invokeMethod(Action.setVolume.name, [pow(volume, 2).toString()]);
    print(result);
  }
}
