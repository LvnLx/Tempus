import 'package:flutter/widgets.dart';

enum ReferenceAxis { horizontal, vertical }

class AxisSizedBox extends StatelessWidget {
  final Widget child;
  final ReferenceAxis reference;

  const AxisSizedBox({super.key, required this.child, required this.reference});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, constraints) => SizedBox(
            height: reference == ReferenceAxis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth,
            width: reference == ReferenceAxis.vertical
                ? constraints.maxHeight
                : constraints.maxWidth,
            child: child,
          ));
}
