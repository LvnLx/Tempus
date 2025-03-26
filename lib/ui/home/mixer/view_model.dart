import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart' hide BeatUnit;
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/ui/home/mixer/channel.dart';

class MixerViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  int _count = 1;

  MixerViewModel(this._audioService, this._purchaseService) {
    _audioService.beatVolume.valueNotifier.addListener(notifyListeners);
    _audioService.downbeatVolume.valueNotifier.addListener(notifyListeners);
    _audioService.subdivisions.valueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);

    _audioService.playback.valueNotifier.addListener(() {
      _count = 1;
      notifyListeners();
    });

    _audioService.eventStream.listen((event) {
      if (event is Beat) {
        _count = event.count;
        notifyListeners();
      }
    });
  }

  ValueNotifier<double> get beatVolumeValueNotifier =>
      _audioService.beatVolume.valueNotifier;
  int get count => _count;
  ValueNotifier<double> get downbeatVolumeValueNotifier =>
      _audioService.downbeatVolume.valueNotifier;
  bool get isPremium => _purchaseService.isPremium;
  bool get playback => _audioService.playback.value;
  Map<Key, SubdivisionData> get subdivisions =>
      _audioService.subdivisions.value;

  Future<void> addSubdivision() async => await _audioService.subdivisions.set({
        ...subdivisions,
        UniqueKey():
            SubdivisionData(option: Options.subdivisionOptions[0], volume: 0.0)
      });

  Future<void> removeSubdivision(Key key) async =>
      await _audioService.subdivisions.set({...subdivisions}..remove(key));

  Future<void> setBeatVolume(double volume) async =>
      await _audioService.beatVolume.set(volume);

  Future<void> setDownbeatVolume(double volume) async =>
      await _audioService.downbeatVolume.set(volume);

  Future<void> setSubdivisionOption(Key key, int option) async =>
      await _audioService.subdivisions.set({...subdivisions}..update(
          key,
          (subdivisionData) =>
              SubdivisionData(option: option, volume: subdivisionData.volume)));

  Future<void> setSubdivisionVolume(Key key, double volume) async =>
      await _audioService.subdivisions.set({...subdivisions}..update(
          key,
          (subdivisionData) =>
              SubdivisionData(option: subdivisionData.option, volume: volume)));

  Future<PurchaseResult> purchasePremium() async =>
      await _purchaseService.purchasePremium();
}
