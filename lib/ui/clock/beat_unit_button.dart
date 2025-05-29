import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/domain/models/fraction.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/selector.dart';
import 'package:tempus/ui/core/themed_text.dart';

class BeatUnitButton extends StatelessWidget {
  final BeatUnit beatUnit;
  final BoxConstraints constraints;
  final bool isPremium;
  final Future<void> Function(BeatUnit beatUnit) setBeatUnit;

  const BeatUnitButton(
      {super.key,
      required this.beatUnit,
      required this.constraints,
      required this.isPremium,
      required this.setBeatUnit});

  @override
  Widget build(BuildContext context) => ThemedButton(
      onPressed: () async => await _showDialog(context),
      child: SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxHeight / 2,
        child: ScaledPadding(
          scale: 0.9,
          child: FittedBox(
              child: ThemedText(beatUnit.toString(), isMusicalSymbal: true)),
        ),
      ));

  Future<void> _showDialog(BuildContext context) async {
    BeatUnit updatedBeatUnit = beatUnit;

    await showInputDialog(context,
        title: "Beat Unit",
        input: SizedBox(
          height: (TextPainter(
                  text: TextSpan(text: "\n\n\n"),
                  maxLines: 3,
                  textScaler: MediaQuery.of(context).textScaler,
                  textDirection: TextDirection.ltr)
                ..layout())
              .size
              .height,
          child: LayoutBuilder(
            builder: (_, constraints) => Selector(
                callback: (index) async => updatedBeatUnit = (isPremium
                    ? Options.premiumBeatUnits
                    : Options.freeBeatUnits)[index],
                itemExtent: constraints.maxWidth / 6,
                initialItemIndex: (isPremium
                        ? Options.premiumBeatUnits
                        : Options.freeBeatUnits)
                    .indexOf(beatUnit),
                options: (isPremium
                        ? Options.premiumBeatUnits
                        : Options.freeBeatUnits)
                    .map((beatUnit) => SizedBox(
                          height: constraints.maxWidth / 10,
                          child: Center(
                            child: PlatformText(beatUnit.toString(),
                                style: TextStyle(
                                    fontFamily: "NotoMusic",
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))
                    .toList(),
                orientation: Axis.horizontal,
                useTheme: false),
          ),
        ),
        onConfirm: () async => await setBeatUnit(updatedBeatUnit),
        confirmText: "Set");
  }
}
