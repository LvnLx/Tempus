import 'package:flutter/widgets.dart';

class TimeSignature extends StatelessWidget {
  const TimeSignature({super.key});

  @override
  Widget build(BuildContext context) => FittedBox(
        child: Column(children: [
          Text("4", style: TextStyle()),
          Text("4", style: TextStyle(height: 0.65))
        ]),
      );
}
