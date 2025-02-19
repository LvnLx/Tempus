import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tempus/domain/models/sample_pair.dart';

class AssetService {
  late final ValueNotifier<List<SamplePair>> _samplePairsValueNotifier;

  Future<void> init() async {
    AssetManifest assetManifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    _samplePairsValueNotifier = ValueNotifier([
      ..._getSamplePairs(assetManifest, false),
      ..._getSamplePairs(assetManifest, true)
    ]);
  }

  List<SamplePair> get samplePairs => _samplePairsValueNotifier.value;
  ValueNotifier<List<SamplePair>> get samplePairsValueNotifier =>
      _samplePairsValueNotifier;

  List<SamplePair> _getSamplePairs(
          AssetManifest assetManifest, bool isPremiumPath) =>
      assetManifest
          .listAssets()
          .where((string) =>
              string.startsWith("audio/${isPremiumPath ? "premium" : "free"}/"))
          .fold<Set<String>>(
              {}, (accumulator, path) => {...accumulator, path.split("/")[2]})
          .map((samplePairName) => SamplePair(samplePairName, isPremiumPath))
          .toList();
}
