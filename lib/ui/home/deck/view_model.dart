import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart' hide TimeSignature;
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/fraction.dart';

class DeckViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  bool _playback = false;

  DeckViewModel(this._audioService, this._purchaseService) {
    _audioService.bpm.valueNotifier.addListener(notifyListeners);
    _audioService.timeSignature.valueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  Future<void> init() async {
    await _audioService.stopPlayback();
  }

  int get bpm => _audioService.bpm.value;
  TimeSignature get timeSignature => _audioService.timeSignature.value;
  bool get isPremium => _purchaseService.isPremium;
  bool get playback => _playback;

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.bpm.set(bpm, flag: skipUnchanged);

  Future<void> setTimeSignature(TimeSignature timeSignature) async =>
      await _audioService.timeSignature.set(timeSignature);

  Future<void> togglePlayback() async {
    _playback
        ? await _audioService.stopPlayback()
        : await _audioService.startPlayback();
    _playback = !playback;

    notifyListeners();
  }
}
