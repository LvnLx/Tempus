import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tempus/domain/models/sample_pair.dart';

class AssetService {
  late final ValueNotifier<List<SampleSet>> _sampleSetsValueNotifier;

  Future<void> init() async {
    AssetManifest assetManifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    _sampleSetsValueNotifier = ValueNotifier([
      ..._getSampleSets(assetManifest, false),
      ..._getSampleSets(assetManifest, true)
    ]);
  }

  List<SampleSet> get sampleSets => _sampleSetsValueNotifier.value;
  ValueNotifier<List<SampleSet>> get sampleSetsValueNotifier =>
      _sampleSetsValueNotifier;

  List<SampleSet> _getSampleSets(
          AssetManifest assetManifest, bool isPremiumPath) =>
      assetManifest
          .listAssets()
          .where((string) =>
              string.startsWith("assets/audio/${isPremiumPath ? "premium" : "free"}/"))
          .fold<Set<String>>(
              {}, (accumulator, path) => {...accumulator, path.split("/")[3]})
          .map((sampleSetName) => SampleSet(sampleSetName, isPremiumPath))
          .toList();
}
