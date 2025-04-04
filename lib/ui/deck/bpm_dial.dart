import 'dart:math';
import 'package:flutter/material.dart';

class BpmDial extends StatefulWidget {
  final int callbackThreshold;
  final Future<void> Function(int) callback;

  BpmDial({super.key, required this.callbackThreshold, required this.callback})
      : assert(callbackThreshold >= 1 && callbackThreshold <= 360,
            'callbackThreshold must be in the range [1, 360]');

  @override
  State<StatefulWidget> createState() => BpmDialState();
}

class BpmDialState extends State<BpmDial> {
  double dialRotation = 0;

  late Point previousIncrement;
  late Point previous;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        Point origin =
            Point(constraints.maxWidth / 2, constraints.maxHeight / 2);
        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            previous = previousIncrement = Point(
                details.localPosition.dx - origin.x,
                origin.y - details.localPosition.dy);
          },
          onPanUpdate: (DragUpdateDetails details) async {
            Point current = Point(details.localPosition.dx - origin.x,
                origin.y - details.localPosition.dy);

            double previousStepDegrees =
                rotationDelta(current, previousIncrement);
            double previousDegrees = rotationDelta(current, previous);

            int change =
                (previousStepDegrees / widget.callbackThreshold / 2).round();

            if (change != 0) {
              await widget.callback(change);
              previousIncrement = current;
            }

            previous = current;
            setState(() => dialRotation += previousDegrees);
          },
          child: Transform.rotate(
            angle: radians(dialRotation),
            child: Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Center(
                  child: Container(
                    width: constraints.maxWidth / 5 * 3,
                    height: constraints.maxHeight / 5 * 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

double algebraicDotProduct(Point a, Point b) {
  return a.x * b.x + a.y * b.y as double;
}

double crossProduct(Point a, Point b) {
  return a.x * b.y - a.y * b.x as double;
}

double degrees(double radians) {
  return radians * (180 / pi);
}

double radians(double degrees) {
  return degrees * (pi / 180);
}

double rotationDelta(Point current, Point previous) {
  double dotProduct = algebraicDotProduct(current, previous);
  double magnitude = current.magnitude * previous.magnitude;

  double rotationRadians = acos(dotProduct / magnitude);
  double rotationDegrees = degrees(rotationRadians);

  return crossProduct(current, previous) >= 0
      ? rotationDegrees
      : -rotationDegrees;
}
