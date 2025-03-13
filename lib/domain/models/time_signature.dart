import 'dart:convert';

import 'package:tempus/domain/models/beat_unit.dart';

class TimeSignature {
  final int denominator;
  final int numerator;

  const TimeSignature(this.numerator, this.denominator);

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

  BeatUnit defaultBeatUnit() => throw UnimplementedError();

  String toJsonString() =>
      jsonEncode({"numerator": numerator, "denominator": denominator});
}
