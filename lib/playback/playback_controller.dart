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
  bool playback = false;

  @override
  void initState() {
    super.initState();
    Audio.stopPlayback();
  }

  onDialChanged(int change) {
    setBpm(Provider.of<AppState>(context, listen: false).getBpm() + change);
  }

  setBpm(int newBpm) async {
    await Provider.of<AppState>(context, listen: false).setBpm(newBpm);
    await Audio.setBpm(newBpm);
  }

  togglePlayback() {
    playback ? Audio.stopPlayback() : Audio.startPlayback();
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
                  onPressed: () => setBpm(
                      Provider.of<AppState>(context, listen: false).getBpm() -
                          1),
                ),
                Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(8.0)),
                    width: 100,
                    height: 60,
                    child: Center(
                        child: Text(
                      Provider.of<AppState>(context).getBpm().toString(),
                      style: TextStyle(
                          fontSize: 35,
                          color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center,
                    ))),
                PlatformIconButton(
                    icon: Icon(PlatformIcons(context).add,
                        color: Theme.of(context).colorScheme.primary, size: 35),
                    onPressed: () => setBpm(
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
                            callbackThreshold: 20, callback: onDialChanged)),
                  ),
                  Center(
                      child: PlatformIconButton(
                    icon: Icon(
                        size: 80,
                        playback
                            ? PlatformIcons(context).pause
                            : PlatformIcons(context).playArrowSolid,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: togglePlayback,
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
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        builder: (BuildContext context) =>
                                            Settings());
                                  }),
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
