import 'package:flutter/material.dart';

class BpmDial extends StatefulWidget {
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
        double centerX = constraints.maxWidth / 2;
        double centerY = constraints.maxHeight / 2;

        return GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            double x = details.localPosition.dx - centerX;
            double y = centerY - details.localPosition.dy;

            if (xPrevious != null && yPrevious != null) {
              Direction direction = getDirection(xPrevious!, yPrevious!, x, y);

              if (y > 0) {
                if (x > 0) {
                  // Quadrant 1
                  switch (direction) {
                    case Direction.up:
                      print('-');
                    case Direction.down:
                      print('+');
                    case Direction.left:
                      print('-');
                    case Direction.right:
                      print('+');
                  }
                } else {
                  // Quadrant 2
                  switch (direction) {
                    case Direction.up:
                      print('+');
                    case Direction.down:
                      print('-');
                    case Direction.left:
                      print('-');
                    case Direction.right:
                      print('+');
                  }
                }
              } else {
                if (x < 0) {
                  // Quadrant 3
                  switch (direction) {
                    case Direction.up:
                      print('+');
                    case Direction.down:
                      print('-');
                    case Direction.left:
                      print('+');
                    case Direction.right:
                      print('-');
                  }
                } else {
                  // Quadrant 4
                  switch (direction) {
                    case Direction.up:
                      print('-');
                    case Direction.down:
                      print('+');
                    case Direction.left:
                      print('+');
                    case Direction.right:
                      print('-');
                  }
                }
              }
            }

            xPrevious = x;
            yPrevious = y;
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
