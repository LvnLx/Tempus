import 'package:flutter/material.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart' hide SampleSet;
import 'package:tempus/data/services/preference_service.dart'
    hide SampleSet, ThemeMode;
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
    _audioService.appVolume.valueNotifier.addListener(notifyListeners);
    _audioService.sampleSet.valueNotifier.addListener(notifyListeners);
    _preferenceService.autoUpdateBeatUnit.valueNotifier
        .addListener(notifyListeners);
    _preferenceService.beatHaptics.valueNotifier.addListener(notifyListeners);
    _preferenceService.downbeatHaptics.valueNotifier.addListener(notifyListeners);
    _preferenceService.innerBeatHaptics.valueNotifier.addListener(notifyListeners);
    _preferenceService.visualizer.valueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
    _themeService.themeModeValueNotifier.addListener(notifyListeners);
  }

  double get appVolume => _audioService.appVolume.value;
  bool get autoUpdateBeatUnit => _preferenceService.autoUpdateBeatUnit.value;
  bool get beatHaptics => _preferenceService.beatHaptics.value;
  bool get downbeatHaptics => _preferenceService.downbeatHaptics.value;
  bool get innerBeatHaptics => _preferenceService.innerBeatHaptics.value;
  bool get isPremium => _purchaseService.isPremium;
  bool get isVisualizerEnabled => _preferenceService.visualizer.value;
  SampleSet get sampleSet => _audioService.sampleSet.value;
  List<SampleSet> get sampleSets => _assetService.sampleSets;
  ThemeMode get themeMode => _themeService.themeMode;

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();

  Future<void> resetApp() async {
    _preferenceService.beatHaptics
        .set(_preferenceService.beatHaptics.defaultValue);
    _preferenceService.autoUpdateBeatUnit
        .set(_preferenceService.autoUpdateBeatUnit.defaultValue);
    _preferenceService.visualizer
        .set(_preferenceService.visualizer.defaultValue);
    _themeService.setThemeMode(_preferenceService.themeMode.defaultValue);
    await _audioService.setState(
        _preferenceService.appVolume.defaultValue,
        _preferenceService.bpm.defaultValue,
        _preferenceService.beatUnit.defaultValue,
        _preferenceService.beatVolume.defaultValue,
        _preferenceService.downbeatVolume.defaultValue,
        _preferenceService.sampleSet.defaultValue,
        _preferenceService.subdivisions.defaultValue,
        _preferenceService.timeSignature.defaultValue);
  }

  Future<void> resetMetronome() async {
    await _audioService.setState(
        appVolume,
        _preferenceService.bpm.defaultValue,
        _preferenceService.beatUnit.defaultValue,
        _preferenceService.beatVolume.defaultValue,
        _preferenceService.downbeatVolume.defaultValue,
        sampleSet,
        _preferenceService.subdivisions.defaultValue,
        _preferenceService.timeSignature.defaultValue);
  }

  Future<PurchaseResult> restorePremium() async =>
      await _purchaseService.restorePremium();

  Future<void> setAppVolume(double volume) async =>
      await _audioService.appVolume.set(volume);

  Future<void> setAutoUpdateBeatUnit(bool value) async =>
      await _preferenceService.autoUpdateBeatUnit.set(value);

  Future<void> setBeatHaptics(bool value) async =>
      await _preferenceService.beatHaptics.set(value);

  Future<void> setDownbeatHaptics(bool value) async =>
      await _preferenceService.downbeatHaptics.set(value);

  Future<void> setInnerBeatHaptics(bool value) async =>
      await _preferenceService.innerBeatHaptics.set(value);

  Future<void> setIsVisualizerEnabled(bool value) async =>
      await _preferenceService.visualizer.set(value);

  Future<void> setSampleSet(SampleSet sampleSet) async =>
      await _audioService.sampleSet.set(sampleSet);

  void setThemeMode(ThemeMode themeMode) =>
      _themeService.setThemeMode(themeMode);
}
