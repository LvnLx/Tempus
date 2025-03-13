import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/constants.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/domain/extensions/subdivisions.dart';
import 'package:tempus/domain/models/beat_unit.dart';
import 'package:tempus/domain/models/sample_set.dart';
import 'package:tempus/domain/models/time_signature.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

enum Action {
  setAppVolume,
  addSubdivision,
  removeSubdivision,
  setBpm,
  setBeatSample,
  setBeatUnit,
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
  late ValueNotifier<BeatUnit> _beatUnitValueNotifier;
  late ValueNotifier<double> _beatVolumeValueNotifier;
  late ValueNotifier<double> _downbeatVolumeValueNotifier;
  late ValueNotifier<SampleSet> _sampleSetValueNotifier;
  late ValueNotifier<TimeSignature> _timeSignatureValueNotifier;

  late final ValueNotifier<Map<Key, SubdivisionData>>
      _subdivisionsValueNotifier;

  AudioService(this._assetService, this._preferenceService) {
    _methodChannel.setMethodCallHandler((call) async {
      if (Event.values.map((event) => event.name).contains(call.method)) {
        _eventController
            .add(Event.values.firstWhere((event) => event.name == call.method));
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
    _beatUnitValueNotifier =
        ValueNotifier(await _preferenceService.getBeatUnit());
    _beatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getBeatVolume());
    _downbeatVolumeValueNotifier =
        ValueNotifier(await _preferenceService.getDownbeatVolume());
    _sampleSetValueNotifier =
        ValueNotifier(await _preferenceService.getSampleSet());
    _subdivisionsValueNotifier =
        ValueNotifier(await _preferenceService.getSubdivisions());
    _timeSignatureValueNotifier =
        ValueNotifier(await _preferenceService.getTimeSignature());

    await _setSamplePaths(_assetService.sampleSets.fold<Set<String>>(
        {},
        (accumulator, sampleSet) => {
              ...accumulator,
              sampleSet.getBeatSamplePath(),
              sampleSet.getInnerBeatSamplePath()
            }));

    await setState(appVolume, bpm, beatUnit, beatVolume, downbeatVolume,
        sampleSet, subdivisions, timeSignature);
  }

  Stream<Event> get eventStream => _eventController.stream;

  double get appVolume => _appVolumeValueNotifier.value;
  ValueNotifier get appVolumeValueNotifier => _appVolumeValueNotifier;
  int get bpm => _bpmValueNotifier.value;
  ValueNotifier<int> get bpmValueNotifier => _bpmValueNotifier;
  BeatUnit get beatUnit => _beatUnitValueNotifier.value;
  ValueNotifier<BeatUnit> get beatUnitValueNotifier => _beatUnitValueNotifier;
  double get beatVolume => _beatVolumeValueNotifier.value;
  ValueNotifier<double> get beatVolumeValueNotifier => _beatVolumeValueNotifier;
  double get downbeatVolume => _downbeatVolumeValueNotifier.value;
  ValueNotifier<double> get downbeatVolumeValueNotifier =>
      _downbeatVolumeValueNotifier;
  SampleSet get sampleSet => _sampleSetValueNotifier.value;
  ValueNotifier<SampleSet> get sampleSetValueNotifier =>
      _sampleSetValueNotifier;
  Map<Key, SubdivisionData> get subdivisions =>
      _subdivisionsValueNotifier.value;
  ValueNotifier<Map<Key, SubdivisionData>> get subdivisionsValueNotifier =>
      _subdivisionsValueNotifier;
  TimeSignature get timeSignature => _timeSignatureValueNotifier.value;
  ValueNotifier<TimeSignature> get timeSignatureValueNotifier =>
      _timeSignatureValueNotifier;

  Future<void> addSubdivision() async {
    UniqueKey key = UniqueKey();
    _subdivisionsValueNotifier.value = {
      ...subdivisions,
      key: SubdivisionData(option: Constants.subdivisionOptions[0], volume: 0.0)
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

  Future<void> setBeatUnit(BeatUnit beatUnit) async {
    _beatUnitValueNotifier.value = beatUnit;

    await _setBeatUnit(beatUnit);
    _preferenceService.setBeatUnit(beatUnit);
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

  Future<void> setSampleSet(SampleSet sampleSet) async {
    _sampleSetValueNotifier.value = sampleSet;

    await _setBeatSample(sampleSet.getBeatSamplePath());
    await _setInnerBeatSample(sampleSet.getInnerBeatSamplePath());

    _preferenceService.setSampleSet(sampleSet);
  }

  Future<void> setState(
      double appVolume,
      int bpm,
      BeatUnit beatUnit,
      double beatVolume,
      double downbeatVolume,
      SampleSet sampleSet,
      Map<Key, SubdivisionData> subdivisions,
      TimeSignature timeSignature) async {
    _appVolumeValueNotifier.value = appVolume;
    _bpmValueNotifier.value = bpm;
    _beatUnitValueNotifier.value = beatUnit;
    _beatVolumeValueNotifier.value = beatVolume;
    _downbeatVolumeValueNotifier.value = downbeatVolume;
    _sampleSetValueNotifier.value = sampleSet;
    _subdivisionsValueNotifier.value = subdivisions;
    _timeSignatureValueNotifier.value = timeSignature;

    _preferenceService.setAppVolume(appVolume);
    _preferenceService.setBpm(bpm);
    _preferenceService.setBeatUnit(beatUnit);
    _preferenceService.setBeatVolume(beatVolume);
    _preferenceService.setDownbeatVolume(downbeatVolume);
    _preferenceService.setSampleSet(sampleSet);
    _preferenceService.setSubdivisions(subdivisions);
    _preferenceService.setTimeSignature(timeSignature);

    final result = await _methodChannel.invokeMethod(Action.setState.name, [
      appVolume.toString(),
      bpm.toString(),
      beatUnit.toJsonString(),
      beatVolume.toString(),
      timeSignature.denominator.toString(),
      downbeatVolume.toString(),
      timeSignature.numerator.toString(),
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

  Future<void> setTimeSignature(TimeSignature timeSignature) async {
    _timeSignatureValueNotifier.value = timeSignature;

    await setBeatUnit(timeSignature.defaultBeatUnit());
    await _setNumerator(timeSignature.numerator);
    await _setDenominator(timeSignature.denominator);

    _preferenceService.setTimeSignature(timeSignature);
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

  Future<void> _setBeatUnit(BeatUnit beatUnit) async {
    final result = await _methodChannel
        .invokeMethod(Action.setBeatUnit.name, [beatUnit.toJsonString()]);
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
