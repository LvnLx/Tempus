import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/selector.dart';
import 'package:tempus/ui/core/themed_text.dart';

class SubdivisionOptionButton extends StatelessWidget {
  final Future<void> Function(int updatedSubdivisionOption) callback;
  final int subdivisionOption;

  const SubdivisionOptionButton(
      {super.key, required this.callback, required this.subdivisionOption});

  @override
  Widget build(BuildContext context) => ThemedButton(
      onPressed: () async => await _showDialog(context),
      child: ScaledPadding(
          scale: 0.8,
          child: FittedBox(child: ThemedText(subdivisionOption.toString()))));

  Future<void> _showDialog(BuildContext context) async {
    int updatedSubdivisionOption = subdivisionOption;

    await showInputDialog(context,
        title: "Subdivision Option",
        input: SizedBox(
          height: (TextPainter(
                  text: TextSpan(text: "\n\n"),
                  maxLines: 2,
                  textScaler: MediaQuery.of(context).textScaler,
                  textDirection: TextDirection.ltr)
                ..layout())
              .size
              .height,
          child: LayoutBuilder(
            builder: (_, constraints) => Selector(
                callback: (index) async => updatedSubdivisionOption =
                    Options.subdivisionOptions[index],
                itemExtent: constraints.maxWidth / 6,
                initialItemIndex:
                    Options.subdivisionOptions.indexOf(subdivisionOption),
                options: Options.subdivisionOptions
                    .map((numeratorOption) => PlatformText(
                        numeratorOption.toString(),
                        style: TextStyle(fontFamily: "SFMono")))
                    .toList(),
                orientation: Axis.horizontal,
                useTheme: false),
          ),
        ),
        onConfirm: () async => await callback(updatedSubdivisionOption),
        confirmText: "Set");
  }
}
