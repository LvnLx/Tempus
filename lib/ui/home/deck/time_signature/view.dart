import 'package:flutter/material.dart';
import 'package:tempus/ui/core/dialogs.dart';

class TimeSignature extends StatelessWidget {
  final Future<void> Function(int) denominatorCallback;
  final ValueNotifier<int> denominatorValueNotifier;
  final Future<void> Function(int) numeratorCallback;
  final ValueNotifier<int> numeratorValueNotifier;

  const TimeSignature(
      {super.key,
      required this.denominatorCallback,
      required this.denominatorValueNotifier,
      required this.numeratorCallback,
      required this.numeratorValueNotifier});

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: GestureDetector(
                onTap: () async => await showIntegerSettingDialog(
                    context,
                    "Time signature numerator",
                    2,
                    numeratorCallback,
                    numeratorValueNotifier.value),
                child: SizedBox.expand(
                    child: FittedBox(
                        child: Text(numeratorValueNotifier.value.toString(),
                            style: TextStyle(
                                fontFamily: "SFMono",
                                fontWeight: FontWeight.bold)))))),
        Divider(height: 0),
        Expanded(
            child: GestureDetector(
                onTap: () async => await showIntegerSettingDialog(
                    context,
                    "Time signature denominator",
                    2,
                    denominatorCallback,
                    denominatorValueNotifier.value),
                child: SizedBox.expand(
                    child: FittedBox(
                        child: Text(denominatorValueNotifier.value.toString(),
                            style: TextStyle(
                                fontFamily: "SFMono",
                                fontWeight: FontWeight.bold))))))
      ]);
}
