import 'package:flutter/material.dart';
import 'package:tempus/data/services/theme_service.dart';

class MainViewModel extends ChangeNotifier {
  final ThemeService _themeService;

  MainViewModel(this._themeService) {
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  ThemeData get darkThemeData => _themeService.darkThemeData;
  ThemeData get lightThemeData => _themeService.lightThemeData;
  ThemeMode get themeMode => _themeService.themeMode;
}
