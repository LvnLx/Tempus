import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/domain/extensions/subdivisions.dart';
import 'package:tempus/domain/models/fraction.dart' as fraction;
import 'package:tempus/domain/models/sample_set.dart' as sample_set;
import 'package:tempus/ui/home/mixer/channel/view.dart';

class AudioService {
  final AssetService _assetService;
  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();
  final MethodChannel _methodChannel = MethodChannel('audio');
  final PreferenceService _preferenceService;

  late AppVolume _appVolume;
  late BeatUnit _beatUnit;
  late BeatVolume _beatVolume;
  late Bpm _bpm;
  late DownbeatVolume _downbeatVolume;
  late SampleSet _sampleSet;
  late Subdivisions _subdivisions;
  late TimeSignature _timeSignature;

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
    _appVolume = AppVolume(this, _preferenceService.setAppVolume,
        ValueNotifier(await _preferenceService.getAppVolume()));
    _beatUnit = BeatUnit(this, _preferenceService.setBeatUnit,
        ValueNotifier(await _preferenceService.getBeatUnit()));
    _beatVolume = BeatVolume(this, _preferenceService.setBeatVolume,
        ValueNotifier(await _preferenceService.getBeatVolume()));
    _bpm = Bpm(this, _preferenceService.setBpm,
        ValueNotifier(await _preferenceService.getBpm()));
    _downbeatVolume = DownbeatVolume(this, _preferenceService.setDownbeatVolume,
        ValueNotifier(await _preferenceService.getDownbeatVolume()));
    _sampleSet = SampleSet(this, _preferenceService.setSampleSet,
        ValueNotifier(await _preferenceService.getSampleSet()));
    _subdivisions = Subdivisions(this, _preferenceService.setSubdivisions,
        ValueNotifier(await _preferenceService.getSubdivisions()));
    _timeSignature = TimeSignature(this, _preferenceService.setTimeSignature,
        ValueNotifier(await _preferenceService.getTimeSignature()));

    await _setSamplePaths(_assetService.sampleSets.fold(
        {},
        (accumulator, sampleSet) => {
              ...accumulator,
              sampleSet.getBeatSamplePath(),
              sampleSet.getDownbeatSamplePath(),
              sampleSet.getInnerBeatSamplePath()
            }));

    await setState(
        _appVolume.value,
        _bpm.value,
        _beatUnit.value,
        _beatVolume.value,
        _downbeatVolume.value,
        _sampleSet.value,
        _subdivisions.value,
        _timeSignature.value);
  }

  Stream<Event> get eventStream => _eventController.stream;

  AppVolume get appVolume => _appVolume;
  BeatUnit get beatUnit => _beatUnit;
  BeatVolume get beatVolume => _beatVolume;
  Bpm get bpm => _bpm;
  DownbeatVolume get downbeatVolume => _downbeatVolume;
  SampleSet get sampleSet => _sampleSet;
  Subdivisions get subdivisions => _subdivisions;
  TimeSignature get timeSignature => _timeSignature;

  Future<void> setState(
      double appVolume,
      int bpm,
      fraction.BeatUnit beatUnit,
      double beatVolume,
      double downbeatVolume,
      sample_set.SampleSet sampleSet,
      Map<Key, SubdivisionData> subdivisions,
      fraction.TimeSignature timeSignature) async {
    await _appVolume.set(appVolume, isMetronomeInitialization: true);
    await _bpm.set(bpm, flag: false, isMetronomeInitialization: true);
    await _beatUnit.set(beatUnit, isMetronomeInitialization: true);
    await _beatVolume.set(beatVolume, isMetronomeInitialization: true);
    await _downbeatVolume.set(downbeatVolume, isMetronomeInitialization: true);
    await _sampleSet.set(sampleSet, isMetronomeInitialization: true);
    await _subdivisions.set(subdivisions, isMetronomeInitialization: true);
    await _timeSignature.set(timeSignature, isMetronomeInitialization: true);

    final result = await _methodChannel.invokeMethod("initializeMetronome");
    print(result);
  }

  Future<void> startPlayback() async {
    final result = await _methodChannel.invokeMethod("startPlayback");
    print(result);
  }

  Future<void> stopPlayback() async {
    final result = await _methodChannel.invokeMethod("stopPlayback");
    print(result);
  }

  Future<void> _setSamplePaths(Set<String> samplePaths) async {
    final result = await _methodChannel.invokeMethod(
        "setSamplePaths", samplePaths.toList());
    print(result);
  }
}

enum Event { beatStarted }

abstract class _Action<T> {
  final AudioService _audioService;
  final Future<void> Function(T value) _setPreference;
  final ValueNotifier<T> _valueNotifier;

  _Action(this._audioService, this._setPreference, this._valueNotifier);

  T get value => _valueNotifier.value;
  ValueNotifier<T> get valueNotifier => _valueNotifier;

  Future<void> set(T value,
      {bool? flag, bool isMetronomeInitialization = false}) async {
    _valueNotifier.value = value;
    await _invokeMethodChannel(value, isMetronomeInitialization);
    _setPreference.call(value);
  }

  Future<void> _invokeMethodChannel(
      T value, bool isMetronomeInitialization) async {
    final result = await _audioService._methodChannel.invokeMethod(
        "set${runtimeType.toString()}",
        [_getString(value), isMetronomeInitialization.toString()]);
    print(result);
  }

  String _getString(T value) => value.toString();
}

class AppVolume extends _Action<double> {
  AppVolume(super._audioService, super._setPreference, super.valueNotifier);
}

class BeatUnit extends _Action<fraction.BeatUnit> {
  BeatUnit(super.audioService, super._setPreference, super.valueNotifier);

  @override
  String _getString(fraction.BeatUnit value) => value.toJsonString();
}

class BeatVolume extends _Action<double> {
  BeatVolume(super.audioService, super._setPreference, super.valueNotifier);
}

class Bpm extends _Action<int> {
  Bpm(super._audioService, super._setPreference, super._valueNotifier);

  @override
  Future<void> set(int value,
      {flag = true, bool isMetronomeInitialization = false}) async {
    late int bpm;

    if (value < 1) {
      bpm = 1;
    } else if (value > 999) {
      bpm = 999;
    } else {
      bpm = value;
    }

    if (flag! && bpm == _valueNotifier.value) {
      return;
    }

    _valueNotifier.value = bpm;

    if (!isMetronomeInitialization) await HapticFeedback.lightImpact();
    super._invokeMethodChannel(bpm, isMetronomeInitialization);

    super._setPreference(bpm);
  }
}

class DownbeatVolume extends _Action<double> {
  DownbeatVolume(super.audioService, super._setPreference, super.valueNotifier);
}

class SampleSet extends _Action<sample_set.SampleSet> {
  SampleSet(super.audioService, super._setPreference, super.valueNotifier);

  @override
  String _getString(sample_set.SampleSet value) => value.getPathsAsJsonString();
}

class Subdivisions extends _Action<Map<Key, SubdivisionData>> {
  Subdivisions(super.audioService, super._setPreference, super.valueNotifier);

  @override
  String _getString(Map<Key, SubdivisionData> value) => value.toJsonString();
}

class TimeSignature extends _Action<fraction.TimeSignature> {
  TimeSignature(super.audioService, super._setPreference, super.valueNotifier);

  @override
  String _getString(fraction.TimeSignature value) => value.toJsonString();

  @override
  Future<void> set(fraction.TimeSignature value,
      {bool? flag, bool isMetronomeInitialization = false}) async {
    _valueNotifier.value = value;

    if (_audioService._preferenceService.autoUpdateBeatUnit &&
        !isMetronomeInitialization) {
      await _audioService.beatUnit.set(value.defaultBeatUnit());
    }

    super._invokeMethodChannel(value, isMetronomeInitialization);

    _setPreference(value);
  }
}
