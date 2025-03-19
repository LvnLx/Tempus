import 'package:tempus/domain/constants/symbols.dart';
import 'package:tempus/domain/extensions/beat_units.dart';
import 'package:tempus/domain/models/fraction.dart';

class Options {
  static final List<BeatUnit> freeBeatUnits =
      [BeatUnit(3, 4), BeatUnit(3, 8), BeatUnit(1, 4), BeatUnit(1, 8)].sorted();
  static final List<int> freeDenominators = [4, 8];
  static final List<int> freeNumerators = [1, 2, 3, 4, 5, 6, 9, 12];
  static final List<BeatUnit> premiumBeatUnits =
      (Note.values.map((note) => BeatUnit(3, note.denominator)).toList() +
              List.generate(99, (index) => BeatUnit(1, index + 1)))
          .sorted();
  static final List<int> premiumDenominators =
      List.generate(99, (index) => index + 1);
  static final List<int> premiumNumerators =
      List.generate(99, (index) => index + 1);
  static final List<int> subdivisionOptions =
      List.generate(8, (index) => (index + 2));
}
