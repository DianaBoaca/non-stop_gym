import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/class_utils.dart';
import '../../utils/methods.dart';
import '../users/white_text.dart';

class ReservedClientsList extends StatelessWidget {
  const ReservedClientsList({super.key, required this.classSnapshot});

  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .where('class', isEqualTo: classSnapshot.reference)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data!.docs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        List<QueryDocumentSnapshot<Map<String, dynamic>>> reservations = snapshot.data!.docs;

        return Center(
          child: Card(
            margin: const EdgeInsets.all(10),
            color: colors[classSnapshot['className']] ?? Colors.blue,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  reservations.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: reservations.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<String>(
                              future: getUserName(reservations[index].data()['client']),
                              builder: (context, nameSnapshot) {
                                if (nameSnapshot.connectionState == ConnectionState.waiting
                                    || nameSnapshot.data!.isEmpty) {
                                  return const SizedBox();
                                }

                                if (nameSnapshot.hasError) {
                                  return const Center(
                                    child: Text('Eroare!'),
                                  );
                                }

                                return Row(
                                  children: [
                                    SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                    ),
                                    WhiteText(
                                      text: '${index + 1}. ${nameSnapshot.data}',
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      : const WhiteText(
                          text: 'Nu există înscrieri la această clasă!',
                        ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Închide'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
