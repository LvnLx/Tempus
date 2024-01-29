import 'package:flutter/material.dart';
import 'package:metronomic/audio.dart';

typedef SubdivisionCallback = void Function(Key key);

const List<String> subdivisionOptions = [
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9'
];

class Subdivision extends StatefulWidget {
  final SubdivisionCallback onRemove;

  Subdivision({required Key key, required this.onRemove}) : super(key: key);

  @override
  SubdivisionState createState() => SubdivisionState();
}

class SubdivisionState extends State<Subdivision> {
  bool _muted = true;
  double _volume = 0.5;
  String subdivisionOption = subdivisionOptions[0];

  void toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: DropdownButton(
                    isExpanded: true,
                    iconSize: 0,
                    underline: Container(),
                    value: subdivisionOption,
                    items: subdivisionOptions
                        .map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem(
                          value: option,
                          child: Center(
                            child: Text(
                              option,
                              style: (TextStyle(
                                  fontSize: 32,
                                  color: _muted ? Colors.grey : Colors.white)),
                              textAlign: TextAlign.center,
                            ),
                          ));
                    }).toList(),
                    onChanged: (String? option) {
                      setState(() {
                        subdivisionOption = option!;
                      });
                    },
                  )),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Slider(
                activeColor: _muted ? Colors.grey : Colors.white,
                value: _volume,
                onChanged: (double value) {
                  setState(() {
                    _volume = value;
                  });
                  Audio.setSubdivisionVolume(widget.key!, value);
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: IconButton(
                onPressed: () => toggleMuted(),
                icon: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  size: 32,
                ),
                color: _muted ? Colors.red : Colors.white,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: IconButton(
                  onPressed: () => widget.onRemove(widget.key!),
                  icon: Icon(Icons.close, size: 32),
                  color: Colors.red,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
