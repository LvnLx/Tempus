import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AcquisitionResult { failed, succeeded }

class DeviceService {
  final MethodChannel _methodChannel = MethodChannel("device");

  late final ValueNotifier<bool> _flashlight;

  Future<void> init() async => _flashlight =
      ValueNotifier(await acquireFlashlight() == AcquisitionResult.succeeded);

  ValueNotifier<bool> get flashlightValueNotifier => _flashlight;
  bool get flashlight => _flashlight.value;

  Future<AcquisitionResult> acquireFlashlight() async {
    String result = await _methodChannel.invokeMethod("acquireFlashlight");
    print("Flashlight acquisition: $result");
    return AcquisitionResult.values.firstWhere(
        (acquisitionResult) => acquisitionResult.name == result.toLowerCase());
  }

  Future<void> setFlashlight(bool value) async {
    final result =
        await _methodChannel.invokeMethod("setFlashlight", [value.toString()]);
    print(result);
  }
}
