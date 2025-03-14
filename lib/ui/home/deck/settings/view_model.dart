import 'package:flutter/material.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/domain/models/sample_set.dart';

class SettingsViewModel extends ChangeNotifier {
  final AssetService _assetService;
  final AudioService _audioService;
  final PreferenceService _preferenceService;
  final PurchaseService _purchaseService;
  final ThemeService _themeService;

  SettingsViewModel(this._assetService, this._audioService,
      this._preferenceService, this._purchaseService, this._themeService) {
    _assetService.sampleSetsValueNotifier.addListener(notifyListeners);
    _audioService.appVolumeValueNotifier.addListener(notifyListeners);
    _audioService.sampleSetValueNotifier.addListener(notifyListeners);
    _preferenceService.autoUpdateBeatUnitValueNotifier
        .addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  List<SampleSet> get sampleSets => _assetService.sampleSets;
  double get appVolume => _audioService.appVolume;
  bool get autoUpdateBeatUnit => _preferenceService.autoUpdateBeatUnit;
  SampleSet get sampleSet => _audioService.sampleSet;
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
        Preference.beatVolume.defaultValue,
        Preference.downbeatVolume.defaultValue,
        Preference.sampleSet.defaultValue,
        Preference.subdivisions.defaultValue,
        Preference.timeSignature.defaultValue);
  }

  Future<void> resetMetronome() async {
    await _audioService.setState(
        _audioService.appVolume,
        Preference.bpm.defaultValue,
        Preference.beatUnit.defaultValue,
        Preference.beatVolume.defaultValue,
        Preference.downbeatVolume.defaultValue,
        sampleSet,
        Preference.subdivisions.defaultValue,
        Preference.timeSignature.defaultValue);
  }

  Future<PurchaseResult> restorePremium() async =>
      await _purchaseService.restorePremium();

  Future<void> setAppVolume(double volume) async =>
      await _audioService.setAppVolume(volume);

  Future<void> setAutoUpdateBeatUnit(bool value) async =>
      await _preferenceService.setAutoUpdateBeatUnit(value);

  Future<void> setSampleSet(SampleSet sampleSet) async =>
      await _audioService.setSampleSet(sampleSet);

  Future<void> setThemeMode(ThemeMode themeMode) async =>
      await _preferenceService.setThemeMode(themeMode);
}
