import 'dart:async';
import 'dart:collection';

import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/domain/utils/queue_notifier.dart';

class TapTempoService {
  final AudioService _audioService;

  final int _maxTapTimeCount = 5;
  final QueueNotifier<int> _tapTimesValueNotifier = QueueNotifier();

  late Timer _lastTapTimer;

  TapTempoService(this._audioService);

  Queue<int> get tapTimes => _tapTimesValueNotifier.value;
  QueueNotifier<int> get tapTimesValueNotifier => _tapTimesValueNotifier;

  void addTapTime(int tapTime) {
    if (_tapTimesValueNotifier.value.length >= _maxTapTimeCount) {
      _tapTimesValueNotifier.removeFirst();
    }

    _tapTimesValueNotifier.addLast(tapTime);
  }

  void tapTempo() {
    if (_tapTimesValueNotifier.value.isEmpty) {
      addTapTime(DateTime.now().millisecondsSinceEpoch);
      _lastTapTimer =
          Timer(Duration(seconds: 3), () => _tapTimesValueNotifier.clear);
    } else {
      addTapTime(DateTime.now().millisecondsSinceEpoch);
      _setBpm(
          (1 / (_averageTapDeltaMilliseconds() / 1000) * 60).round(), false);
      _lastTapTimer.cancel();
      _lastTapTimer =
          Timer(Duration(seconds: 3), () => _tapTimesValueNotifier.clear);
    }
  }

  int _averageTapDeltaMilliseconds() {
    List<int> tapTimeDeltas = List.empty(growable: true);
    for (int i = 1; i < _tapTimesValueNotifier.value.length; i++) {
      tapTimeDeltas.add(_tapTimesValueNotifier.value.elementAt(i) -
          _tapTimesValueNotifier.value.elementAt(i - 1));
    }

    int sum = tapTimeDeltas.reduce((value, element) => value + element);
    return (sum / tapTimeDeltas.length).round();
  }

  Future<void> _setBpm(int bpm, [bool skipUnchanged = true]) async =>
      await _audioService.bpm.set(bpm, flag: skipUnchanged);
}
