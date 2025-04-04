import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/themed_text.dart';
import 'package:tempus/ui/deck/buttons/beat_unit_button.dart';
import 'package:tempus/ui/deck/buttons/bpm_button.dart';
import 'package:tempus/ui/deck/bpm_dial.dart';
import 'package:tempus/ui/settings/view.dart';
import 'package:tempus/ui/deck/buttons/time_signature_button.dart';
import 'package:tempus/ui/deck/view_model.dart';

class Deck extends StatefulWidget {
  const Deck({super.key});

  @override
  State<StatefulWidget> createState() => DeckState();
}

class DeckState extends State<Deck> {
  final int maxTapTimeCount = 5;

  late Timer lastTapTimer;
  Queue<int> tapTimes = Queue();

  void addTapTime(int tapTime) {
    if (tapTimes.length >= maxTapTimeCount) {
      tapTimes.removeFirst();
    }

    tapTimes.addLast(tapTime);
  }

  int averageTapDeltaMilliseconds() {
    List<int> tapTimeDeltas = List.empty(growable: true);
    for (int i = 1; i < tapTimes.length; i++) {
      tapTimeDeltas.add(tapTimes.elementAt(i) - tapTimes.elementAt(i - 1));
    }

    int sum = tapTimeDeltas.reduce((value, element) => value + element);
    return (sum / tapTimeDeltas.length).round();
  }

  void tapTempo() {
    if (tapTimes.isEmpty) {
      setState(() => addTapTime(DateTime.now().millisecondsSinceEpoch));
      lastTapTimer =
          Timer(Duration(seconds: 3), () => setState(tapTimes.clear));
    } else {
      setState(() => addTapTime(DateTime.now().millisecondsSinceEpoch));
      context.read<DeckViewModel>().setBpm(
          (1 / (averageTapDeltaMilliseconds() / 1000) * 60).round(), false);
      lastTapTimer.cancel();
      lastTapTimer =
          Timer(Duration(seconds: 3), () => setState(tapTimes.clear));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, constraints) => Flex(direction: Axis.vertical, children: [
              Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                      builder: (_, barConstraints) => Column(children: [
                            Expanded(child: SizedBox()),
                            Expanded(
                                flex: 5,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BeatUnitButton(
                                          beatUnit: context
                                              .watch<DeckViewModel>()
                                              .beatUnit,
                                          constraints: barConstraints,
                                          isPremium: context
                                              .watch<DeckViewModel>()
                                              .isPremium,
                                          setBeatUnit: context
                                              .read<DeckViewModel>()
                                              .setBeatUnit),
                                      SizedBox(
                                        height: barConstraints.maxHeight,
                                        child: ThemedDivider(orientation: Axis.vertical),
                                      ),
                                      ThemedButton(
                                          onPressed: () async =>
                                              await _showBpmDialog(context),
                                          child: SizedBox(
                                              height:
                                                  barConstraints.maxHeight / 2,
                                              width: barConstraints.maxHeight,
                                              child: FittedBox(
                                                  child: ThemedText(tapTimes
                                                              .length ==
                                                          1
                                                      ? "TAP"
                                                      : context
                                                          .watch<
                                                              DeckViewModel>()
                                                          .bpm
                                                          .toString())))),
                                      ThemedDivider(orientation: Axis.vertical),
                                      TimeSignatureButton(
                                          setTimeSignature:
                                              (updatedTimeSignature) => context
                                                  .read<DeckViewModel>()
                                                  .setTimeSignature(
                                                      updatedTimeSignature),
                                          constraints: barConstraints,
                                          denominatorOptions: context
                                                  .read<DeckViewModel>()
                                                  .isPremium
                                              ? Options.premiumDenominators
                                              : Options.freeDenominators,
                                          numeratorOptions: context
                                                  .read<DeckViewModel>()
                                                  .isPremium
                                              ? Options.premiumNumerators
                                              : Options.freeNumerators,
                                          timeSignature: context
                                              .read<DeckViewModel>()
                                              .timeSignature)
                                    ])),
                            Expanded(child: SizedBox())
                          ]))),
              Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                      builder: (_, dialConstraints) => Stack(children: [
                            Center(
                                child: SizedBox(
                                    height: min(dialConstraints.maxHeight,
                                        dialConstraints.maxWidth),
                                    width: min(dialConstraints.maxHeight,
                                        dialConstraints.maxWidth),
                                    child: BpmDial(
                                        callbackThreshold: 20,
                                        callback: (int change) async =>
                                            await context
                                                .read<DeckViewModel>()
                                                .setBpm(context
                                                        .read<DeckViewModel>()
                                                        .bpm +
                                                    change)))),
                            Center(
                                child: SizedBox(
                                    height: min(dialConstraints.maxHeight,
                                        dialConstraints.maxWidth),
                                    width: min(dialConstraints.maxHeight,
                                        dialConstraints.maxWidth),
                                    child: Row(children: [
                                      Expanded(
                                        child: BpmButton(
                                            callback: () async => await context
                                                .read<DeckViewModel>()
                                                .setBpm(context
                                                        .read<DeckViewModel>()
                                                        .bpm -
                                                    1),
                                            iconData:
                                                PlatformIcons(context).remove),
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: GestureDetector(
                                              onTap: () async => await context
                                                  .read<DeckViewModel>()
                                                  .togglePlayback(),
                                              child: SizedBox.expand(
                                                  child: FittedBox(
                                                      child: Icon(
                                                          context
                                                                  .watch<
                                                                      DeckViewModel>()
                                                                  .playback
                                                              ? CupertinoIcons
                                                                  .pause
                                                              : Icons
                                                                  .play_arrow_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary))))),
                                      Expanded(
                                          child: BpmButton(
                                              callback: () async => await context
                                                  .read<DeckViewModel>()
                                                  .setBpm(context
                                                          .read<DeckViewModel>()
                                                          .bpm +
                                                      1),
                                              iconData:
                                                  PlatformIcons(context).add))
                                    ])))
                          ]))),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: GestureDetector(
                            onTap: () async => await showPlatformModalSheet(
                                context: context,
                                builder: (BuildContext context) => Settings()),
                            child: AxisSizedBox(
                                reference: Axis.vertical,
                                child: FittedBox(
                                    child: Icon(
                                  PlatformIcons(context).settings,
                                  color: Theme.of(context).colorScheme.primary,
                                ))))),
                    Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: GestureDetector(
                            onTap: tapTempo,
                            child: AxisSizedBox(
                                reference: Axis.vertical,
                                child: FittedBox(
                                    child: Icon(
                                  Icons.touch_app,
                                  color: Theme.of(context).colorScheme.primary,
                                )))))
                  ]))
            ]));
  }

  Future<void> _showBpmDialog(BuildContext context) async {
    String updatedValue = "";
    await showInputDialog(context,
        title: "Beats Per Minute",
        input: PlatformTextField(
          autofocus: true,
          cursorColor: Colors.transparent,
          hintText: context.read<DeckViewModel>().bpm.toString(),
          keyboardType: TextInputType.number,
          makeCupertinoDecorationNull: true,
          maxLength: 3,
          onChanged: (text) => updatedValue = text,
          textAlign: TextAlign.center,
        ),
        onConfirm: () async => await context.read<DeckViewModel>().setBpm(max(
            int.tryParse(updatedValue) ?? context.read<DeckViewModel>().bpm,
            1)),
        confirmText: "Set");
  }
}
