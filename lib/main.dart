import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomic/audio.dart';
import 'package:metronomic/subdivision/subdivisionController.dart';
import 'package:metronomic/playback/playbackController.dart';
import 'package:metronomic/subdivision/subdivision.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool hasMaxSubdivisions = false;
  bool playback = false;

  final ValueNotifier<int> bpm = ValueNotifier<int>(120);
  final ValueNotifier<List<Subdivision>> subdivisions =
      ValueNotifier<List<Subdivision>>([]);

  @override
  void initState() {
    super.initState();

    Audio.postFlutterInit(bpm.value);
    bpm.addListener(() => Audio.setBpm(bpm.value));
    subdivisions.addListener(() => checkSubdivisionCount());
  }

  void addSubdivision() {
    var subdivisionKey = UniqueKey();
    var subdivision = Subdivision(
        key: subdivisionKey, onRemove: (Key key) => removeSubdivisonByKey(key));
    setState(() {
      subdivisions.value = [...subdivisions.value, subdivision];
    });
    Audio.addSubdivision(subdivisionKey, subdivision.getSubdivisionOption(),
        subdivision.getSubdivisionVolume());
  }

  void checkSubdivisionCount() {
    setState(() {
      hasMaxSubdivisions = subdivisions.value.length >= 4 ? true : false;
    });
  }

  void removeSubdivisonByKey(Key key) {
    var subdivision =
        subdivisions.value.firstWhere((element) => element.key == key);
    var index = subdivisions.value.indexOf(subdivision);
    setState(() {
      subdivisions.value = subdivisions.value.sublist(0, index) +
          subdivisions.value.sublist(index + 1, subdivisions.value.length);
    });
    Audio.removeSubdivision(key);
  }

  void togglePlayback() {
    playback ? Audio.stopPlayback() : Audio.startPlayback();
    setState(() {
      playback = !playback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      home: Container(
        color: Color.fromRGBO(30, 30, 30, 1.0),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Flex(
                direction: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                children: [
                  Expanded(child: SubdivisionController()),
                  orientation == Orientation.portrait
                      ? Divider(color: Color.fromRGBO(60, 60, 60, 1.0),)
                      : VerticalDivider(),
                  Expanded(child: PlaybackController())
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
