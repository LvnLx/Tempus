import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/ui/mixer/subdivision.dart';

enum Preference {
  bpm(true, true),
  isPremium(false, false),
  samplePair(true, false),
  subdivisions(true, true),
  subdivisionSample(true, false),
  themeMode(true, false),
  volume(true, true);

  final bool isAppSetting;
  final bool isMetronomeSetting;
  const Preference(this.isAppSetting, this.isMetronomeSetting);
}

class SharedPreferencesService extends ChangeNotifier {
  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  late int _bpm;
  late bool _isPremium;
  late SamplePair _samplePair;
  late Map<Key, SubdivisionData> _subdivisions;
  late ThemeMode _themeMode;
  late double _volume;

  int getBpm() => _bpm;

  bool getIsPremium() => _isPremium;

  SamplePair getSamplePair() => _samplePair;

  Map<Key, SubdivisionData> getSubdivisions() => _subdivisions;

  ThemeMode getThemeMode() => _themeMode;

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
    await AudioService.setBpm(validatedBpm);
  }

  Future<void> setIsPremium(bool value) async {
    _isPremium = value;

    notifyListeners();

    await _sharedPreferencesAsync.setBool(Preference.isPremium.name, value);
  }

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

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.themeMode.name, themeMode.toString());
  }

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
          Defaults.bpm;
      _isPremium =
          await _sharedPreferencesAsync.getBool(Preference.isPremium.name) ??
              Defaults.isPremium;
      _themeMode = await _getOrElse<ThemeMode>(
          Preference.themeMode.name,
          ThemeMode.values,
          Defaults.themeMode.toString(),
          (themeMode) => themeMode.toString());
      _samplePair = await _getOrElse<SamplePair>(
          Preference.samplePair.name,
          samplePairs,
          Defaults.samplePair.name,
          (samplePair) => samplePair.name);
      _subdivisions = await _getSubdivisions() ?? {};
      _volume =
          await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
              Defaults.volume;
    } catch (_) {
      await resetApp();
    }

    notifyListeners();

    await AudioService.setSampleNames(samplePairs.fold<Set<String>>(
        {},
        (accumulator, samplePair) => {
              ...accumulator,
              samplePair.downbeatSample,
              samplePair.subdivisionSample
            }));
    await AudioService.setState(_bpm, _samplePair.downbeatSample,
        _samplePair.subdivisionSample, _getJsonEncodedSubdivisions(), _volume);
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
  static const int bpm = 120;
  static const bool isPremium = false;
  static SamplePair samplePair = SamplePair("sine", false);
  static const ThemeMode themeMode = ThemeMode.system;
  static const double volume = 1.0;
  static int subdivisionOption = subdivisionOptions[0];
  static const subdivisionVolume = 0.0;
}
