import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/beat_unit.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

class MixerViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  MixerViewModel(this._audioService, this._purchaseService) {
    _audioService.beatUnitValueNotifier.addListener(notifyListeners);
    _audioService.beatVolumeValueNotifier.addListener(notifyListeners);
    _audioService.downbeatVolumeValueNotifier.addListener(notifyListeners);
    _audioService.subdivisionsValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  BeatUnit get beatUnit => _audioService.beatUnit;
  ValueNotifier<double> get beatVolumeValueNotifier =>
      _audioService.beatVolumeValueNotifier;
  ValueNotifier<double> get downbeatVolumeValueNotifier =>
      _audioService.downbeatVolumeValueNotifier;
  bool get isPremium => _purchaseService.isPremium;
  Map<Key, SubdivisionData> get subdivisions => _audioService.subdivisions;

  Future<void> addSubdivision() async => await _audioService.addSubdivision();

  Future<void> removeSubdivision(Key key) async =>
      await _audioService.removeSubdivision(key);

  Future<void> setBeatVolume(double volume) async =>
      await _audioService.setBeatVolume(volume);

  Future<void> setDownbeatVolume(double volume) async =>
      await _audioService.setDownbeatVolume(volume);

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();
}
