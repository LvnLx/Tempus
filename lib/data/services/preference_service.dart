import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/domain/extensions/subdivisions.dart';
import 'package:tempus/domain/models/fraction.dart' as fraction;
import 'package:tempus/domain/models/sample_set.dart' as sample_set;
import 'package:tempus/domain/models/subdivision.dart';

class PreferenceService {
  final AssetService _assetService;
  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  late final AppVolume appVolume;
  late final AutoUpdateBeatUnit autoUpdateBeatUnit;
  late final BeatHaptics beatHaptics;
  late final BeatUnit beatUnit;
  late final BeatVolume beatVolume;
  late final Bpm bpm;
  late final DownbeatHaptics downbeatHaptics;
  late final DownbeatVolume downbeatVolume;
  late final InnerBeatHaptics innerBeatHaptics;
  late final Premium premium;
  late final SampleSet sampleSet;
  late final Subdivisions subdivisions;
  late final ThemeMode themeMode;
  late final TimeSignature timeSignature;

  PreferenceService(this._assetService) {
    appVolume = AppVolume(this, 1.0);
    autoUpdateBeatUnit = AutoUpdateBeatUnit(this, true);
    beatHaptics = BeatHaptics(this, false);
    beatUnit = BeatUnit(this, fraction.BeatUnit(1, 4));
    beatVolume = BeatVolume(this, 1.0);
    bpm = Bpm(this, 120);
    downbeatHaptics = DownbeatHaptics(this, false);
    downbeatVolume = DownbeatVolume(this, 1.0);
    innerBeatHaptics = InnerBeatHaptics(this, false);
    premium = Premium(this, false);
    sampleSet = SampleSet(this, sample_set.SampleSet("sine", false));
    subdivisions = Subdivisions(this, {});
    themeMode = ThemeMode(this, material.ThemeMode.system);
    timeSignature = TimeSignature(this, fraction.TimeSignature(4, 4));
  }

  Future<void> init() async {
    await _ServiceOwned.initInstances();
  }
}

abstract class _Preference<T> {
  final T defaultValue;

  final PreferenceService _service;

  late final String _name;

  _Preference(this._service, this.defaultValue) {
    _name = runtimeType.toString();
  }

  /// Use `.value` instead, unless you are accessing the value in the `.init()`
  /// method of another service
  Future<T> get() async {
    try {
      return await _unsafeGet();
    } catch (exception) {
      print("Exception while getting $_name preference: $exception");
      await set(defaultValue);
      return defaultValue;
    }
  }

  Future<void> set(T value) async => await _rawSet(value);

  Future<void> _rawSet(T value) async {
    switch (T) {
      case const (bool):
        await _service._sharedPreferencesAsync.setBool(_name, value as bool);
      case const (double):
        await _service._sharedPreferencesAsync
            .setDouble(_name, value as double);
      case const (int):
        await _service._sharedPreferencesAsync.setInt(_name, value as int);
      default:
        throw UnimplementedError();
    }
  }

  Future<T> _unsafeGet() async {
    switch (T) {
      case const (bool):
        return (await _service._sharedPreferencesAsync.getBool(_name) ??
            defaultValue) as T;
      case const (double):
        return (await _service._sharedPreferencesAsync.getDouble(_name) ??
            defaultValue) as T;
      case const (int):
        return (await _service._sharedPreferencesAsync.getInt(_name) ??
            defaultValue) as T;
      default:
        throw UnimplementedError();
    }
  }
}

abstract class _ServiceOwned<T> extends _Preference<T> {
  static final List<_ServiceOwned> _instances = List.empty(growable: true);

  late final ValueNotifier<T> valueNotifier;

  _ServiceOwned(super.service, super.defaultValue) {
    _ServiceOwned._instances.add(this);
  }

  static Future<void> initInstances() async =>
      await Future.wait(_instances.map((instance) async =>
          instance.valueNotifier = ValueNotifier(await instance.get())));

  T get value => valueNotifier.value;

  @override
  Future<void> set(T value) async {
    await super.set(value);
    valueNotifier.value = value;
  }
}

class AppVolume extends _Preference<double> {
  AppVolume(super._service, super.defaultValue);
}

class AutoUpdateBeatUnit extends _ServiceOwned<bool> {
  AutoUpdateBeatUnit(super._service, super.defaultValue);
}

class BeatHaptics extends _ServiceOwned<bool> {
  BeatHaptics(super._service, super.defaultValue);
}

class BeatUnit extends _Preference<fraction.BeatUnit> {
  BeatUnit(super._service, super.defaultValue);

  @override
  Future<void> _rawSet(fraction.BeatUnit value) async =>
      await _service._sharedPreferencesAsync
          .setString(_name, value.toJsonString());

  @override
  Future<fraction.BeatUnit> _unsafeGet() async {
    String? beatUnitAsJsonString =
        await _service._sharedPreferencesAsync.getString(_name);

    if (beatUnitAsJsonString != null) {
      Map<String, dynamic> beatUnitAsJson = jsonDecode(beatUnitAsJsonString);
      return fraction.BeatUnit.fromJson(beatUnitAsJson);
    } else {
      return defaultValue;
    }
  }
}

class BeatVolume extends _Preference<double> {
  BeatVolume(super._service, super.defaultValue);
}

class Bpm extends _Preference<int> {
  Bpm(super._service, super.defaultValue);
}

class DownbeatHaptics extends _ServiceOwned<bool> {
  DownbeatHaptics(super._service, super.defaultValue);
}

class DownbeatVolume extends _Preference<double> {
  DownbeatVolume(super._service, super.defaultValue);
}

class InnerBeatHaptics extends _ServiceOwned<bool> {
  InnerBeatHaptics(super._service, super.defaultValue);
}

class Premium extends _Preference<bool> {
  Premium(super._service, super.defaultValue);
}

class SampleSet extends _Preference<sample_set.SampleSet> {
  SampleSet(super._service, super.defaultValue);

  @override
  Future<void> _rawSet(sample_set.SampleSet value) async =>
      await _service._sharedPreferencesAsync
          .setString(_name, value.toJsonString());

  @override
  Future<sample_set.SampleSet> _unsafeGet() async {
    String? sampleSetAsJsonString =
        await _service._sharedPreferencesAsync.getString(_name);

    if (sampleSetAsJsonString != null) {
      return _service._assetService.sampleSets.firstWhere((sampleSet) =>
          sampleSet ==
          sample_set.SampleSet.fromJsonString(sampleSetAsJsonString));
    } else {
      return defaultValue;
    }
  }
}

class Subdivisions extends _Preference<Map<Key, Subdivision>> {
  Subdivisions(super.service, super.defaultValue);

  @override
  Future<void> _rawSet(Map<Key, Subdivision> value) async =>
      await _service._sharedPreferencesAsync
          .setString(_name, value.toJsonString());

  @override
  Future<Map<Key, Subdivision>> _unsafeGet() async {
    String? subdivisionsAsJsonString =
        await _service._sharedPreferencesAsync.getString(_name);

    if (subdivisionsAsJsonString != null) {
      Map<String, dynamic> subdivisionsAsJson =
          jsonDecode(subdivisionsAsJsonString);
      return subdivisionsAsJson.map(
          (key, value) => MapEntry(Key(key), Subdivision.fromJson(value)));
    } else {
      return defaultValue;
    }
  }
}

class ThemeMode extends _Preference<material.ThemeMode> {
  ThemeMode(super.service, super.defaultValue);

  @override
  Future<void> _rawSet(material.ThemeMode value) async =>
      await _service._sharedPreferencesAsync.setString(_name, value.name);

  @override
  Future<material.ThemeMode> _unsafeGet() async {
    String? themeModeAsString =
        await _service._sharedPreferencesAsync.getString(_name);

    if (themeModeAsString != null) {
      return material.ThemeMode.values
          .firstWhere((themeMode) => themeMode.name == themeModeAsString);
    } else {
      return defaultValue;
    }
  }
}

class TimeSignature extends _Preference<fraction.TimeSignature> {
  TimeSignature(super.service, super.defaultValue);

  @override
  Future<void> _rawSet(fraction.TimeSignature value) async =>
      await _service._sharedPreferencesAsync
          .setString(_name, value.toJsonString());

  @override
  Future<fraction.TimeSignature> _unsafeGet() async {
    String? timeSignatureAsJsonString =
        await _service._sharedPreferencesAsync.getString(_name);
    if (timeSignatureAsJsonString != null) {
      Map<String, dynamic> timeSignatureAsJson =
          jsonDecode(timeSignatureAsJsonString);
      return fraction.TimeSignature.fromJson(timeSignatureAsJson);
    } else {
      return defaultValue;
    }
  }
}
