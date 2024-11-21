import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomical/audio.dart';
import 'package:metronomical/subdivision/scroll_wheel.dart';

typedef SubdivisionCallback = void Function(Key key);

const List<String> subdivisionOptions = ["2", "3", "4", "5", "6", "7", "8", "9"];

class Subdivision extends StatefulWidget {
  final SubdivisionCallback onRemove;

  Subdivision({required Key key, required this.onRemove}) : super(key: key);

  @override
  SubdivisionState createState() => SubdivisionState();

  String getSubdivisionOption() {
    final SubdivisionState subdivisionState = SubdivisionState();
    return subdivisionState.option;
  }

  double getSubdivisionVolume() {
    final SubdivisionState subdivisionState = SubdivisionState();
    return subdivisionState.volume;
  }
}

class SubdivisionState extends State<Subdivision> {
  double volume = 0.0;
  String option = subdivisionOptions[0];
  PageController scrollController = PageController(viewportFraction: 0.5);

  void setOption(String newOption) {
    setState(() {
      option = newOption;
    });
    Audio.setSubdivisionOption(widget.key!, newOption);
  }

  void setVolume(double newVolume, [bool useThrottling = true]) {
    setState(() {
      volume = newVolume;
    });
    Audio.setSubdivisionVolume(widget.key!, newVolume, useThrottling);
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.isScrollingNotifier.value == false) {
        final int currentPage = scrollController.page!.round();
        scrollController.animateToPage(
          currentPage,
          curve: Curves.easeOut,
          duration: Duration(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VerticalDivider(
          color: Color.fromRGBO(60, 60, 60, 1.0),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                child: RotatedBox(
                    quarterTurns: 3,
                    child: PlatformSlider(
                      activeColor: Colors.white,
                      onChanged: (double value) => setVolume(value),
                      onChangeEnd: (double value) => setVolume(value, false),
                      value: volume,
                    ))),
            SizedBox(width: 50, height: 120, child: ScrollWheel(callback: setOption)),
            SizedBox(
              child: PlatformIconButton(
                  onPressed: () => widget.onRemove(widget.key!),
                  icon: Icon(PlatformIcons(context).clear, color: Colors.red, size: 35)),
            )
          ]),
        ),
      ],
    );
  }
}
