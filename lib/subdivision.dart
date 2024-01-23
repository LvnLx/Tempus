import 'package:flutter/material.dart';

typedef SubdivisionCallback = void Function(Key key);

class Subdivision extends StatefulWidget {
  final SubdivisionCallback onRemove;

  const Subdivision({required Key key, required this.onRemove}) : super(key: key);

  @override
  _SubdivisionState createState() => _SubdivisionState();
}

class _SubdivisionState extends State<Subdivision> {
  bool _muted = false;
  double _volume = 0.5;

  void toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
          child: Icon(Icons.music_note_outlined),
        ),
        Expanded(
          child: Slider(
            value: _volume,
            onChanged: (double value) {
              setState(() {
                _volume = value;
              });
            },
          ),
        ),
        IconButton(
            onPressed: () => toggleMuted(),
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up)),
        IconButton(onPressed: () => {}, icon: Icon(Icons.settings)),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
          child: IconButton(
              onPressed: () => widget.onRemove(widget.key!),
              icon: Icon(Icons.close)),
        )
      ],
    );
  }
}
