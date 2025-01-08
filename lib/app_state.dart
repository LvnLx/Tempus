import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/audio.dart';

class AppState extends ChangeNotifier {
  final SharedPreferencesAsync sharedPreferencesAsync =
      SharedPreferencesAsync();

  Sample? _downbeatSample;
  Sample? _subdivisionSample;
  ThemeMode? _themeMode;

  Sample getDownbeatSample() {
    return _downbeatSample!;
  }

  Sample getSubdivisionSample() {
    return _subdivisionSample!;
  }

  ThemeMode getThemeMode() {
    return _themeMode!;
  }

  Future<void> setDownbeatSample(Sample sample) async {
    if (!Sample.values.contains(sample)) {
      throw ArgumentError.value(sample);
    }

    _downbeatSample = sample;

    notifyListeners();

    await sharedPreferencesAsync.setString(
        Preference.downbeatSample.name, sample.name);
  }

  Future<void> setSubdivisionSample(Sample sample) async {
    if (!Sample.values.contains(sample)) {
      throw ArgumentError.value(sample);
    }

    _subdivisionSample = sample;

    notifyListeners();

    await sharedPreferencesAsync.setString(
        Preference.subdivisionSample.name, sample.name);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    notifyListeners();

    await sharedPreferencesAsync.setString(
        Preference.themeMode.name, themeMode.toString());
  }

  Future<void> loadPreferences() async {
    _themeMode = await _getOrElse<ThemeMode>(
        Preference.themeMode.name,
        ThemeMode.values,
        ThemeMode.system.toString(),
        (themeMode) => themeMode.toString());
    _downbeatSample = await _getOrElse<Sample>(
        Preference.downbeatSample.name,
        Sample.values,
        Sample.downbeat.name,
        (downbeatSample) => downbeatSample.name);
    _subdivisionSample = await _getOrElse<Sample>(
        Preference.subdivisionSample.name,
        Sample.values,
        Sample.subdivision.name,
        (subdivisionSample) => subdivisionSample.name);

    notifyListeners();
  }

  Future<T> _getOrElse<T>(
    String key,
    List<T> possibleValues,
    String defaultValue,
    String Function(T) comparator,
  ) async {
    String value = await sharedPreferencesAsync.getString(key) ?? defaultValue;
    return possibleValues.firstWhere((element) => comparator(element) == value);
  }
}

enum Preference { downbeatSample, subdivisionSample, themeMode }
