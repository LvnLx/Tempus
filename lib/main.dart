import 'package:flutter/material.dart';
import 'package:metronomic/audio.dart';

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
  final ValueNotifier<int> _bpm = ValueNotifier<int>(120);
  
  @override void initState() {
    super.initState();

    Audio.postFlutterInit();
    Audio.configureBuffer(_bpm.value);
    _bpm.addListener(() => Audio.configureBuffer(_bpm.value));
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: togglePlayback,
                icon: playback
                    ? const Icon(Icons.pause_circle_rounded)
                    : const Icon(Icons.play_arrow_rounded),
                iconSize: 100,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
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
                      child: Text(_bpm.value.toString(),
                          style: const TextStyle(fontSize: 50)),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
