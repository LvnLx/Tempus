import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:metronomic/audio.dart';
import 'package:metronomic/subdivision.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool playback = false;
  List<Subdivision> subdivisons = [];
  final ValueNotifier<int> _bpm = ValueNotifier<int>(120);

  @override
  void initState() {
    super.initState();

    Audio.postFlutterInit(_bpm.value);
    _bpm.addListener(() => Audio.updateBpm(_bpm.value));
  }

  void addSubdivision() {
    setState(() {
      subdivisons = [
        ...subdivisons,
        Subdivision(
            key: UniqueKey(), onRemove: (Key key) => removeSubdivisonByKey(key))
      ];
    });
  }

  void removeSubdivisonByKey(Key key) {
    var subdivision = subdivisons.firstWhere((element) => element.key == key);
    setState(() {
      subdivisons.remove(subdivision);
    });
  }

  void togglePlayback() {
    playback ? Audio.stopPlayback() : Audio.startPlayback();
    setState(() {
      playback = !playback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _bpm.value.toString(),
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...subdivisons,
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DottedBorder(
                          color: Colors.grey,
                          dashPattern: [5, 5],
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          child: Container(
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
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _bpm.value--;
                          }),
                          icon: const Icon(
                            Icons.remove,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: togglePlayback,
                          icon: playback
                              ? const Icon(Icons.pause_circle_rounded)
                              : const Icon(Icons.play_arrow_rounded),
                          iconSize: 50,
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () => setState(() {
                                  _bpm.value++;
                                }),
                            icon: const Icon(
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
  }
}
