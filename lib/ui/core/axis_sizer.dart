import 'package:flutter/widgets.dart';

class AxisSizedBox extends StatelessWidget {
  final Widget child;
  final Axis reference;

  const AxisSizedBox({super.key, required this.child, required this.reference});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, constraints) => SizedBox(
            height: reference == Axis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth,
            width: reference == Axis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth,
            child: child,
          ));
}
