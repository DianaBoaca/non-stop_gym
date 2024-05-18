import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/methods.dart';
import '../../widgets/users/reservation_card.dart';
import '../../widgets/users/white_text.dart';
import 'package:rxdart/rxdart.dart';

class ReservationsListScreen extends StatelessWidget {
  const ReservationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> user = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> stream =
        Rx.combineLatest2(
      FirebaseFirestore.instance
          .collection('reservations')
          .where('client', isEqualTo: user)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots(),
      FirebaseFirestore.instance
          .collection('waitingList')
          .where('client', isEqualTo: user)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots(),
      (QuerySnapshot<Map<String, dynamic>> reservationsQuery,
          QuerySnapshot<Map<String, dynamic>> waitingListQuery) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> allReservations = [
          ...reservationsQuery.docs,
          ...waitingListQuery.docs
        ];

        allReservations.sort((a, b) => (a['end']).compareTo(b['end']));

        return allReservations;
      },
    );

    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        List<DocumentSnapshot<Map<String, dynamic>>> combinedDocs = snapshot.data ?? [];

        if (combinedDocs.isEmpty) {
          return const Center(
            child: WhiteText(text: 'Nu există rezervări viitoare!'),
          );
        }

        return ListView.builder(
          itemCount: combinedDocs.length,
          itemBuilder: (context, index) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: combinedDocs[index]['class'].get(),
              builder: (context, classSnapshot) {
                if (classSnapshot.connectionState == ConnectionState.waiting ||
                    !classSnapshot.hasData) {
                  return const SizedBox();
                }

                return FutureBuilder<int>(
                  future: calculatePosition(combinedDocs[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return const SizedBox();
                    }

                    return ReservationCard(
                      reservationRef: combinedDocs[index].reference,
                      classSnapshot: classSnapshot.data!,
                      position: snapshot.data!,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
