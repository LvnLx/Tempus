import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';

class DeckViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  bool _playback = false;

  DeckViewModel(this._audioService, this._purchaseService) {
    _audioService.bpmValueNotifier.addListener(notifyListeners);
    _audioService.denominatorValueNotifier.addListener(notifyListeners);
    _audioService.numeratorValueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  Future<void> init() async {
    await _audioService.stopPlayback();
  }

  int get bpm => _audioService.bpm;
  int get denominator => _audioService.denominator;
  bool get isPremium => _purchaseService.isPremium;
  int get numerator => _audioService.numerator;
  bool get playback => _playback;

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.setBpm(bpm, skipUnchanged);

  Future<void> setDenominator(int value) async =>
      await _audioService.setDenominator(value);

  Future<void> setNumerator(int value) async =>
      await _audioService.setNumerator(value);

  Future<void> togglePlayback() async {
    _playback
        ? await _audioService.stopPlayback()
        : await _audioService.startPlayback();
    _playback = !playback;

    notifyListeners();
  }
}
