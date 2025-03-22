import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart';

class VisualizerViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final PreferenceService _preferenceService;

  bool _isVisible = false;

  VisualizerViewModel(this._audioService, this._preferenceService) {
    _audioService.eventStream.listen((event) {
      if (event == Event.beatStarted) {
        _isVisible = true;
        notifyListeners();

        Future.delayed(Duration(milliseconds: 100), () {
          _isVisible = false;
          notifyListeners();
        });
      }
    });

    _preferenceService.visualizer.valueNotifier.addListener(notifyListeners);
  }

  bool get isVisible => _isVisible;
  bool get isVisualizerEnabled => _preferenceService.visualizer.value;
}
