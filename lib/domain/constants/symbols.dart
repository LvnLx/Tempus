class Symbols {
  static final String augmentationDot = "\u{1D16D}";
}

enum Note {
  whole(1, "\u{1D15D}"),
  half(2, "\u{1D15E}"),
  quarter(4, "\u{1D15F}"),
  eighth(8, "\u{1D160}"),
  sixteenth(16, "\u{1D161}"),
  thirtySecond(32, "\u{1D162}"),
  sixtyFourth(64, "\u{1D163}");

  final int denominator;
  final String symbol;

  const Note(this.denominator, this.symbol);
}

enum NumericSubscript {
  zero(0, "\u{2080}"),
  one(1, "\u{2081}"),
  two(2, "\u{2082}"),
  three(3, "\u{2083}"),
  four(4, "\u{2084}"),
  five(5, "\u{2085}"),
  six(6, "\u{2086}"),
  seven(7, "\u{2087}"),
  eight(8, "\u{2088}"),
  nine(9, "\u{2089}");

  final int value;
  final String symbol;

  const NumericSubscript(this.value, this.symbol);
}
