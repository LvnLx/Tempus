import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart'
    hide BeatUnit, TimeSignature;
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/tap_tempo_service.dart';
import 'package:tempus/domain/models/fraction.dart';

class ClockViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PurchaseService _purchaseService;
  final TapTempoService _tapTempoService;

  ClockViewModel(
      this._audioService, this._purchaseService, this._tapTempoService) {
    _audioService.beatUnit.valueNotifier.addListener(notifyListeners);
    _audioService.bpm.valueNotifier.addListener(notifyListeners);
    _purchaseService.isPremiumValueNotifier.addListener(notifyListeners);
    _tapTempoService.tapTimesValueNotifier.addListener(notifyListeners);
  }

  BeatUnit get beatUnit => _audioService.beatUnit.value;
  int get bpm => _audioService.bpm.value;
  bool get isPremium => _purchaseService.isPremium;
  Queue<int> get tapTimes => _tapTempoService.tapTimes;
  TimeSignature get timeSignature => _audioService.timeSignature.value;

  Future<void> setBeatUnit(BeatUnit beatUnit) async =>
      await _audioService.beatUnit.set(beatUnit);

  Future<void> setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.bpm.set(bpm, flag: skipUnchanged);

  Future<void> setTimeSignature(TimeSignature timeSignature) async =>
      await _audioService.timeSignature.set(timeSignature);
}
