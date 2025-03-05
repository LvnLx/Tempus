import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/domain/extensions/subdivisions.dart';
import 'package:tempus/domain/models/sample_pair.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

enum Action {
  setAppVolume,
  addSubdivision,
  removeSubdivision,
  setBpm,
  setBeatVolume,
  setDownbeatVolume,
  setSample,
  setSampleNames,
  setState,
  setSubdivisionOption,
  setSubdivisionVolume,
  startPlayback,
  stopPlayback,
}

class AudioService {
  final AssetService _assetService;
  final PreferenceService _preferenceService;

  final MethodChannel methodChannel = MethodChannel('audio');

  late ValueNotifier<double> _appVolumeValueNotifier;
  late ValueNotifier<int> _bpmValueNotifier;
  late ValueNotifier<double> _beatVolumeValueNotifier;
  late ValueNotifier<double> _downbeatVolumeValueNotifier;
  late ValueNotifier<SamplePair> _samplePairValueNotifier;
  late final ValueNotifier<Map<Key, SubdivisionData>>
      _subdivisionsValueNotifier;

  AudioService(this._assetService, this._preferenceService);

  Future<void> init() async {
    _appVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getAppVolume());
    _bpmValueNotifier = ValueNotifier(await _preferenceService.getBpm());
    _beatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getBeatVolume());
    _downbeatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getDownbeatVolume());
    _samplePairValueNotifier =
        ValueNotifier(await _preferenceService.getSamplePair());
    _subdivisionsValueNotifier =
        ValueNotifier(await _preferenceService.getSubdivisions());

    await _setSampleNames(_assetService.samplePairs.fold<Set<String>>(
        {},
        (accumulator, samplePair) => {
              ...accumulator,
              samplePair.getDownbeatSamplePath(),
              samplePair.getSubdivisionSamplePath()
            }));

    await setState(
        await _preferenceService.getAppVolume(),
        await _preferenceService.getBpm(),
        await _preferenceService.getBeatVolume(),
        await _preferenceService.getDownbeatVolume(),
        await _preferenceService.getSamplePair(),
        await _preferenceService.getSubdivisions());
  }

  double get appVolume => _appVolumeValueNotifier.value;
  ValueNotifier get appVolumeValueNotifier => _appVolumeValueNotifier;
  int get bpm => _bpmValueNotifier.value;
  ValueNotifier<int> get bpmValueNotifier => _bpmValueNotifier;
  double get beatVolume => _beatVolumeValueNotifier.value;
  ValueNotifier<double> get beatVolumeValueNotifier => _beatVolumeValueNotifier;
  double get downbeatVolume => _downbeatVolumeValueNotifier.value;
  ValueNotifier<double> get downbeatVolumeValueNotifier =>
      _downbeatVolumeValueNotifier;
  SamplePair get samplePair => _samplePairValueNotifier.value;
  ValueNotifier<SamplePair> get samplePairValueNotifier =>
      _samplePairValueNotifier;
  Map<Key, SubdivisionData> get subdivisions =>
      _subdivisionsValueNotifier.value;
  ValueNotifier<Map<Key, SubdivisionData>> get subdivisionsValueNotifier =>
      _subdivisionsValueNotifier;

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

  Future<void> setAppVolume(double volume) async {
    _appVolumeValueNotifier.value = volume;

    await _setAppVolume(volume);
    _preferenceService.setAppVolume(volume);
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

  Future<void> setBeatVolume(double volume) async {
    _beatVolumeValueNotifier.value = volume;

    await _setBeatVolume(volume);
    _preferenceService.setBeatVolume(volume);
  }

  Future<void> setDownbeatVolume(double volume) async {
    _downbeatVolumeValueNotifier.value = volume;

    await _setDownbeatVolume(volume);
    _preferenceService.setDownbeatVolume(volume);
  }

  Future<void> setSamplePair(SamplePair samplePair) async {
    _samplePairValueNotifier.value = samplePair;

    await _setSample(true, samplePair.getDownbeatSamplePath());
    await _setSample(false, samplePair.getSubdivisionSamplePath());

    _preferenceService.setSamplePair(samplePair);
  }

  Future<void> setState(
      double appVolume,
      int bpm,
      double beatVolume,
      double downbeatVolume,
      SamplePair samplePair,
      Map<Key, SubdivisionData> subdivisions) async {
    _bpmValueNotifier.value = bpm;
    _beatVolumeValueNotifier.value = beatVolume;
    _downbeatVolumeValueNotifier.value = downbeatVolume;
    _samplePairValueNotifier.value = samplePair;
    _subdivisionsValueNotifier.value = subdivisions;

    final result = await methodChannel.invokeMethod(Action.setState.name, [
      appVolume.toString(),
      bpm.toString(),
      beatVolume.toString(),
      downbeatVolume.toString(),
      samplePair.getDownbeatSamplePath(),
      samplePair.getSubdivisionSamplePath(),
      subdivisions.toJsonString(),
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
        [key.toString(), option.toString(), volume.toString()]);
    print(result);
  }

  Future<void> _removeSubdivision(Key key) async {
    await HapticFeedback.mediumImpact();
    final result = await methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  Future<void> _setAppVolume(double volume) async {
    final result = await methodChannel
        .invokeMethod(Action.setAppVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setBpm(int bpm) async {
    await HapticFeedback.lightImpact();
    final result =
        await methodChannel.invokeMethod(Action.setBpm.name, [bpm.toString()]);
    print(result);
  }

  Future<void> _setBeatVolume(double volume) async {
    final result = await methodChannel
        .invokeMethod(Action.setBeatVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setDownbeatVolume(double volume) async {
    final result = await methodChannel
        .invokeMethod(Action.setDownbeatVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setSample(bool isDownbeat, String sampleName) async {
    final result = await methodChannel.invokeMethod(
        Action.setSample.name, [isDownbeat.toString(), sampleName]);
    print(result);
  }

  Future<void> _setSampleNames(Set<String> sampleNames) async {
    final result = await methodChannel.invokeMethod(
        Action.setSampleNames.name, sampleNames.toList());
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
        Action.setSubdivisionVolume.name, [key.toString(), volume.toString()]);
    print(result);
  }
}
