class SamplePair {
  String name;
  bool isPremium;

  late String downbeatSample;
  late String subdivisionSample;

  SamplePair(this.name, this.isPremium) {
    downbeatSample =
        "audio/${isPremium ? "premium" : "free"}/$name/downbeat.wav";
    subdivisionSample =
        "audio/${isPremium ? "premium" : "free"}/$name/subdivision.wav";
  }
}
