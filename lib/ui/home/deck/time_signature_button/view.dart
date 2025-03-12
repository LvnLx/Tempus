import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/ui/core/selector.dart';

class TimeSignatureButton extends StatelessWidget {
  final int denominator;
  final int numerator;

  const TimeSignatureButton(
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
                    child: SizedBox(
                      height: (TextPainter(
                              text: TextSpan(text: "\n\n\n\n"),
                              maxLines: 4,
                              textScaler: MediaQuery.of(context).textScaler,
                              textDirection: TextDirection.ltr)
                            ..layout())
                          .size
                          .height,
                      child: LayoutBuilder(
                        builder: (_, constraints) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Selector(
                                    callback: (index) async =>
                                        updatedNumerator =
                                            numeratorOptions[index],
                                    itemExtent: constraints.maxWidth / 6,
                                    initialItemIndex:
                                        numeratorOptions.indexOf(numerator),
                                    options: numeratorOptions
                                        .map((numeratorOption) => FittedBox(
                                              child: PlatformText(
                                                  numeratorOption.toString(),
                                                  style: TextStyle(
                                                      fontFamily: "SFMono")),
                                            ))
                                        .toList(),
                                    orientation: Axis.horizontal,
                                    useTheme: false)),
                            Flexible(child: Divider()),
                            Expanded(
                                child: Selector(
                                    callback: (index) async =>
                                        updatedDenominator =
                                            denominatorOptions[index],
                                    itemExtent: constraints.maxWidth / 6,
                                    initialItemIndex:
                                        denominatorOptions.indexOf(denominator),
                                    options: denominatorOptions
                                        .map((denominatorOption) => FittedBox(
                                              child: PlatformText(
                                                  denominatorOption.toString(),
                                                  style: TextStyle(
                                                      fontFamily: "SFMono")),
                                            ))
                                        .toList(),
                                    orientation: Axis.horizontal,
                                    useTheme: false))
                          ],
                        ),
                      ),
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
