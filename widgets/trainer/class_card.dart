import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/trainer/reserved_clients_list.dart';
import '../../utils/methods.dart';
import '../../utils/time_utils.dart';
import '../../utils/class_utils.dart';
import '../users/white_text.dart';

class ClassCard extends StatefulWidget {
  const ClassCard({super.key, required this.classSnapshot});

  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  Future<void> _cancelClass() async {
    try {
      widget.classSnapshot.reference.delete();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clasa a fost anulată.'),
        ),
      );

      QuerySnapshot<Map<String, dynamic>> waitingListSnapshot =
          await FirebaseFirestore.instance
              .collection('waitingList')
              .where('class', isEqualTo: widget.classSnapshot.reference)
              .get();

      for (QueryDocumentSnapshot waiting in waitingListSnapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await waiting['client'].get();

        if (userSnapshot.exists) {
          sendNotification(
            userSnapshot['token'],
            'Anulare clasă',
            'Clasa de ${widget.classSnapshot['className']} a fost anulată!',
          );
        }

        waiting.reference.delete();
      }

      QuerySnapshot<Map<String, dynamic>> reservationsSnapshot =
          await FirebaseFirestore.instance
              .collection('reservations')
              .where('class', isEqualTo: widget.classSnapshot.reference)
              .get();
      for (QueryDocumentSnapshot reservation in reservationsSnapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await reservation['client'].get();

        if (userSnapshot.exists) {
          sendNotification(
            userSnapshot['token'],
            'Anulare clasă',
            'Clasa de ${widget.classSnapshot['className']} a fost anulată!',
          );
        }

        reservation.reference.delete();
      }
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => ReservedClientsList(classSnapshot: widget.classSnapshot),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        color: colors[widget.classSnapshot['className']] ?? Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.classSnapshot['className'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      WhiteText(
                        text: formatter.format(widget.classSnapshot['date'].toDate()),
                      ),
                      const SizedBox(height: 8),
                      WhiteText(
                        text: '${formatterTime.format(widget.classSnapshot['start'].toDate())} - ${formatterTime.format(widget.classSnapshot['end'].toDate())}',
                      ),
                      const SizedBox(height: 8),
                      WhiteText(
                        text: 'Sala: ${widget.classSnapshot['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
                      ),
                      const SizedBox(height: 8),
                      WhiteText(
                        text: 'Persoane înscrise: ${widget.classSnapshot['reserved']}/${widget.classSnapshot['capacity']}',
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: const Text('Anulează'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Card(
                                margin: const EdgeInsets.all(20),
                                color: colors[widget.classSnapshot['className']],
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      WhiteText(
                                          text: 'Sunteți sigur că anulați clasa de ${widget.classSnapshot['className']}?',
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _cancelClass();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Da'),
                                          ),
                                          const SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Nu'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
