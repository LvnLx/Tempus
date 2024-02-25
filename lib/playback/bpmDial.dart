import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class BpmDial extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BpmDialState();
}

class BpmDialState extends State<BpmDial> {
  double _rotationAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          if (details.primaryDelta != null) {
            setState(() {
              // Calculate the angle based on the pan update
              _rotationAngle += details.primaryDelta!;
            });
          }
        },
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(60, 60, 60, 1.0),
          ),
        ));
  }
}
