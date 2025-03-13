import 'dart:convert';

enum BeatUnit {
  whole(1, 1, "\u{1D15D}"),
  dottedWhole(3, 2, "\u{1D15D} \u{1D16D}"),
  half(1, 2, "\u{1D15E}"),
  dottedHalf(3, 4, "\u{1D15E} \u{1D16D}"),
  quarter(1, 4, "\u{1D15F}", false),
  dottedQuarter(3, 8, "\u{1D15F} \u{1D16D}"),
  eighth(1, 8, "\u{1D160}"),
  dottedEighth(3, 16, "\u{1D160} \u{1D16D}", false),
  sixteenth(1, 16, "\u{1D161}"),
  dottedSixteenth(3, 32, "\u{1D161} \u{1D16D}"),
  thirtySecond(1, 32, "\u{1D162}"),
  dottedThirtySecond(3, 64, "\u{1D162} \u{1D16D}"),
  sixtyFourth(1, 64, "\u{1D163}"),
  dottedSixtyFourth(3, 128, "\u{1D163} \u{1D16D}"),
  oneHundredTwentyEighthNote(1, 128, "\u{1D164}"),
  dottedOneHundredTwentyEighthNote(3, 128, "\u{1D164} \u{1D16D}"),
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
