import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/fraction.dart';
import 'package:tempus/ui/core/outlined.dart';
import 'package:tempus/ui/core/selector.dart';

class TimeSignatureButton extends StatelessWidget {
  final Future<void> Function(TimeSignature updatedTimeSignature) callback;
  final BoxConstraints constraints;
  final List<int> denominatorOptions;
  final List<int> numeratorOptions;
  final TimeSignature timeSignature;

  const TimeSignatureButton(
      {super.key,
      required this.callback,
      required this.constraints,
      required this.denominatorOptions,
      required this.numeratorOptions,
      required this.timeSignature});

  @override
  Widget build(BuildContext context) => Outlined(
        child: GestureDetector(
            onTap: () async => await _showDialog(context),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxHeight / 2,
                child: Column(children: [
                  Expanded(
                      child: SizedBox.expand(
                          child: FittedBox(
                              child: Text(timeSignature.numerator.toString(),
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: "SFMono"))))),
                  Divider(height: 0),
                  Expanded(
                      child: SizedBox.expand(
                          child: FittedBox(
                              child: Text(timeSignature.denominator.toString(),
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: "SFMono")))))
                ]))),
      );

  Future<void> _showDialog(BuildContext context) async {
    TimeSignature updatedTimeSignature = timeSignature;

    return await showPlatformDialog(
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
                                        updatedTimeSignature =
                                            updatedTimeSignature.copyWith(
                                                numerator:
                                                    numeratorOptions[index]),
                                    itemExtent: constraints.maxWidth / 6,
                                    initialItemIndex: numeratorOptions
                                        .indexOf(timeSignature.numerator),
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
                                        updatedTimeSignature =
                                            updatedTimeSignature.copyWith(
                                                denominator:
                                                    denominatorOptions[index]),
                                    itemExtent: constraints.maxWidth / 6,
                                    initialItemIndex: denominatorOptions
                                        .indexOf(timeSignature.denominator),
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
                        await callback(updatedTimeSignature);
                      },
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDefaultAction: true))
                ]));
  }
}
