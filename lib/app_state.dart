import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/subdivision/subdivision.dart';

enum Preference {
  bpm(true),
  downbeatSample(false),
  subdivisions(true),
  subdivisionSample(false),
  themeMode(false),
  volume(true);

  final bool isMetronomeSetting;
  const Preference(this.isMetronomeSetting);
}

class AppState extends ChangeNotifier {
  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  late int _bpm;
  late String _downbeatSampleName;
  late Map<Key, SubdivisionData> _subdivisions;
  late String _subdivisionSampleName;
  late ThemeMode _themeMode;
  late double _volume;

  int getBpm() => _bpm;

  String getDownbeatSampleName() => _downbeatSampleName;

  Map<Key, SubdivisionData> getSubdivisions() => _subdivisions;

  String getSubdivisionSampleName() => _subdivisionSampleName;

  ThemeMode getThemeMode() => _themeMode;

  double getVolume() => _volume;

  Future<void> setBpm(int bpm) async {
    int validatedBpm = bpm > 0 ? bpm : 1;

    _bpm = validatedBpm;

    notifyListeners();

    await _sharedPreferencesAsync.setInt(Preference.bpm.name, validatedBpm);
  }

  Future<void> setDownbeatSampleName(String sampleName) async {
    if (!sampleNames.contains(sampleName)) {
      throw ArgumentError.value(sampleName);
    }

    _downbeatSampleName = sampleName;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.downbeatSample.name, sampleName);
  }

  Future<void> setSubdivisions(Map<Key, SubdivisionData> subdivisions) async {
    _subdivisions = subdivisions;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.subdivisions.name, _getJsonEncodedSubdivisions());
  }

  Future<void> setSubdivisionSampleName(String sampleName) async {
    if (!sampleNames.contains(sampleName)) {
      throw ArgumentError.value(sampleName);
    }

    _subdivisionSampleName = sampleName;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.subdivisionSample.name, sampleName);
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
    sampleNames = assetManifest
        .listAssets()
        .where((string) => string.startsWith("audio/"))
        .map((string) => string.split("/").last.split(".").first)
        .toSet();

    _bpm = await _sharedPreferencesAsync.getInt(Preference.bpm.name) ??
        Defaults.bpm;
    _themeMode = await _getOrElse<ThemeMode>(
        Preference.themeMode.name,
        ThemeMode.values,
        Defaults.themeMode.toString(),
        (themeMode) => themeMode.toString());
    _downbeatSampleName = await _getOrElse<String>(
        Preference.downbeatSample.name,
        sampleNames,
        sampleNames.first,
        (downbeatSampleName) => downbeatSampleName);
    _subdivisions = await _getSubdivisions() ?? {};
    _subdivisionSampleName = await _getOrElse<String>(
        Preference.subdivisionSample.name,
        sampleNames,
        sampleNames.last,
        (subdivisionSampleName) => subdivisionSampleName);
    _volume = await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
        Defaults.volume;

    notifyListeners();

    print(_getJsonEncodedSubdivisions());

    Audio.setSampleNames(sampleNames);
    Audio.setState(_bpm, _downbeatSampleName, _subdivisionSampleName,
        _getJsonEncodedSubdivisions(), _volume);
  }

  Future<void> resetMetronome() async {
    _sharedPreferencesAsync.clear(
        allowList: Set.from(Preference.values
            .where((preference) => preference.isMetronomeSetting)
            .map((preference) => preference.name)));
    await loadPreferences();
  }

  Future<void> resetApp() async {
    _sharedPreferencesAsync.clear();
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
  static const ThemeMode themeMode = ThemeMode.system;
  static const double volume = 1.0;
  static int subdivisionOption = subdivisionOptions[0];
  static const subdivisionVolume = 0.0;
}
