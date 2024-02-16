import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/client/reservation_card.dart';
import '../../widgets/client/white_text.dart';

class ReservationsListScreen extends StatelessWidget {
  const ReservationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('client', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('end', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('end')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: WhiteText(text: 'Nu există rezervări viitoare!'),
            );
          }

          final reservations = snapshot.data!.docs;

          if (snapshot.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: reservations[index]['class'].get(),
                builder: (context, classSnapshot) {
                  if (!classSnapshot.hasData || classSnapshot.data == null) {
                    return const SizedBox();
                  }

                  return ReservationCard(
                    reservationSnapshot: reservations[index],
                    classSnapshot: classSnapshot.data!,
                  );
                  },
              );
            }
            );
        }
        );
  }
}
