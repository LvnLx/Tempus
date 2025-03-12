class Constants {
  static final List<int> freeDenominatorOptions = [4, 8];
  static final List<int> freeNumeratorOptions = [1, 2, 3, 4, 5, 6, 9, 12];
  static final List<int> premiumTimeSignatureOptions =
      List.generate(99, (index) => index + 1);
  static final List<int> subdivisionOptions =
      List.generate(8, (index) => (index + 2));

  static final String contactEmail = "contact@lvnlx.com";
  static final String feedbackEmail = "feedback@lvnlx.com";
  static final String supportEmail = "support@lvnlx.com";
}
