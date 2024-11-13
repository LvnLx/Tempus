import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomic/audio.dart';
import 'package:metronomic/playback/bpmDial.dart';

class PlaybackController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlaybackControllerState();
}

class PlaybackControllerState extends State<PlaybackController> {
  int bpm = 120;
  bool playback = false;

  onDialChanged(int change) {
    setBpm(bpm + change);
  }

  setBpm(int newBpm) {
    setState(() => newBpm > 0 ? bpm = newBpm : 1);
    Audio.setBpm(bpm);
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
            flex: 3,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                      width: 250,
                      height: 250,
                      child: BpmDial(
                          callbackThreshold: 20, callback: onDialChanged)),
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
                                PlatformIcons(context).settings,
                                size: 35,
                                color: Colors.white,
                              ),
                              onPressed: () => (print("Settings")),
                            ),
                            PlatformIconButton(
                              icon: Icon(
                                  size: 35,
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
