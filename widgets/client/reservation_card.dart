import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'white_text.dart';
import '../../utils/ClassUtils.dart';

class ReservationCard extends StatefulWidget {
  const ReservationCard({super.key, required this.reservationSnapshot, required this.classSnapshot});

  final DocumentSnapshot<Map<String, dynamic>> reservationSnapshot;
  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  void _cancelClass() {
    DocumentSnapshot<Map<String, dynamic>>? canceledReservation;

    try {
      canceledReservation = widget.reservationSnapshot;
      widget.reservationSnapshot.reference.delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rezervarea a fost anulată.'),
          action: SnackBarAction(
            label: 'Anulați',
            onPressed: () {
              widget.reservationSnapshot.reference.set(canceledReservation!.data()!);
              canceledReservation = null;
              widget.classSnapshot.reference.update({'reserved': FieldValue.increment(1)});
            },
          ),
        ),
      );

      widget.classSnapshot.reference.update({'reserved': FieldValue.increment(-1)});
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: colors[widget.classSnapshot['className']],
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
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
                const SizedBox(height: 15),
                WhiteText(
                  text: '${formatter.format(widget.classSnapshot['date'].toDate())}   ${formatterTime.format(widget.classSnapshot['end'].toDate())}',
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _cancelClass();
              },
              child: const Text('Anulează'),
            ),
          ],
        ),
      ),
    );
  }
}