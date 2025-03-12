import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/constants.dart';
import 'package:tempus/ui/core/selector.dart';

class TimeSignature extends StatelessWidget {
  final int denominator;
  final int numerator;

  const TimeSignature(
      {super.key, required this.numerator, required this.denominator});

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: SizedBox.expand(
                child: FittedBox(
                    child: Text(numerator.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: "SFMono"))))),
        Divider(height: 0),
        Expanded(
            child: SizedBox.expand(
                child: FittedBox(
                    child: Text(denominator.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: "SFMono")))))
      ]);

  static Future<void> showDialog(
      BuildContext context,
      Future<void> Function(int) numeratorCallback,
      Future<void> Function(int) denominatorCallback,
      int numerator,
      int denominator,
      List<int> numeratorOptions,
      List<int> denominatorOptions) async {
    int updatedNumerator = numerator;
    int updatedDenominator = denominator;
    showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
                title: Text("Time Signature"),
                content: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        SizedBox(
                            height: Constants.dialogMinWidth / 8,
                            child: Selector(
                                callback: (index) async =>
                                    updatedNumerator = numeratorOptions[index],
                                itemExtent: Constants.dialogMinWidth / 8,
                                initialItemIndex:
                                    numeratorOptions.indexOf(numerator),
                                options: numeratorOptions,
                                orientation: Axis.horizontal,
                                useTheme: false)),
                        Divider(),
                        SizedBox(
                            height: Constants.dialogMinWidth / 8,
                            child: Selector(
                                callback: (index) async =>
                                    denominator = denominatorOptions[index],
                                itemExtent: Constants.dialogMinWidth / 8,
                                initialItemIndex:
                                    denominatorOptions.indexOf(denominator),
                                options: denominatorOptions,
                                orientation: Axis.horizontal,
                                useTheme: false))
                      ],
                    )),
                actions: [
                  PlatformDialogAction(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDestructiveAction: true)),
                  PlatformDialogAction(
                      child: Text("Set"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await numeratorCallback(updatedNumerator);
                        await denominatorCallback(updatedDenominator);
                      },
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDefaultAction: true))
                ]));
  }
}
