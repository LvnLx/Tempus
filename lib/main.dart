import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomic/audio.dart';
import 'package:metronomic/SubdivisionController.dart';
import 'package:metronomic/playbackController.dart';
import 'package:metronomic/subdivision.dart';

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
    bpm.addListener(() => Audio.updateBpm(bpm.value));
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
      home: PlatformScaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              children: [
                Expanded(child: SubdivisionController()),
                Expanded(child: PlaybackController())
              ],
            );
          },
        ),
      ),
    );
  }
/*
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        bpm.value.toString(),
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Subdivisions',
                        style: TextStyle(color: Colors.grey, fontSize: 22),
                      ),
                    ),
                    ...subdivisions.value,
                    if (!hasMaxSubdivisions)
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DottedBorder(
                            color: Colors.grey,
                            dashPattern: [5, 5],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              child: IconButton(
                                  onPressed: addSubdivision,
                                  icon: Icon(Icons.add, color: Colors.grey)),
                            ),
                          )),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () => setState(() {
                            bpm.value--;
                          }),
                          icon: Icon(
                            Icons.remove,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: togglePlayback,
                          icon: playback
                              ? Icon(Icons.pause_circle_rounded)
                              : Icon(Icons.play_arrow_rounded),
                          iconSize: 50,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () => setState(() {
                                  bpm.value++;
                                }),
                            icon: Icon(
                              Icons.add,
                              size: 50,
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }*/
}
