import 'package:flutter/material.dart';
import 'package:metronomical/subdivision/subdivision.dart';

class ScrollWheel extends StatefulWidget {
  final Function(String) callback;

  ScrollWheel({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() => ScrollWheelState();
}

class ScrollWheelState extends State<ScrollWheel> {
  late final FixedExtentScrollController _scrollController;

  double itemHeight = 40; // Height of each item in the list
  int itemCount = subdivisionOptions.length;
  int viewCount = 3;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight * viewCount,
      child: ListWheelScrollView.useDelegate(
        controller: _scrollController,
        itemExtent: itemHeight,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: (int value) => {widget.callback(subdivisionOptions[value])},
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final double scrollOffset = _scrollController.offset;
            final double itemScrollOffset = scrollOffset % itemHeight;

            // Calculate transition values for entering and exiting animations
            final double enteringScale = 1.0 - (itemScrollOffset / itemHeight);
            final double exitingScale = itemScrollOffset / itemHeight;

            final centerOffset = index * itemHeight - scrollOffset;
            final itemOpacity = (double x) {
              if (x < viewCount ~/ 2 * itemHeight) return 1.0;
              if (x > (viewCount ~/ 2 + 1) * itemHeight) return 0.0;
              return 1 - (x - viewCount ~/ 2 * itemHeight) / itemHeight;
            }(centerOffset.abs() + 25); // adjust as needed

            return AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                // return Text('offset: $centerOffset,  opacity: $itemOpacity');
                return Transform.scale(
                  scale: (enteringScale + exitingScale)
                      .clamp(0.6, 1.0), // Adjust the range as needed
                  child: Opacity(opacity: itemOpacity, child: child),
                );
              },
              child: Text(subdivisionOptions[index], style: TextStyle(color: Colors.white, fontSize: 35),)
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}
