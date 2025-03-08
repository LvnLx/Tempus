import 'dart:convert';

class SampleSet {
  final String name;
  final bool isPremium;

  const SampleSet(this.name, this.isPremium);

  static SampleSet fromJsonString(String jsonString) {
    Map<String, dynamic> sampleSetAsJson = jsonDecode(jsonString);
    return SampleSet(sampleSetAsJson["name"], sampleSetAsJson["isPremium"]);
  }

  @override
  bool operator ==(Object other) {
    return other is SampleSet &&
        other.name == name &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode => Object.hash(name, isPremium);

  String getBeatSamplePath() =>
      "assets/audio/${isPremium ? "premium" : "free"}/$name/beat.wav";

  String getInnerBeatSamplePath() =>
      "assets/audio/${isPremium ? "premium" : "free"}/$name/inner_beat.wav";

  String toJsonString() => jsonEncode({"name": name, "isPremium": isPremium});
}
