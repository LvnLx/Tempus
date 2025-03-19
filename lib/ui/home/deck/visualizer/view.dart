import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus/ui/home/deck/visualizer/view_model.dart';

class Visualizer extends StatelessWidget {
  final BoxConstraints constraints;

  const Visualizer({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) => Stack(children: [
        FittedBox(
            child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.onSurface),
              borderRadius: BorderRadius.circular(8.0)),
          child: SizedBox(
              height: constraints.maxHeight / 2,
              width: constraints.maxHeight / 2),
        )),
        AnimatedOpacity(
            opacity: context.watch<VisualizerViewModel>().isVisible &&
                    context.watch<VisualizerViewModel>().isVisualizerEnabled
                ? 1.0
                : 0.0,
            duration: context.watch<VisualizerViewModel>().isVisible
                ? Duration(seconds: 0)
                : Duration(milliseconds: 200),
            child: FittedBox(
                child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).colorScheme.primary),
              child: SizedBox(
                  height: constraints.maxHeight / 2,
                  width: constraints.maxHeight / 2),
            )))
      ]);
}
