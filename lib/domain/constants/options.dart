class Options {
  static final List<int> freeDenominators = [4, 8];
  static final List<int> freeNumerators = [1, 2, 3, 4, 5, 6, 9, 12];
  static final List<int> premiumDenominators =
      List.generate(99, (index) => index + 1);
  static final List<int> premiumNumerators =
      List.generate(99, (index) => index + 1);
  static final List<int> subdivisionOptions =
      List.generate(8, (index) => (index + 2));
}
