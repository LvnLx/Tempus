import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/outlined.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/home/deck/bpm_button/view.dart';
import 'package:tempus/ui/home/deck/bpm_dial/view.dart';
import 'package:tempus/ui/home/deck/settings/view.dart';
import 'package:tempus/ui/home/deck/view_model.dart';

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
        builder: (_, constraints) => Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: SizedBox.expand()),
                      Expanded(
                        flex: 3,
                        child: LayoutBuilder(
                          builder: (_, barConstraints) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BpmButton(
                                  callback: () async => await context
                                      .read<DeckViewModel>()
                                      .setBpm(
                                          context.read<DeckViewModel>().bpm -
                                              1),
                                  iconData: PlatformIcons(context).remove),
                              GestureDetector(
                                onTap: () async => await showBpmDialog(
                                    context,
                                    context.read<DeckViewModel>().setBpm,
                                    context.read<DeckViewModel>().bpm),
                                child: Outlined(
                                  child: SizedBox(
                                    height: barConstraints.maxHeight,
                                    width: barConstraints.maxHeight * 2,
                                    child: FittedBox(
                                        child: Text(
                                      tapTimes.length == 1
                                          ? "TAP"
                                          : context
                                              .watch<DeckViewModel>()
                                              .bpm
                                              .toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontFamily: "SFMono"),
                                      textAlign: TextAlign.center,
                                    )),
                                  ),
                                ),
                              ),
                              BpmButton(
                                  callback: () async => await context
                                      .read<DeckViewModel>()
                                      .setBpm(
                                          context.read<DeckViewModel>().bpm +
                                              1),
                                  iconData: PlatformIcons(context).add)
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox.expand())
                    ],
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                              width: constraints.maxHeight,
                              height: constraints.maxWidth,
                              child: BpmDial(
                                  callbackThreshold: 20,
                                  callback: (int change) async => await context
                                      .read<DeckViewModel>()
                                      .setBpm(
                                          context.read<DeckViewModel>().bpm +
                                              change))),
                        ),
                        Center(
                            child: GestureDetector(
                          onTap: () async => await context
                              .read<DeckViewModel>()
                              .togglePlayback(),
                          child: ScaledPadding(
                            scale: 0.4,
                            child: Icon(
                                context.watch<DeckViewModel>().playback
                                    ? PlatformIcons(context).pause
                                    : PlatformIcons(context).playArrowSolid,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        )),
                      ],
                    )),
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  constraints: constraints.copyWith(
                                      maxHeight: double.infinity),
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  builder: (BuildContext context) =>
                                      Settings());
                            },
                            child: AxisSizedBox(
                              reference: Axis.vertical,
                              child: FittedBox(
                                child: Icon(
                                  PlatformIcons(context).settings,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                ),
                              ),
                            ),
                          ),
                        )
                      ]),
                )
              ],
            ));
  }
}

Future<void> showBpmDialog(BuildContext context,
    Future<void> Function(int bpm) setBpm, int initialBpm) async {
  String bpm = initialBpm.toString();
  await showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
              title: Text("BPM"),
              content: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                  child: PlatformTextField(
                    autofocus: true,
                    cursorColor: Colors.transparent,
                    hintText: initialBpm.toString(),
                    keyboardType: TextInputType.number,
                    makeCupertinoDecorationNull: true,
                    maxLength: 3,
                    onChanged: (text) => bpm = text,
                    textAlign: TextAlign.center,
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
                      await setBpm(max(int.parse(bpm), 1));
                    },
                    cupertino: (context, platform) =>
                        CupertinoDialogActionData(isDefaultAction: true))
              ]));
}
