import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/ui/core/axis_sizer.dart';

class FixedChannel extends StatefulWidget {
  final double initialVolume;
  final Widget child;
  final Future<void> Function(double) sliderCallback;

  const FixedChannel(
      {super.key,
      required this.initialVolume,
      required this.child,
      required this.sliderCallback});

  @override
  State<StatefulWidget> createState() => _FixedChannelState();
}

class _FixedChannelState extends State<FixedChannel> {
  late ValueNotifier<double> volume;

  @override
  void initState() {
    volume = ValueNotifier(widget.initialVolume);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            flex: 5,
            child: RotatedBox(
                quarterTurns: 3,
                child: PlatformSlider(
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (double value) async {
                      await widget.sliderCallback(value);
                      volume.value = value;
                    },
                    value: volume.value))),
        Expanded(
            child: AxisSizedBox(reference: Axis.vertical, child: widget.child))
      ]);
}
