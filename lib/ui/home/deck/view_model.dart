import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';

class DeckViewModel extends ChangeNotifier {
  final AudioService _audioService;

  bool _playback = false;

  DeckViewModel(this._audioService) {
    _audioService.bpmValueNotifier.addListener(notifyListeners);
    _audioService.denominatorValueNotifier.addListener(notifyListeners);
    _audioService.numeratorValueNotifier.addListener(notifyListeners);
  }

  Future<void> init() async {
    await _audioService.stopPlayback();
  }

  int get bpm => _audioService.bpm;
  ValueNotifier<int> get denominatorValueNotifier =>
      _audioService.denominatorValueNotifier;
  ValueNotifier<int> get numeratorValueNotifier =>
      _audioService.numeratorValueNotifier;
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
