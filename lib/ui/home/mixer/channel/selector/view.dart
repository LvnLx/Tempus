import 'package:flutter/material.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

class Selector extends StatefulWidget {
  final Future<void> Function(Key, int) callback;
  final double height;
  final int initialItem;

  Selector(
      {super.key,
      required this.callback,
      required this.height,
      required this.initialItem});

  @override
  State<StatefulWidget> createState() => SelectorState();
}

class SelectorState extends State<Selector> {
  late final FixedExtentScrollController _scrollController;

  int itemCount = subdivisionOptions.length;
  int viewCount = 3;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.jumpTo(widget.initialItem * (widget.height / 3)));
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
    return ListWheelScrollView.useDelegate(
      controller: _scrollController,
      itemExtent: widget.height / viewCount,
      physics: FixedExtentScrollPhysics(),
      onSelectedItemChanged: (int value) async =>
          {await widget.callback(widget.key!, subdivisionOptions[value])},
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final double scrollOffset = _scrollController.offset;
          final double itemScrollOffset = scrollOffset % (widget.height / 3);

          // Calculate transition values for entering and exiting animations
          final double enteringScale = 1.0 - (itemScrollOffset / (widget.height / 3));
          final double exitingScale = itemScrollOffset / (widget.height / 3);

          final centerOffset = index * (widget.height / 3) - scrollOffset;
          final itemOpacity = (double x) {
            if (x < viewCount ~/ 2 * (widget.height / 3)) return 1.0;
            if (x > (viewCount ~/ 2 + 1) * (widget.height / 3)) return 0.0;
            return 1 - (x - viewCount ~/ 2 * (widget.height / 3)) / (widget.height / 3);
          }(centerOffset.abs() + widget.height / 5); // adjust as needed

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
              child: FittedBox(
                child: Text(
                  subdivisionOptions[index].toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: "SFMono"),
                ),
              ));
        },
        childCount: itemCount,
      ),
    );
  }
}
