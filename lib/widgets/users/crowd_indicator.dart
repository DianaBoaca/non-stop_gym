import 'package:flutter/material.dart';

class CrowdIndicator extends StatefulWidget {
  const CrowdIndicator({
    super.key,
    required this.checkedInClients,
    required this.capacity,
  });

  final int checkedInClients;
  final int capacity;

  @override
  State<CrowdIndicator> createState() => _CrowdIndicatorState();
}

class _CrowdIndicatorState extends State<CrowdIndicator> {
  final List<int> _emojis = [0x1F60A, 0x1F605, 0x1F633];
  final List<String> _texts = [
    'Deloc aglomerat',
    'Aglomerat',
    'Foarte aglomerat'
  ];
  final List<MaterialColor> _colors = [Colors.green, Colors.yellow, Colors.red];
  double _percentage = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    setState(() {

      if (widget.checkedInClients >= widget.capacity) {
        _percentage = 0.99;
      } else {
        _percentage = widget.checkedInClients / widget.capacity;
      }

      if (_percentage <= 0.33) {
        _index = 0;
      } else if (_percentage <= 0.66) {
        _index = 1;
      } else {
        _index = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${_texts[_index]} ${String.fromCharCode(_emojis[_index])}',
          style: TextStyle(
            fontSize: 25,
            color: _colors[_index],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _colors,
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * _percentage,
                    child: Container(
                      width: 5,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
