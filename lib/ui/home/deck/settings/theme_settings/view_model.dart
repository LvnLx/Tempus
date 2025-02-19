import 'package:flutter/material.dart';
import 'package:tempus/data/services/theme_service.dart';

class ThemeSettingsViewModel extends ChangeNotifier {
  final ThemeService _themeService;

  ThemeSettingsViewModel(this._themeService) {
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  ThemeMode get themeMode => _themeService.themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeService.setThemeMode(themeMode);
  }
}
