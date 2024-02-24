import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/client/reservation_card.dart';
import '../../widgets/client/white_text.dart';
import 'package:rxdart/rxdart.dart';

class ReservationsListScreen extends StatelessWidget {
  const ReservationsListScreen({super.key});

  Future<int> calculatePosition(
    DocumentSnapshot<Map<String, dynamic>> reservationsSnapshot,
  ) async {
    QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
        .collection('waitingList')
        .orderBy('time')
        .get();

    if (query.docs
        .every((doc) => doc.reference != reservationsSnapshot.reference)) {
      return 0;
    }

    List<QueryDocumentSnapshot<Map<String, dynamic>>> waitingListDocs =
        query.docs;
    int position = waitingListDocs
        .indexWhere((doc) => doc.reference == reservationsSnapshot.reference);

    return position + 1;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    Stream<List<QueryDocumentSnapshot>> stream = Rx.combineLatest2(
      FirebaseFirestore.instance
          .collection('reservations')
          .where('client', isEqualTo: uid)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots(),
      FirebaseFirestore.instance
          .collection('waitingList')
          .where('client', isEqualTo: uid)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots(),
      (QuerySnapshot reservationsQuery, QuerySnapshot waitingListQuery) {
        List<QueryDocumentSnapshot> allReservations = [
          ...reservationsQuery.docs,
          ...waitingListQuery.docs
        ];
        allReservations.sort((a, b) => (a['end']).compareTo(b['end']));
        return allReservations;
      },
    );

    return StreamBuilder<List<DocumentSnapshot>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final combinedDocs = snapshot.data ?? [];

          if (combinedDocs.isEmpty) {
            return const Center(
              child: WhiteText(text: 'Nu există rezervări viitoare!'),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
              itemCount: combinedDocs.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: combinedDocs[index]['class'].get(),
                  builder: (context, classSnapshot) {
                    if (!classSnapshot.hasData ||
                        classSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const SizedBox();
                    }

                    return FutureBuilder<int>(
                      future: calculatePosition(combinedDocs[index]
                          as DocumentSnapshot<Map<String, dynamic>>),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        return ReservationCard(
                            reservationSnapshot: combinedDocs[index]
                                as DocumentSnapshot<Map<String, dynamic>>,
                            classSnapshot: classSnapshot.data!,
                            position: snapshot.data!);
                      },
                    );
                  },
                );
              });
        });
  }
}
