import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart' hide ThemeMode;
import 'package:tempus/data/services/theme_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PreferenceService _preferenceService;
  final ThemeService _themeService;

  HomeViewModel(
      this._audioService, this._preferenceService, this._themeService) {
    _preferenceService.beatHaptics.valueNotifier.addListener(notifyListeners);

    _audioService.eventStream.listen((event) {
      if (areBeatHapticsEnabled && event == Event.beatStarted) {
        HapticFeedback.mediumImpact();
      }
    });

    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  bool get areBeatHapticsEnabled => _preferenceService.beatHaptics.value;
  ThemeData get darkThemeData => _themeService.darkThemeData;
  ThemeData get lightThemeData => _themeService.lightThemeData;
  ThemeMode get themeMode => _themeService.themeMode;
}
