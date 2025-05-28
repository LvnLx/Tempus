import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/tap_tempo_service.dart';

class DeckViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final TapTempoService _tapTempoService;

  DeckViewModel(this._audioService, this._tapTempoService) {
    _audioService.bpm.valueNotifier.addListener(notifyListeners);
    _audioService.playback.valueNotifier.addListener(notifyListeners);
  }

  Future<void> init() async {
    await _audioService.playback.set(false);
  }

  int get bpm => _audioService.bpm.value;
  bool get playback => _audioService.playback.value;

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.bpm.set(bpm, flag: skipUnchanged);

  void tapTempo() => _tapTempoService.tapTempo();

  Future<void> togglePlayback() async {
    playback
        ? await _audioService.playback.set(false)
        : await _audioService.playback.set(true);

    notifyListeners();
  }
}
