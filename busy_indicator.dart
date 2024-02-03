import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusyIndicator extends StatelessWidget {
  BusyIndicator({super.key});

  final List<int> emojis = [0x1F60A, 0x1F605, 0x1F633];
  final List<MaterialColor> colors = [Colors.green, Colors.yellow, Colors.red];
  final List<String> texts = ['Lejer', 'Destul de aglomerat', 'Foarte aglomerat'];

  @override
  Widget build(BuildContext context) {
    int checkedInClients;
    int index;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('statistics').doc('4WVH8oQxUkXv0bWq3pXn').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data == null) {
          checkedInClients = 0;
        } else {
          checkedInClients = snapshot.data!['checkedInClients'];
        }

        double percentage = checkedInClients / 50;
        if (percentage <= 0.33) {
          index = 0;
        } else if (percentage <= 0.66) {
          index = 1;
        } else {
          index = 2;
        }

        return Column(
          children: [
            Text(
              '${texts[index]} ${String.fromCharCode(emojis[index])}',
              style: TextStyle(
                fontSize: 25,
                color: colors[index],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16),
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
      },
    );
  }
}
