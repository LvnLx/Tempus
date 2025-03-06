import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';

class VisualizerViewModel extends ChangeNotifier {
  final AudioService _audioService;

  bool _isVisible = false;

  VisualizerViewModel(this._audioService) {
    _audioService.eventStream.listen((event) {
      if (event == Event.beatStarted) {
        _isVisible = true;
        notifyListeners();

        Future.delayed(Duration(milliseconds: 34), () {
          _isVisible = false;
          notifyListeners();
        });
      }
    });
  }

  bool get isVisible => _isVisible;
}
