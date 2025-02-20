import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

class MixerViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  MixerViewModel(this._audioService, this._purchaseService) {
    _audioService.subdivisionsValueNotifier.addListener(notifyListeners);
    _audioService.volumeValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  bool get isPremium => _purchaseService.isPremium;
  Map<Key, SubdivisionData> get subdivisions => _audioService.subdivisions;
  double get volume => _audioService.volume;

  Future<void> addSubdivision() async => await _audioService.addSubdivision();

  Future<void> removeSubdivision(Key key) async =>
      await _audioService.removeSubdivision(key);

  Future<void> setVolume(double volume) async =>
      await _audioService.setVolume(volume);

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();
}
