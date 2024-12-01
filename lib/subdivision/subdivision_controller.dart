import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/subdivision/subdivision.dart';

class SubdivisionController extends StatefulWidget {
  const SubdivisionController({super.key});

  @override
  State<StatefulWidget> createState() => SubdivisionControllerState();
}

class SubdivisionControllerState extends State<SubdivisionController> {
  final Map<Key, Subdivision> subdivisions = <Key, Subdivision>{};

  double volume = 1.0;
  late IconData volumeIcon;

  @override // Instead of initState, since we need access to context
  void didChangeDependencies() {
    super.didChangeDependencies();
    setVolume(context, volume);
  }

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
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                      child: RotatedBox(
                    quarterTurns: 3,
                    child: PlatformSlider(
                      activeColor: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.primary,
                      )),
                    ),
                  ),
                ],
              ),
            ),
            ...subdivisions.values,
            VerticalDivider(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            if (subdivisions.length <= subdivisionOptions.length)
              PlatformIconButton(
                  onPressed: addSubdivision,
                  icon: Icon(
                    PlatformIcons(context).add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 35,
                  ))
          ],
        ),
      ),
    );
  }
}
