import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PriceScreen extends StatelessWidget {
  const PriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('contact')
            .doc('XZc7U6u8uXpXVJsO1hIK')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data!.data()!.isEmpty) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return const Text('Eroare!');
          }

          return Padding(
            padding: const EdgeInsets.all(15),
            child: Image.network(
              snapshot.data!['tarife'],
            ),
          );
        },
      ),
    );
  }
}
