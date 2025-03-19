import 'package:flutter/foundation.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

class ChannelViewModel extends ChangeNotifier {
  final AudioService _audioService;

  ChannelViewModel(this._audioService) {
    _audioService.subdivisionsValueNotifier.addListener(notifyListeners);
  }

  Future<void> setSubdivisionOption(Key key, int option) async =>
      await _audioService.setSubdivisions({...subdivisions}..update(
          key,
          (subdivisionData) =>
              SubdivisionData(option: option, volume: subdivisionData.volume)));

  Future<void> setSubdivisionVolume(Key key, double volume) async =>
      await _audioService.setSubdivisions({...subdivisions}..update(
          key,
          (subdivisionData) =>
              SubdivisionData(option: subdivisionData.option, volume: volume)));

  Map<Key, SubdivisionData> get subdivisions => _audioService.subdivisions;
}
