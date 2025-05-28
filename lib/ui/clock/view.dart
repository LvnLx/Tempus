import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/ui/clock/view_model.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/core/themed_text.dart';
import 'package:tempus/ui/deck/buttons/beat_unit_button.dart';
import 'package:tempus/ui/deck/buttons/time_signature_button.dart';

class Clock extends StatelessWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, barConstraints) => Column(children: [
            Expanded(child: SizedBox()),
            Expanded(
                flex: 5,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  BeatUnitButton(
                      beatUnit: context.watch<ClockViewModel>().beatUnit,
                      constraints: barConstraints,
                      isPremium: context.watch<ClockViewModel>().isPremium,
                      setBeatUnit: context.read<ClockViewModel>().setBeatUnit),
                  SizedBox(
                    height: barConstraints.maxHeight,
                    child: ThemedDivider(orientation: Axis.vertical),
                  ),
                  ThemedButton(
                      onPressed: () async => await _showBpmDialog(context),
                      child: SizedBox(
                          height: barConstraints.maxHeight / 2,
                          width: barConstraints.maxHeight,
                          child: FittedBox(
                              child: ThemedText(context.read<ClockViewModel>().tapTimes.length == 1
                                  ? "TAP"
                                  : context
                                      .watch<ClockViewModel>()
                                      .bpm
                                      .toString())))),
                  ThemedDivider(orientation: Axis.vertical),
                  TimeSignatureButton(
                      setTimeSignature: (updatedTimeSignature) => context
                          .read<ClockViewModel>()
                          .setTimeSignature(updatedTimeSignature),
                      constraints: barConstraints,
                      denominatorOptions:
                          context.read<ClockViewModel>().isPremium
                              ? Options.premiumDenominators
                              : Options.freeDenominators,
                      numeratorOptions: context.read<ClockViewModel>().isPremium
                          ? Options.premiumNumerators
                          : Options.freeNumerators,
                      timeSignature:
                          context.read<ClockViewModel>().timeSignature)
                ])),
            Expanded(child: SizedBox())
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
