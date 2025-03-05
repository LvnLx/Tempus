import 'package:flutter/material.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/domain/models/sample_pair.dart';

class SettingsViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;
  final ThemeService _themeService;

  SettingsViewModel(
      this._audioService, this._purchaseService, this._themeService) {
    _audioService.appVolumeValueNotifier.addListener(notifyListeners);
    _audioService.samplePairValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  double get appVolume => _audioService.appVolume;
  SamplePair get samplePair => _audioService.samplePair;
  bool get isPremium => _purchaseService.isPremium;
  ThemeMode get themeMode => _themeService.themeMode;

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();

  Future<void> resetApp() async {
    _themeService.setThemeMode(Preference.themeMode.defaultValue);
    await _audioService.setState(
        Preference.appVolume.defaultValue,
        Preference.bpm.defaultValue,
        Preference.beatVolume.defaultValue,
        Preference.denominator.defaultValue,
        Preference.downbeatVolume.defaultValue,
        Preference.numerator.defaultValue,
        Preference.samplePair.defaultValue,
        Preference.subdivisions.defaultValue);
  }

  Future<void> resetMetronome() async {
    await _audioService.setState(
        _audioService.appVolume,
        Preference.bpm.defaultValue,
        Preference.beatVolume.defaultValue,
        Preference.denominator.defaultValue,
        Preference.downbeatVolume.defaultValue,
        Preference.numerator.defaultValue,
        samplePair,
        Preference.subdivisions.defaultValue);
  }

  Future<PurchaseResult> restorePremium() async =>
      await _purchaseService.restorePremium();
}
