import 'dart:convert';

enum BeatUnit {
  whole(1, 1, "\u{1D15D}"),
  half(1, 2, "\u{1D15E}"),
  quarter(1, 4, "\u{1D15F}", false),
  eighth(1, 8, "\u{1D160}"),
  sixteenth(1, 16, "\u{1D161}"),
  thirtySecond(1, 32, "\u{1D162}"),
  sixtyFourth(1, 64, "\u{1D163}"),
  oneHundredTwentyEighthNote(1, 128, "\u{1D164}"),
  ;

  final int denominator;
  final bool isPremium;
  final int numerator;
  final String symbol;

  const BeatUnit(this.numerator, this.denominator, this.symbol,
      [this.isPremium = true]);

  @override
  String toString() => symbol;

  static BeatUnit fromJson(Map<String, dynamic> json) =>
      BeatUnit.values.firstWhere((beatUnit) =>
          beatUnit.numerator == json["numerator"] &&
          beatUnit.denominator == json["denominator"]);

  String toJsonString() =>
      jsonEncode({"numerator": numerator, "denominator": denominator});
}
