import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

String capitalizeFirst(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

String jsonEncodeSubdivisions(Map<Key, SubdivisionData> subdivisions) =>
    jsonEncode(subdivisions
        .map((key, value) => MapEntry(key.toString(), value.toJson())));
