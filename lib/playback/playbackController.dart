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

  @override
  initState() {
    super.initState();
    Audio.postFlutterInit(bpm);
  }

  setBpm(int newBpm) {
    setState(() => bpm = newBpm);
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlatformIconButton(
                icon: Icon(
                  Icons.remove,
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
                  child: Center(
                      child: Text(
                    bpm.toString(),
                    style: TextStyle(fontSize: 35, color: Colors.white),
                    textAlign: TextAlign.center,
                  ))),
              PlatformIconButton(
                  icon: Icon(Icons.add, color: Colors.white, size: 35),
                  onPressed: () => setBpm(bpm + 1)),
            ],
          ),
        ),
        Expanded(
            flex: 4, child: SizedBox(width: 220, height: 220, child: BpmDial()))
      ],
    );
  }
}
