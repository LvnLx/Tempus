import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final List<String> samples = ['downbeat', 'subdivision'];

  String? _downbeatSample = 'downbeat';
  String? _subdivisionSample = 'subdivision';
  ThemeMode? _themeMode;

  String getDownbeatSample() {
    return _downbeatSample!;
  }

  String getSubdivisionSample() {
    return _subdivisionSample!;
  }

  ThemeMode getThemeMode() {
    return _themeMode!;
  }

  Future<void> setDownbeatSample(String downbeatSample) async {
    if (!samples.contains(downbeatSample)) {
      throw ArgumentError.value(downbeatSample);
    }

    _downbeatSample = downbeatSample;

    notifyListeners();

    SharedPreferencesAsync sharedPreferencesAsync = SharedPreferencesAsync();
    await sharedPreferencesAsync.setString('downbeatSample', downbeatSample);
  }

  Future<void> setSubdivisionSample(String subdivisionSample) async {
    if (!samples.contains(subdivisionSample)) {
      throw ArgumentError.value(subdivisionSample);
    }

    _subdivisionSample = subdivisionSample;

    notifyListeners();

    SharedPreferencesAsync sharedPreferencesAsync = SharedPreferencesAsync();
    await sharedPreferencesAsync.setString(
        'subdivisionSample', subdivisionSample);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    notifyListeners();

    SharedPreferencesAsync sharedPreferencesAsync = SharedPreferencesAsync();
    await sharedPreferencesAsync.setString('themeMode', themeMode.toString());
  }

  Future<void> loadPreferences() async {
    SharedPreferencesAsync sharedPreferencesAsync = SharedPreferencesAsync();
    String? themeModeString =
        await sharedPreferencesAsync.getString('themeMode');
    _themeMode = ThemeMode.values.firstWhere((element) =>
        element.toString() == (themeModeString ?? ThemeMode.system.toString()));

    notifyListeners();
  }
}
