import 'package:flutter/material.dart';

class BpmDial extends StatefulWidget {
  final Function(int) callback;

  BpmDial({required this.callback});

  @override
  State<StatefulWidget> createState() => BpmDialState();
}

class BpmDialState extends State<BpmDial> {
  double? xPrevious;
  double? yPrevious;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double xCenter = constraints.maxWidth / 2;
        double yCenter = constraints.maxHeight / 2;

        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            xPrevious = details.localPosition.dx - xCenter;
            yPrevious = yCenter - details.localPosition.dy;
          },
          onPanUpdate: (DragUpdateDetails details) {
            double x = details.localPosition.dx - xCenter;
            double y = yCenter - details.localPosition.dy;

            int rotationMinimum = 15;
            if (((x - xPrevious!).abs() < rotationMinimum &&
                (y - yPrevious!).abs() < rotationMinimum)) {
              return;
            }

            Direction direction = getDirection(xPrevious!, yPrevious!, x, y);
            bool isClockwise;

            if (y > 0) {
              if (x > 0) {
                // Quadrant 1
                switch (direction) {
                  case Direction.up:
                    isClockwise = false;
                  case Direction.down:
                    isClockwise = true;
                  case Direction.left:
                    isClockwise = false;
                  case Direction.right:
                    isClockwise = true;
                }
              } else {
                // Quadrant 2
                switch (direction) {
                  case Direction.up:
                    isClockwise = true;
                  case Direction.down:
                    isClockwise = false;
                  case Direction.left:
                    isClockwise = false;
                  case Direction.right:
                    isClockwise = true;
                }
              }
            } else {
              if (x < 0) {
                // Quadrant 3
                switch (direction) {
                  case Direction.up:
                    isClockwise = true;
                  case Direction.down:
                    isClockwise = false;
                  case Direction.left:
                    isClockwise = true;
                  case Direction.right:
                    isClockwise = false;
                }
              } else {
                // Quadrant 4
                switch (direction) {
                  case Direction.up:
                    isClockwise = false;
                  case Direction.down:
                    isClockwise = true;
                  case Direction.left:
                    isClockwise = true;
                  case Direction.right:
                    isClockwise = false;
                }
              }
            }

            xPrevious = x;
            yPrevious = y;

            widget.callback(isClockwise ? 1 : -1);
          },
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(60, 60, 60, 1.0),
            ),
          ),
        );
      },
    );
  }
}

enum Direction { up, down, left, right }

Direction getDirection(double x1, double y1, double x2, double y2) {
  double dx = x2 - x1;
  double dy = y2 - y1;

  if (dx.abs() > dy.abs()) {
    return dx > 0 ? Direction.right : Direction.left;
  } else {
    return dy > 0 ? Direction.up : Direction.down;
  }
}
