import 'package:flutter/material.dart';
import 'package:tempus/data/services/preference_service.dart';

class ThemeService extends ChangeNotifier {
  final PreferenceService _preferenceService;

  final ThemeData _darkThemeData = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.white,
          onPrimary: Color.fromRGBO(31, 31, 31, 1.0),
          secondary: Color.fromRGBO(112, 112, 112, 1.0),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Color.fromRGBO(31, 31, 31, 1.0),
          onSurface: Color.fromRGBO(64, 64, 64, 1.0)));
  final ThemeData _lightThemeData = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromRGBO(31, 31, 31, 1.0),
          onPrimary: Colors.white,
          secondary: Color.fromRGBO(147, 147, 147, 1.0),
          onSecondary: Color.fromRGBO(31, 31, 31, 1.0),
          error: Colors.red,
          onError: Color.fromRGBO(31, 31, 31, 1.0),
          surface: Colors.white,
          onSurface: Color.fromRGBO(211, 211, 211, 1.0)));

  late ThemeMode _themeMode;

  ThemeService(this._preferenceService);

  Future<void> init() async {
    _themeMode = await _preferenceService.getThemeMode();
  }

  ThemeData get darkThemeData => _darkThemeData;
  ThemeData get lightThemeData => _lightThemeData;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _preferenceService.setThemeMode(themeMode);

    notifyListeners();
  }
}
