import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/audio.dart';

enum Preference {
  bpm(true),
  downbeatSample(false),
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
  late String _subdivisionSampleName;
  late ThemeMode _themeMode;
  late double _volume;

  int getBpm() {
    return _bpm;
  }

  String getDownbeatSampleName() {
    return _downbeatSampleName;
  }

  String getSubdivisionSampleName() {
    return _subdivisionSampleName;
  }

  ThemeMode getThemeMode() {
    return _themeMode;
  }

  double getVolume() {
    return _volume;
  }

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
    _subdivisionSampleName = await _getOrElse<String>(
        Preference.subdivisionSample.name,
        sampleNames,
        sampleNames.last,
        (subdivisionSampleName) => subdivisionSampleName);
    _volume = await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
        Defaults.volume;

    notifyListeners();

    Audio.setSampleNames(sampleNames);
    Audio.setState(_bpm, _downbeatSampleName, _subdivisionSampleName, _volume);
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
}

class Defaults {
  static const int bpm = 120;
  static const ThemeMode themeMode = ThemeMode.system;
  static const double volume = 1.0;
}
