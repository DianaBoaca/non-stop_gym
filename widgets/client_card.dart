import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientCard extends StatefulWidget {
  const ClientCard({super.key});

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting && snapshot.hasData) {
          return FlipCard(
            fill: Fill.fillBack,
            side: CardSide.FRONT,
            speed: 1000,
            front: Card(
              margin: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: QrImageView(
                        data: user.uid,
                        backgroundColor: Colors.white,
                        size: 150,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            snapshot.data!['lastName'] + ' ' + snapshot.data!['firstName'],
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 23,
                            ),
                          ),
                          Text(
                            snapshot.data!['id'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            back: const Placeholder(),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
