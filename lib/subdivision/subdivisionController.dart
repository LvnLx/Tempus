import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomic/audio.dart';
import 'package:metronomic/subdivision/subdivision.dart';

class SubdivisionController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SubdivisionControllerState();
}

class SubdivisionControllerState extends State<SubdivisionController> {
  final Map<Key, Subdivision> subdivisions = <Key, Subdivision>{};

  double volume = 1.0;
  IconData volumeIcon = Icons.volume_up;

  void addSubdivision() {
    var key = UniqueKey();
    var subdivision =
        Subdivision(key: key, onRemove: (Key key) => removeSubdivison(key));
    setState(() {
      subdivisions[key] = subdivision;
    });
    Audio.addSubdivision(key, subdivision.getSubdivisionOption(),
        subdivision.getSubdivisionVolume());
  }

  void removeSubdivison(Key key) {
    setState(() {
      subdivisions.remove(key);
    });
    Audio.removeSubdivision(key);
  }

  void setVolume(double newVolume) {
    setState(() {
      volume = newVolume;
      if (volume > 0.66) {
        volumeIcon = Icons.volume_up;
      } else if (volume > 0.33) {
        volumeIcon = Icons.volume_down;
      } else if (volume > 0.0) {
        volumeIcon = Icons.volume_mute;
      } else {
        volumeIcon = Icons.volume_off;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: RotatedBox(
                quarterTurns: 3,
                child: PlatformSlider(
                  activeColor: Colors.white,
                  onChanged: (double value) => setVolume(volume = value),
                  value: volume,
                ),
              )),
              SizedBox(
                child: Center(
                  child: PlatformIconButton(
                      icon: Icon(
                    volumeIcon,
                    size: 35,
                    color: Colors.white,
                  )),
                ),
              ),
            ],
          ),
        ),
        ...subdivisions.values,
        VerticalDivider(
          color: Color.fromRGBO(60, 60, 60, 1.0),
        ),
        if (subdivisions.length < 2) PlatformIconButton(
            onPressed: addSubdivision,
            icon: Icon(
              Icons.add,
              color: Colors.white,
              size: 35,
            ))
      ],
    );
  }
}
