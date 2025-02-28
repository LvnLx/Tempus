import 'package:flutter/widgets.dart';

class ScaledPadding extends StatelessWidget {
  final Widget child;
  final double scale;

  const ScaledPadding({super.key, required this.child, this.scale = 0.6});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, constraints) => Center(
            child: SizedBox(
                height: constraints.maxHeight * scale,
                width: constraints.maxWidth * scale,
                child: FittedBox(child: child)),
          ));
}
