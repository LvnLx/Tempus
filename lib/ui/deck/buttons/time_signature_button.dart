import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/fraction.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/selector.dart';
import 'package:tempus/ui/core/themed_text.dart';

class TimeSignatureButton extends StatelessWidget {
  final Future<void> Function(TimeSignature timeSignature) setTimeSignature;
  final BoxConstraints constraints;
  final List<int> denominatorOptions;
  final List<int> numeratorOptions;
  final TimeSignature timeSignature;

  const TimeSignatureButton(
      {super.key,
      required this.setTimeSignature,
      required this.constraints,
      required this.denominatorOptions,
      required this.numeratorOptions,
      required this.timeSignature});

  @override
  Widget build(BuildContext context) => ThemedButton(
      onPressed: () async => await _showDialog(context),
      child: SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxHeight / 2,
          child: Column(children: [
            Expanded(
                child: SizedBox.expand(
                    child: FittedBox(
                        child:
                            ThemedText(timeSignature.numerator.toString())))),
            ThemedDivider(orientation: Axis.horizontal, girth: 0),
            Expanded(
                child: SizedBox.expand(
                    child: FittedBox(
                        child:
                            ThemedText(timeSignature.denominator.toString()))))
          ])));

  Future<void> _showDialog(BuildContext context) async {
    TimeSignature updatedTimeSignature = timeSignature;

    await showInputDialog(context,
        title: "Time Signature",
        input: SizedBox(
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
                        callback: (index) async => updatedTimeSignature =
                            updatedTimeSignature.copyWith(
                                numerator: numeratorOptions[index]),
                        itemExtent: constraints.maxWidth / 6,
                        initialItemIndex:
                            numeratorOptions.indexOf(timeSignature.numerator),
                        options: numeratorOptions
                            .map((numeratorOption) => PlatformText(
                                numeratorOption.toString(),
                                style: TextStyle(fontFamily: "SFMono")))
                            .toList(),
                        orientation: Axis.horizontal,
                        useTheme: false)),
                Flexible(child: ThemedDivider(orientation: Axis.horizontal)),
                Expanded(
                    child: Selector(
                        callback: (index) async => updatedTimeSignature =
                            updatedTimeSignature.copyWith(
                                denominator: denominatorOptions[index]),
                        itemExtent: constraints.maxWidth / 6,
                        initialItemIndex: denominatorOptions
                            .indexOf(timeSignature.denominator),
                        options: denominatorOptions
                            .map((denominatorOption) => PlatformText(
                                denominatorOption.toString(),
                                style: TextStyle(fontFamily: "SFMono")))
                            .toList(),
                        orientation: Axis.horizontal,
                        useTheme: false))
              ],
            ),
          ),
        ),
        onConfirm: () async => await setTimeSignature(updatedTimeSignature),
        confirmText: "Set");
  }
}
