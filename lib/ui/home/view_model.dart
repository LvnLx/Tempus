import 'package:flutter/material.dart';
import 'package:tempus/data/services/theme_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ThemeService _themeService;

  HomeViewModel(this._themeService) {
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  ThemeData get darkThemeData => _themeService.darkThemeData;
  ThemeData get lightThemeData => _themeService.lightThemeData;
  ThemeMode get themeMode => _themeService.themeMode;
}
