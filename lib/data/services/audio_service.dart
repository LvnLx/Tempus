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
  setBeatSample,
  setBeatVolume,
  setDenominator,
  setDownbeatVolume,
  setInnerBeatSample,
  setNumerator,
  setSamplePaths,
  setState,
  setSubdivisionOption,
  setSubdivisionVolume,
  startPlayback,
  stopPlayback,
}

enum Event { beatStarted }

class AudioService {
  final AssetService _assetService;
  final PreferenceService _preferenceService;

  final MethodChannel _methodChannel = MethodChannel('audio');
  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();

  late ValueNotifier<double> _appVolumeValueNotifier;
  late ValueNotifier<int> _bpmValueNotifier;
  late ValueNotifier<double> _beatVolumeValueNotifier;
  late ValueNotifier<int> _denominatorValueNotifier;
  late ValueNotifier<double> _downbeatVolumeValueNotifier;
  late ValueNotifier<int> _numeratorValueNotifier;
  late ValueNotifier<SampleSet> _sampleSetValueNotifier;
  late final ValueNotifier<Map<Key, SubdivisionData>>
      _subdivisionsValueNotifier;

  AudioService(this._assetService, this._preferenceService) {
    _methodChannel.setMethodCallHandler((call) async {
      if (Event.values.map((event) => event.name).contains(call.method)) {
        _eventController.add(Event.values
            .firstWhere((event) => event.name == call.method));
      } else {
        throw MissingPluginException(
            "Unknown method call method received: ${call.method}");
      }
    });
  }

  Future<void> init() async {
    _appVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getAppVolume());
    _bpmValueNotifier = ValueNotifier(await _preferenceService.getBpm());
    _beatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getBeatVolume());
    _denominatorValueNotifier =
        ValueNotifier(await _preferenceService.getDenominator());
    _downbeatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getDownbeatVolume());
    _numeratorValueNotifier =
        ValueNotifier(await _preferenceService.getNumerator());
    _sampleSetValueNotifier =
        ValueNotifier(await _preferenceService.getSampleSet());
    _subdivisionsValueNotifier =
        ValueNotifier(await _preferenceService.getSubdivisions());

    await _setSamplePaths(_assetService.sampleSets.fold<Set<String>>(
        {},
        (accumulator, sampleSet) => {
              ...accumulator,
              sampleSet.getBeatSamplePath(),
              sampleSet.getInnerBeatSamplePath()
            }));

    await setState(
        await _preferenceService.getAppVolume(),
        await _preferenceService.getBpm(),
        await _preferenceService.getBeatVolume(),
        await _preferenceService.getDenominator(),
        await _preferenceService.getDownbeatVolume(),
        await _preferenceService.getNumerator(),
        await _preferenceService.getSampleSet(),
        await _preferenceService.getSubdivisions());
  }

  Stream<Event> get eventStream => _eventController.stream;

  double get appVolume => _appVolumeValueNotifier.value;
  ValueNotifier get appVolumeValueNotifier => _appVolumeValueNotifier;
  int get bpm => _bpmValueNotifier.value;
  ValueNotifier<int> get bpmValueNotifier => _bpmValueNotifier;
  double get beatVolume => _beatVolumeValueNotifier.value;
  ValueNotifier<double> get beatVolumeValueNotifier => _beatVolumeValueNotifier;
  int get denominator => _denominatorValueNotifier.value;
  ValueNotifier<int> get denominatorValueNotifier => _denominatorValueNotifier;
  double get downbeatVolume => _downbeatVolumeValueNotifier.value;
  ValueNotifier<double> get downbeatVolumeValueNotifier =>
      _downbeatVolumeValueNotifier;
  int get numerator => _numeratorValueNotifier.value;
  ValueNotifier<int> get numeratorValueNotifier => _numeratorValueNotifier;
  SampleSet get sampleSet => _sampleSetValueNotifier.value;
  ValueNotifier<SampleSet> get sampleSetValueNotifier =>
      _sampleSetValueNotifier;
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

  Future<void> setDenominator(int value) async {
    _denominatorValueNotifier.value = value;

    await _setDenominator(value);
    _preferenceService.setDenominator(value);
  }

  Future<void> setDownbeatVolume(double volume) async {
    _downbeatVolumeValueNotifier.value = volume;

    await _setDownbeatVolume(volume);
    _preferenceService.setDownbeatVolume(volume);
  }

  Future<void> setNumerator(int value) async {
    _numeratorValueNotifier.value = value;

    await _setNumerator(value);
    _preferenceService.setNumerator(value);
  }

  Future<void> setSampleSet(SampleSet sampleSet) async {
    _sampleSetValueNotifier.value = sampleSet;

    await _setBeatSample(sampleSet.getBeatSamplePath());
    await _setInnerBeatSample(sampleSet.getInnerBeatSamplePath());

    _preferenceService.setSampleSet(sampleSet);
  }

  Future<void> setState(
      double appVolume,
      int bpm,
      double beatVolume,
      int denominator,
      double downbeatVolume,
      int numerator,
      SampleSet sampleSet,
      Map<Key, SubdivisionData> subdivisions) async {
    _appVolumeValueNotifier.value = appVolume;
    _bpmValueNotifier.value = bpm;
    _beatVolumeValueNotifier.value = beatVolume;
    _denominatorValueNotifier.value = denominator;
    _downbeatVolumeValueNotifier.value = downbeatVolume;
    _numeratorValueNotifier.value = numerator;
    _sampleSetValueNotifier.value = sampleSet;
    _subdivisionsValueNotifier.value = subdivisions;

    _preferenceService.setAppVolume(appVolume);
    _preferenceService.setBpm(bpm);
    _preferenceService.setBeatVolume(beatVolume);
    _preferenceService.setDenominator(denominator);
    _preferenceService.setDownbeatVolume(downbeatVolume);
    _preferenceService.setNumerator(numerator);
    _preferenceService.setSampleSet(sampleSet);
    _preferenceService.setSubdivisions(subdivisions);

    final result = await _methodChannel.invokeMethod(Action.setState.name, [
      appVolume.toString(),
      bpm.toString(),
      beatVolume.toString(),
      denominator.toString(),
      downbeatVolume.toString(),
      numerator.toString(),
      sampleSet.getBeatSamplePath(),
      sampleSet.getInnerBeatSamplePath(),
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
    final result = await _methodChannel.invokeMethod(Action.startPlayback.name);
    print(result);
  }

  Future<void> stopPlayback() async {
    final result = await _methodChannel.invokeMethod(Action.stopPlayback.name);
    print(result);
  }

  Future<void> _addSubdivision(Key key, int option, double volume) async {
    await HapticFeedback.mediumImpact();
    final result = await _methodChannel.invokeMethod(Action.addSubdivision.name,
        [key.toString(), option.toString(), volume.toString()]);
    print(result);
  }

  Future<void> _removeSubdivision(Key key) async {
    await HapticFeedback.mediumImpact();
    final result = await _methodChannel
        .invokeMethod(Action.removeSubdivision.name, [key.toString()]);
    print(result);
  }

  Future<void> _setAppVolume(double volume) async {
    final result = await _methodChannel
        .invokeMethod(Action.setAppVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setBpm(int bpm) async {
    await HapticFeedback.lightImpact();
    final result =
        await _methodChannel.invokeMethod(Action.setBpm.name, [bpm.toString()]);
    print(result);
  }

  Future<void> _setBeatSample(String path) async {
    final result =
        await _methodChannel.invokeMethod(Action.setBeatSample.name, [path]);
    print(result);
  }

  Future<void> _setBeatVolume(double volume) async {
    final result = await _methodChannel
        .invokeMethod(Action.setBeatVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setDenominator(int value) async {
    final result = await _methodChannel
        .invokeMethod(Action.setDenominator.name, [value.toString()]);
    print(result);
  }

  Future<void> _setDownbeatVolume(double volume) async {
    final result = await _methodChannel
        .invokeMethod(Action.setDownbeatVolume.name, [volume.toString()]);
    print(result);
  }

  Future<void> _setInnerBeatSample(String path) async {
    final result = await _methodChannel
        .invokeMethod(Action.setInnerBeatSample.name, [path]);
    print(result);
  }

  Future<void> _setNumerator(int value) async {
    final result = await _methodChannel
        .invokeMethod(Action.setNumerator.name, [value.toString()]);
    print(result);
  }

  Future<void> _setSamplePaths(Set<String> samplePaths) async {
    final result = await _methodChannel.invokeMethod(
        Action.setSamplePaths.name, samplePaths.toList());
    print(result);
  }

  Future<void> _setSubdivisionOption(Key key, int option) async {
    await HapticFeedback.lightImpact();
    final result = await _methodChannel.invokeMethod(
        Action.setSubdivisionOption.name, [key.toString(), option.toString()]);
    print(result);
  }

  Future<void> _setSubdivisionVolume(Key key, double volume) async {
    final result = await _methodChannel.invokeMethod(
        Action.setSubdivisionVolume.name, [key.toString(), volume.toString()]);
    print(result);
  }
}
