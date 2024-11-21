import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomical/audio.dart';
import 'package:metronomical/playback/bpm_dial.dart';

class PlaybackController extends StatefulWidget {
  const PlaybackController({super.key});

  @override
  State<StatefulWidget> createState() => PlaybackControllerState();
}

class PlaybackControllerState extends State<PlaybackController> {
  int bpm = 120;
  bool playback = false;
  String feedback = "";

  onDialChanged(int change) {
    setBpm(bpm + change);
  }

  setBpm(int newBpm) {
    setState(() => newBpm > 0 ? bpm = newBpm : 1);
    Audio.setBpm(bpm);
  }

  sendFeedback() {
    print("Sent feedback \"$feedback\"");
    Navigator.pop(context);
  }

  setFeedback(String feedback) {
    this.feedback = feedback;
  }

  togglePlayback() {
    playback ? Audio.stopPlayback() : Audio.startPlayback();
    setState(() {
      playback = !playback;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () => setBpm(bpm - 1),
              ),
              Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0)),
                  width: 100,
                  height: 60,
                  child: Center(
                      child: Text(
                    bpm.toString(),
                    style: TextStyle(fontSize: 35, color: Colors.white),
                    textAlign: TextAlign.center,
                  ))),
              PlatformIconButton(
                  icon: Icon(PlatformIcons(context).add,
                      color: Colors.white, size: 35),
                  onPressed: () => setBpm(bpm + 1)),
            ],
          ),
        ),
        Expanded(
            flex: 4,
            child: Stack(
              children: [
                Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      flex: 9,
                      child: Center(
                        child: SizedBox(
                            width: 250,
                            height: 250,
                            child: BpmDial(
                                callbackThreshold: 20,
                                callback: onDialChanged)),
                      ),
                    ),
                    Expanded(flex: 1, child: Container())
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PlatformIconButton(
                                icon: Icon(
                                  PlatformIcons(context).edit,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                onPressed: () => showFeedbackDialog(context, setFeedback, sendFeedback)),
                            PlatformIconButton(
                              icon: Icon(
                                  size: 40,
                                  playback
                                      ? PlatformIcons(context).pause
                                      : PlatformIcons(context).playArrowSolid,
                                  color: Colors.white),
                              onPressed: togglePlayback,
                            )
                          ]),
                    ),
                  ],
                )
              ],
            )),
      ],
    );
  }
}

showFeedbackDialog(BuildContext context, Function setFeedbackCallback, Function sendFeedbackCallback) {
  showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
              title: Text("Feedback"),
              content: PlatformTextField(
                  hintText: "Issues, feature requests, ...",
                  onChanged: (text) => setFeedbackCallback(text)),
              actions: [
                PlatformDialogAction(
                    child: Text("Close"),
                    onPressed: () => Navigator.pop(context),
                    cupertino: (context, platform) =>
                        CupertinoDialogActionData(isDestructiveAction: true)),
                PlatformDialogAction(
                    child: Text("Submit"),
                    onPressed: () => sendFeedbackCallback(),
                    cupertino: (context, platform) =>
                        CupertinoDialogActionData(isDefaultAction: true))
              ]));
}
