import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tempus/domain/models/subdivision.dart';

extension SubdivisionsExtensions on Map<Key, Subdivision> {
  String toJsonString() =>
      jsonEncode(map((key, value) => MapEntry(key.toString(), value.toJson())));
}