import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/domain/models/sample_pair.dart';
import 'package:tempus/ui/mixer/channel/view.dart';

enum Preference {
  bpm(120, true, true),
  isPremium(false, false, false),
  samplePair(SamplePair("sine", false), true, false),
  subdivisions({}, true, true),
  themeMode(ThemeMode.system, true, false),
  volume(1.0, true, true);

  final dynamic defaultValue;
  final bool isAppSetting;
  final bool isMetronomeSetting;
  const Preference(
      this.defaultValue, this.isAppSetting, this.isMetronomeSetting);
}

class PreferenceService extends ChangeNotifier {
  final AudioService _audioService;

  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  late int _bpm;
  late SamplePair _samplePair;
  late Map<Key, SubdivisionData> _subdivisions;
  late double _volume;

  PreferenceService(this._audioService);

  int getBpm() => _bpm;

  Future<bool> getIsPremium() async =>
      await _sharedPreferencesAsync.getBool(Preference.isPremium.name) ??
      Preference.isPremium.defaultValue;

  SamplePair getSamplePair() => _samplePair;

  Map<Key, SubdivisionData> getSubdivisions() => _subdivisions;

  Future<ThemeMode> getThemeMode() async => await _getOrElse<ThemeMode>(
      Preference.themeMode.name,
      ThemeMode.values,
      Preference.themeMode.defaultValue.toString(),
      (themeMode) => themeMode.toString());

  double getVolume() => _volume;

  Future<void> setBpm(int bpm, {bool skipUnchanged = true}) async {
    late int validatedBpm;

    if (bpm < 1) {
      validatedBpm = 1;
    } else if (bpm > 999) {
      validatedBpm = 999;
    } else {
      validatedBpm = bpm;
    }

    if (skipUnchanged && validatedBpm == _bpm) {
      return;
    } else {
      _bpm = validatedBpm;
    }

    notifyListeners();

    await _sharedPreferencesAsync.setInt(Preference.bpm.name, validatedBpm);
    await _audioService.setBpm(validatedBpm);
  }

  Future<void> setIsPremium(bool value) async =>
      await _sharedPreferencesAsync.setBool(Preference.isPremium.name, value);

  Future<void> setSamplePair(SamplePair samplePair) async {
    if (!samplePairs.contains(samplePair)) {
      throw ArgumentError.value(samplePair);
    }

    _samplePair = samplePair;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.samplePair.name, samplePair.name);
  }

  Future<void> setSubdivisions(Map<Key, SubdivisionData> subdivisions) async {
    _subdivisions = subdivisions;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.subdivisions.name, _getJsonEncodedSubdivisions());
  }

  Future<void> setThemeMode(ThemeMode themeMode) async =>
      await _sharedPreferencesAsync.setString(
          Preference.themeMode.name, themeMode.toString());

  Future<void> setVolume(double volume) async {
    _volume = volume;

    notifyListeners();

    await _sharedPreferencesAsync.setDouble(Preference.volume.name, volume);
  }

  Future<void> loadPreferences() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    samplePairs = [
      ...getSamplePairs(assetManifest, false),
      ...getSamplePairs(assetManifest, true)
    ];

    try {
      _bpm = await _sharedPreferencesAsync.getInt(Preference.bpm.name) ??
          Preference.bpm.defaultValue;
      _samplePair = await _getOrElse<SamplePair>(
          Preference.samplePair.name,
          samplePairs,
          Preference.samplePair.defaultValue.name,
          (samplePair) => samplePair.name);
      _subdivisions = await _getSubdivisions() ?? {};
      _volume =
          await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
              Preference.volume.defaultValue;
    } catch (_) {
      await resetApp();
    }

    notifyListeners();

    await _audioService.setSampleNames(samplePairs.fold<Set<String>>(
        {},
        (accumulator, samplePair) => {
              ...accumulator,
              samplePair.getDownbeatSamplePath(),
              samplePair.getSubdivisionSamplePath()
            }));
    await _audioService.setState(
        _bpm,
        _samplePair.getDownbeatSamplePath(),
        _samplePair.getSubdivisionSamplePath(),
        _getJsonEncodedSubdivisions(),
        _volume);
  }

  List<SamplePair> getSamplePairs(
          AssetManifest assetManifest, bool isPremiumPath) =>
      assetManifest
          .listAssets()
          .where((string) =>
              string.startsWith("audio/${isPremiumPath ? "premium" : "free"}/"))
          .fold<Set<String>>(
              {}, (accumulator, path) => {...accumulator, path.split("/")[2]})
          .map((samplePairName) => SamplePair(samplePairName, isPremiumPath))
          .toList();

  Future<void> resetMetronome() async {
    _sharedPreferencesAsync.clear(
        allowList: Set.from(Preference.values
            .where((preference) => preference.isMetronomeSetting)
            .map((preference) => preference.name)));
    await loadPreferences();
  }

  Future<void> resetApp() async {
    _sharedPreferencesAsync.clear(
        allowList: Set.from(Preference.values
            .where((preference) => preference.isAppSetting)
            .map((preference) => preference.name)));
    await loadPreferences();
  }

  Future<T> _getOrElse<T>(
    String key,
    Iterable<T> possibleValues,
    String defaultValue,
    String Function(T) comparator,
  ) async {
    String value = await _sharedPreferencesAsync.getString(key) ?? defaultValue;
    return possibleValues.firstWhere((element) => comparator(element) == value);
  }

  Future<Map<Key, SubdivisionData>?> _getSubdivisions() async {
    String? subdivisionsAsJsonString =
        await _sharedPreferencesAsync.getString(Preference.subdivisions.name);

    if (subdivisionsAsJsonString == null) return null;

    Map<String, dynamic> subdivisionsAsJson =
        jsonDecode(subdivisionsAsJsonString);
    return subdivisionsAsJson.map(
        (key, value) => MapEntry(Key(key), SubdivisionData.fromJson(value)));
  }

  String _getJsonEncodedSubdivisions() => jsonEncode(_subdivisions
      .map((key, value) => MapEntry(key.toString(), value.toJson())));
}

class Defaults {
  static int subdivisionOption = subdivisionOptions[0];
  static const subdivisionVolume = 0.0;
}
