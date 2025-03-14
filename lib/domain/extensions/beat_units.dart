import 'package:tempus/domain/models/fraction.dart';

extension BeatUnitsExtensions on List<BeatUnit> {
  List<BeatUnit> sorted() {
    sort((a, b) =>
        (a.numerator / a.denominator).compareTo(b.numerator / b.denominator));
    return this;
  }
}
