import 'dart:collection';

import 'package:flutter/foundation.dart';

class QueueNotifier<T> extends ValueNotifier<Queue<T>> {
  QueueNotifier([Queue<T>? initialQueue]) : super(initialQueue ?? Queue<T>());

  void addLast(T value) {
    this.value.addLast(value);
    notifyListeners();
  }

  void clear() {
    value.clear;
    notifyListeners();
  }

  T removeFirst() {
    T first = value.removeFirst();
    notifyListeners();

    return first;
  }
}
