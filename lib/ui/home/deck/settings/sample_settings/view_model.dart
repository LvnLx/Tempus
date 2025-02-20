import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/sample_pair.dart';

class SampleSettingsViewModel extends ChangeNotifier {
  final AssetService _assetService;
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  SampleSettingsViewModel(
      this._assetService, this._audioService, this._purchaseService) {
    _audioService.samplePairValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  SamplePair get samplePair => _audioService.samplePair;
  List<SamplePair> get samplePairs => _assetService.samplePairs;
  bool get isPremium => _purchaseService.isPremium;

  Future<void> setSamplePair(SamplePair samplePair) async {
    await _audioService.setSamplePair(samplePair);
  }
}
