import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/device_service.dart';
import 'package:tempus/data/services/preference_service.dart' hide ThemeMode;
import 'package:tempus/data/services/theme_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final DeviceService _deviceService;
  final PreferenceService _preferenceService;
  final ThemeService _themeService;

  HomeViewModel(this._audioService, this._deviceService,
      this._preferenceService, this._themeService) {
    _deviceService.flashlightValueNotifier.addListener(notifyListeners);
    _preferenceService.beatHaptics.valueNotifier.addListener(notifyListeners);
    _preferenceService.downbeatHaptics.valueNotifier
        .addListener(notifyListeners);
    _preferenceService.innerBeatHaptics.valueNotifier
        .addListener(notifyListeners);
    _preferenceService.flashlight.valueNotifier.addListener(notifyListeners);

    _audioService.eventStream.listen((event) {
      switch (event) {
        case Beat():
          if (_preferenceService.beatHaptics.value) {
            HapticFeedback.mediumImpact();
          }

          if (_deviceService.flashlight &&
              _preferenceService.flashlight.value) {
            _deviceService.setFlashlight(true);
            Future.delayed(Duration(milliseconds: 25),
                () => _deviceService.setFlashlight(false));
          }
        case Downbeat():
          if (_preferenceService.downbeatHaptics.value) {
            HapticFeedback.heavyImpact();
          }
        case InnerBeat():
          if (_preferenceService.innerBeatHaptics.value) {
            HapticFeedback.lightImpact();
          }
      }
    });

    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  ThemeData get darkThemeData => _themeService.darkThemeData;
  ThemeData get lightThemeData => _themeService.lightThemeData;
  ThemeMode get themeMode => _themeService.themeMode;
}
