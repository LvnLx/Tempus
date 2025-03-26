import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:tempus/ui/home/mixer/channel.dart';

extension SubdivisionsExtensions on Map<Key, SubdivisionData> {
  String toJsonString() =>
      jsonEncode(map((key, value) => MapEntry(key.toString(), value.toJson())));
}