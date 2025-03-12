import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/sample_set.dart';

class SampleSettingsViewModel extends ChangeNotifier {
  final AssetService _assetService;
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  SampleSettingsViewModel(
      this._assetService, this._audioService, this._purchaseService) {
    _audioService.sampleSetValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  SampleSet get sampleSet => _audioService.sampleSet;
  List<SampleSet> get sampleSets => _assetService.sampleSets;
  bool get isPremium => _purchaseService.isPremium;

  Future<void> setSampleSets(SampleSet sampleSet) async {
    await _audioService.setSampleSet(sampleSet);
  }
}
