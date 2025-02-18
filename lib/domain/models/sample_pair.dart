class SamplePair {
  final String name;
  final bool isPremium;

  const SamplePair(this.name, this.isPremium);

  String getDownbeatSamplePath() =>
      "audio/${isPremium ? "premium" : "free"}/$name/downbeat.wav";
  String getSubdivisionSamplePath() =>
      "audio/${isPremium ? "premium" : "free"}/$name/subdivision.wav";
}
