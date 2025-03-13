import 'package:tempus/constants/symbols.dart';

extension IntExtensions on int {
  bool isPowerOfTwo() => this > 0 && (this & (this - 1)) == 0;

  int roundedDownToPowerOfTwo() {
    int n = this;
    n |= (n >> 1);
    n |= (n >> 2);
    n |= (n >> 4);
    n |= (n >> 8);
    n |= (n >> 16);
    return n - (n >> 1);
  }

  String toNumericSubscript() => toString()
      .split("")
      .map((character) => int.parse(character))
      .map((integer) => NumericSubscript.values
          .firstWhere((numericSubscript) => numericSubscript.value == integer))
      .map((numericSubscript) => numericSubscript.symbol)
      .join();
}
