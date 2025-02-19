import 'package:flutter/material.dart';
import 'package:tempus/data/services/audio_service.dart';
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
    _audioService.samplePairValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  SamplePair get samplePair => _audioService.samplePair;
  bool get isPremium => _purchaseService.isPremium;
  ThemeMode get themeMode => _themeService.themeMode;

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();

  Future<void> resetApp() async {
    // Reset BPM
    // Reset sample pair
    // Reset subdivisions
    // Reset theme mode
    // Reset volume
  }

  Future<void> resetMetronome() async {
    // Reset BPM
    // Reset subdivisions
    // Reset volume
  }

  Future<PurchaseResult> restorePremium() async =>
      await _purchaseService.restorePremium();
}
