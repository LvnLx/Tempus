import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart'
    hide TimeSignature, BeatUnit;
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/domain/models/fraction.dart';

class DeckViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;

  DeckViewModel(this._audioService, this._purchaseService) {
    _audioService.beatUnit.valueNotifier.addListener(notifyListeners);
    _audioService.bpm.valueNotifier.addListener(notifyListeners);
    _audioService.playback.valueNotifier.addListener(notifyListeners);
    _audioService.timeSignature.valueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
  }

  Future<void> init() async {
    await _audioService.playback.set(false);
  }

  BeatUnit get beatUnit => _audioService.beatUnit.value;
  int get bpm => _audioService.bpm.value;
  TimeSignature get timeSignature => _audioService.timeSignature.value;
  bool get isPremium => _purchaseService.isPremium;
  bool get playback => _audioService.playback.value;

  Future<void> setBeatUnit(BeatUnit beatUnit) async =>
      await _audioService.beatUnit.set(beatUnit);

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.bpm.set(bpm, flag: skipUnchanged);

  Future<void> setTimeSignature(TimeSignature timeSignature) async =>
      await _audioService.timeSignature.set(timeSignature);

  Future<void> togglePlayback() async {
    playback
        ? await _audioService.playback.set(false)
        : await _audioService.playback.set(true);

    notifyListeners();
  }
}
