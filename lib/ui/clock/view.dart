import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/ui/clock/bpm_button.dart';
import 'package:tempus/ui/clock/view_model.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/clock/beat_unit_button.dart';
import 'package:tempus/ui/clock/time_signature_button.dart';

class Clock extends StatelessWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, constraints) =>
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            BeatUnitButton(
                beatUnit: context.watch<ClockViewModel>().beatUnit,
                constraints: constraints,
                isPremium: context.watch<ClockViewModel>().isPremium,
                setBeatUnit: context.read<ClockViewModel>().setBeatUnit),
            SizedBox(
              height: constraints.maxHeight,
              child: ThemedDivider(orientation: Axis.vertical),
            ),
            ThemedButton(
                onPressed: () async => await _showBpmDialog(context),
                child: BpmButton(
                    bpm: context.watch<ClockViewModel>().bpm,
                    tapTimes: context.watch<ClockViewModel>().tapTimes)),
            ThemedDivider(orientation: Axis.vertical),
            TimeSignatureButton(
                setTimeSignature: (updatedTimeSignature) => context
                    .read<ClockViewModel>()
                    .setTimeSignature(updatedTimeSignature),
                constraints: constraints,
                denominatorOptions: context.read<ClockViewModel>().isPremium
                    ? Options.premiumDenominators
                    : Options.freeDenominators,
                numeratorOptions: context.read<ClockViewModel>().isPremium
                    ? Options.premiumNumerators
                    : Options.freeNumerators,
                timeSignature: context.read<ClockViewModel>().timeSignature)
          ]));

  Future<void> _showBpmDialog(BuildContext context) async {
    String updatedValue = "";
    await showInputDialog(context,
        title: "Beats Per Minute",
        input: PlatformTextField(
          autofocus: true,
          cursorColor: Colors.transparent,
          hintText: context.read<ClockViewModel>().bpm.toString(),
          keyboardType: TextInputType.number,
          makeCupertinoDecorationNull: true,
          maxLength: 3,
          onChanged: (text) => updatedValue = text,
          textAlign: TextAlign.center,
        ),
        onConfirm: () async => await context.read<ClockViewModel>().setBpm(max(
            int.tryParse(updatedValue) ?? context.read<ClockViewModel>().bpm,
            1)),
        confirmText: "Set");
  }
}
