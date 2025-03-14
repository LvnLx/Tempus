import 'dart:convert';

import 'package:tempus/domain/constants/symbols.dart';
import 'package:tempus/domain/extensions/int.dart';

class Fraction {
  final int denominator;
  final int numerator;

  const Fraction(this.numerator, this.denominator);

  String toJsonString() =>
      jsonEncode({"numerator": numerator, "denominator": denominator});
}

class BeatUnit extends Fraction {
  const BeatUnit(super.numerator, super.denominator);

  static BeatUnit fromJson(Map<String, dynamic> json) =>
      BeatUnit(json["numerator"], json["denominator"]);

  @override
  String toString() {
    if (_isDotted()) {
      return "${Note.values.firstWhere((note) => note.denominator == denominator / 2).symbol} ${Symbols.augmentationDot}";
    } else if (denominator.isPowerOfTwo()) {
      return Note.values
          .firstWhere((note) => note.denominator == denominator)
          .symbol;
    } else {
      return "${Note.values.firstWhere((note) => note.denominator == denominator.roundedDownToPowerOfTwo()).symbol}${denominator.toNumericSubscript()}";
    }
  }

  bool _isDotted() => numerator == 3 && denominator.isPowerOfTwo() && denominator > 1;
}

class TimeSignature extends Fraction {
  const TimeSignature(super.numerator, super.denominator);

  @override
  bool operator ==(Object other) {
    return other is TimeSignature &&
        other.numerator == numerator &&
        other.denominator == denominator;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);

  static TimeSignature fromJson(Map<String, dynamic> json) =>
      TimeSignature(json["numerator"], json["denominator"]);

  TimeSignature copyWith({int? denominator, int? numerator}) => TimeSignature(
      numerator ?? this.numerator, denominator ?? this.denominator);

  BeatUnit defaultBeatUnit() {
    return _isCompound() ? BeatUnit(3, denominator) : BeatUnit(1, denominator);
  }

  bool _isCompound() =>
      numerator % 3 == 0 && numerator != 3;
}
