import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: QrImageView(
                data: FirebaseAuth.instance.currentUser!.uid,
              ),
            ),
            const SizedBox(width: 50),
            const Column(
              children: [
                Text('Nume client'),
                Text('Id client'),
                Text('Data exp'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}