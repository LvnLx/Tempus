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

  void addSubdivision() {
    var key = UniqueKey();
    var subdivision = Subdivision(
        key: key, onRemove: (Key key) => removeSubdivisonByKey(key));
    setState(() {
      subdivisions[key] = subdivision;
    });
    Audio.addSubdivision(key, subdivision.getSubdivisionOption(),
        subdivision.getSubdivisionVolume());
  }

  void removeSubdivisonByKey(Key key) {
    setState(() {
      subdivisions.remove(key);
    });
    Audio.removeSubdivision(key);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...subdivisions.values,
        PlatformIconButton(onPressed: addSubdivision, icon: Icon(Icons.add))
      ],
    );
  }
}
