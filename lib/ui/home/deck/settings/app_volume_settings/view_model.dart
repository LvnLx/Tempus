import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';

class AppVolumeSettingsViewModel extends ChangeNotifier {
  final AudioService _audioService;

  AppVolumeSettingsViewModel(this._audioService) {
    _audioService.appVolumeValueNotifier.addListener(notifyListeners);
  }

  double get appVolume => _audioService.appVolume;

  Future<void> setAppVolume(double volume) async {
    await _audioService.setAppVolume(volume);
  }
}