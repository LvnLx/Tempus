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
  late IconData volumeIcon;

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

  void setVolume(BuildContext context, double newVolume,
      [bool useThrottling = true]) {
    setState(() {
      volume = newVolume;
      if (volume > 0.66) {
        volumeIcon = PlatformIcons(context).volumeUp;
      } else if (volume > 0.33) {
        volumeIcon = PlatformIcons(context).volumeDown;
      } else if (volume > 0.0) {
        volumeIcon = PlatformIcons(context).volumeMute;
      } else {
        volumeIcon = PlatformIcons(context).volumeOff;
      }
    });
    Audio.setVolume(newVolume, useThrottling);
  }

  @override
  Widget build(BuildContext context) {
    setVolume(context, volume);
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
                  onChanged: (double value) => setVolume(context, value),
                  onChangeEnd: (double value) =>
                      setVolume(context, value, false),
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
        if (subdivisions.length < 3)
          PlatformIconButton(
              onPressed: addSubdivision,
              icon: Icon(
                PlatformIcons(context).add,
                color: Colors.white,
                size: 35,
              ))
      ],
    );
  }
}
