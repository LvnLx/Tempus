import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/audio.dart';

enum Preference { bpm, downbeatSample, subdivisionSample, themeMode, volume }

class AppState extends ChangeNotifier {
  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  int _bpm = 120;
  Sample _downbeatSample = Sample.downbeat;
  Sample _subdivisionSample = Sample.subdivision;
  ThemeMode _themeMode = ThemeMode.system;
  double _volume = 1.0;

  int getBpm() {
    return _bpm;
  }

  Sample getDownbeatSample() {
    return _downbeatSample;
  }

  Sample getSubdivisionSample() {
    return _subdivisionSample;
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

  Future<void> setDownbeatSample(Sample sample) async {
    if (!Sample.values.contains(sample)) {
      throw ArgumentError.value(sample);
    }

    _downbeatSample = sample;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.downbeatSample.name, sample.name);
  }

  Future<void> setSubdivisionSample(Sample sample) async {
    if (!Sample.values.contains(sample)) {
      throw ArgumentError.value(sample);
    }

    _subdivisionSample = sample;

    notifyListeners();

    await _sharedPreferencesAsync.setString(
        Preference.subdivisionSample.name, sample.name);
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
    _bpm = await _sharedPreferencesAsync.getInt(Preference.bpm.name) ?? _bpm;
    _themeMode = await _getOrElse<ThemeMode>(
        Preference.themeMode.name,
        ThemeMode.values,
        _themeMode.toString(),
        (themeMode) => themeMode.toString());
    _downbeatSample = await _getOrElse<Sample>(
        Preference.downbeatSample.name,
        Sample.values,
        _downbeatSample.name,
        (downbeatSample) => downbeatSample.name);
    _subdivisionSample = await _getOrElse<Sample>(
        Preference.subdivisionSample.name,
        Sample.values,
        _subdivisionSample.name,
        (subdivisionSample) => subdivisionSample.name);
    _volume = await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
        _volume;

    notifyListeners();

    Audio.setState(_bpm, _downbeatSample, _subdivisionSample, _volume);
  }

  Future<T> _getOrElse<T>(
    String key,
    List<T> possibleValues,
    String defaultValue,
    String Function(T) comparator,
  ) async {
    String value = await _sharedPreferencesAsync.getString(key) ?? defaultValue;
    return possibleValues.firstWhere((element) => comparator(element) == value);
  }
}
