import 'package:flutter/material.dart';

final List<int> emojis = [0x1F60A, 0x1F605, 0x1F633];
final List<String> texts = ['Lejer', 'Destul de aglomerat', 'Foarte aglomerat'];
final List<MaterialColor> colors = [Colors.green, Colors.yellow, Colors.red];

class BusyIndicator extends StatelessWidget {
  const BusyIndicator({
    super.key,
    required this.index,
    required this.percentage,
  });

  final int index;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${texts[index]} ${String.fromCharCode(emojis[index])}',
          style: TextStyle(
            fontSize: 25,
            color: colors[index],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * (percentage),
                    child: Container(
                      width: 5,
                      height: 30,
                      color: Colors.black,
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
