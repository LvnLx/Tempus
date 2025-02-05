import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/playback/bpm_dial.dart';
import 'package:tempus/settings/settings.dart';

class PlaybackController extends StatefulWidget {
  const PlaybackController({super.key});

  @override
  State<StatefulWidget> createState() => PlaybackControllerState();
}

class PlaybackControllerState extends State<PlaybackController> {
  final int maxTapTimeCount = 5;

  late Timer lastTapTimer;

  Queue<int> tapTimes = Queue();
  bool playback = false;

  @override
  void initState() {
    super.initState();
    Audio.stopPlayback();
  }

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
      setBpm((1 / (averageTapDeltaMilliseconds() / 1000) * 60).round(),
          skipUnchanged: false);
      lastTapTimer.cancel();
      lastTapTimer =
          Timer(Duration(seconds: 3), () => setState(tapTimes.clear));
    }
  }

  Future<void> setBpm(int newBpm, {bool skipUnchanged = true}) async {
    await Provider.of<AppState>(context, listen: false)
        .setBpm(newBpm, skipUnchanged: skipUnchanged);
  }

  Future<void> togglePlayback() async {
    playback ? await Audio.stopPlayback() : await Audio.startPlayback();
    setState(() {
      playback = !playback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlatformIconButton(
                  icon: Icon(
                    PlatformIcons(context).remove,
                    color: Theme.of(context).colorScheme.primary,
                    size: 35,
                  ),
                  onPressed: () async => await setBpm(
                      Provider.of<AppState>(context, listen: false).getBpm() -
                          1),
                ),
                GestureDetector(
                  onTap: () async => await showBpmDialog(context, setBpm,
                      Provider.of<AppState>(context, listen: false).getBpm()),
                  child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(8.0)),
                      width: 100,
                      height: 60,
                      child: Center(
                          child: Text(
                        tapTimes.length == 1
                            ? "TAP"
                            : Provider.of<AppState>(context)
                                .getBpm()
                                .toString(),
                        style: TextStyle(
                            fontSize: 35,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center,
                      ))),
                ),
                PlatformIconButton(
                    icon: Icon(PlatformIcons(context).add,
                        color: Theme.of(context).colorScheme.primary, size: 35),
                    onPressed: () async => await setBpm(
                        Provider.of<AppState>(context, listen: false).getBpm() +
                            1)),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                        width: constraints.maxHeight / 3 * 2,
                        height: constraints.maxWidth / 3 * 2,
                        child: BpmDial(
                            callbackThreshold: 20,
                            callback: (int change) async => await setBpm(
                                Provider.of<AppState>(context, listen: false)
                                        .getBpm() +
                                    change))),
                  ),
                  Center(
                      child: PlatformIconButton(
                    icon: Icon(
                        size: 80,
                        playback
                            ? PlatformIcons(context).pause
                            : PlatformIcons(context).playArrowSolid,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: () async => await togglePlayback(),
                  )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PlatformIconButton(
                                  icon: Icon(
                                    PlatformIcons(context).settings,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        builder: (BuildContext context) =>
                                            Settings());
                                  }),
                              PlatformIconButton(
                                  icon: Icon(
                                    Icons.touch_app,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: tapTempo)
                            ]),
                      ),
                    ],
                  )
                ],
              )),
        ],
      );
    });
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
                    style: TextStyle(fontSize: 35),
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
