import 'dart:math';
import 'package:flutter/material.dart';

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

class BpmDial extends StatefulWidget {
  final int callbackThreshold;
  final Function(int) callback;

  BpmDial({required this.callbackThreshold, required this.callback})
      : assert(callbackThreshold >= 1 && callbackThreshold <= 360,
            'Threshold must be between 1 and 360 (inclusive)');

  @override
  State<StatefulWidget> createState() => BpmDialState();
}

class BpmDialState extends State<BpmDial> {
  late Point previous;
  double baseDialRotation = 0;
  double dialRotation = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Point origin =
            Point(constraints.maxWidth / 2, constraints.maxHeight / 2);
        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            previous = Point(details.localPosition.dx - origin.x,
                origin.y - details.localPosition.dy);
          },
          onPanUpdate: (DragUpdateDetails details) {
            Point current = Point(details.localPosition.dx - origin.x,
                origin.y - details.localPosition.dy);

            double dotProduct = algebraicDotProduct(current, previous);
            double magnitude = current.magnitude * previous.magnitude;

            double rotationRadians = acos(dotProduct / magnitude);
            double rotationDegrees = degrees(rotationRadians);

            if (crossProduct(current, previous) < 0) {
              rotationDegrees = -rotationDegrees;
            }

            int change =
                (rotationDegrees / widget.callbackThreshold / 2).round();

            if (change != 0) {
              widget.callback(change);
              previous = current;
              baseDialRotation = dialRotation;
              setState(() => dialRotation = baseDialRotation);
            } else {
              setState(() => dialRotation = baseDialRotation + rotationDegrees);
            }
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
                    color: Colors.white,
                  ),
                ),
                  Positioned(
                    top: (constraints.maxHeight / 2) -
                        80 * cos(0.0) -
                        25.0,
                    left: (constraints.maxWidth / 2) -
                        80 * sin(0.0) -
                        25.0,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(30, 30, 30, 1.0), shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
