import 'dart:convert';

class SamplePair {
  final String name;
  final bool isPremium;

  const SamplePair(this.name, this.isPremium);

  static SamplePair fromJsonString(String jsonString) {
    Map<String, dynamic> samplePairAsJson = jsonDecode(jsonString);
    return SamplePair(samplePairAsJson["name"], samplePairAsJson["isPremium"]);
  }

  @override
  bool operator ==(Object other) {
    return other is SamplePair &&
        other.name == name &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode => Object.hash(name, isPremium);

  String getDownbeatSamplePath() =>
      "audio/${isPremium ? "premium" : "free"}/$name/downbeat.wav";

  String getSubdivisionSamplePath() =>
      "audio/${isPremium ? "premium" : "free"}/$name/subdivision.wav";

  String toJsonString() => jsonEncode({"name": name, "isPremium": isPremium});
}
