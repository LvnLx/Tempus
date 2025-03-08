import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/domain/models/beat_unit.dart';

class BeatUnitButtonViewModel extends ChangeNotifier {
  final AudioService _audioService;

  BeatUnitButtonViewModel(this._audioService) {
    _audioService.beatUnitValueNotifier.addListener(notifyListeners);
  }

  BeatUnit get beatUnit => _audioService.beatUnitValueNotifier.value;
}
