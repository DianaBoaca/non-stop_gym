import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/methods.dart';
import 'white_text.dart';
import '../../utils/class_utils.dart';
import '../../utils/time_utils.dart';

class ReservationCard extends StatefulWidget {
  const ReservationCard({
    super.key,
    required this.reservationRef,
    required this.classSnapshot,
    required this.position,
  });

  final DocumentReference<Map<String, dynamic>> reservationRef;
  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;
  final int position;

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  Future<void> _cancelReservation() async {
    try {
      widget.reservationRef.delete();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervarea a fost anulată.'),
        ),
      );

      if (widget.position == 0) {
        upgradeFirstWaitingToReserved(widget.classSnapshot);
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Eroare stocare date.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    const SizedBox(height: 15),
                    WhiteText(
                      text: formatter.format(widget.classSnapshot['date'].toDate()),
                    ),
                    const SizedBox(height: 15),
                    WhiteText(
                      text: '${formatterTime.format(widget.classSnapshot['start'].toDate())} - ${formatterTime.format(widget.classSnapshot['end'].toDate())}',
                    ),
                    const SizedBox(height: 15),
                    WhiteText(
                      text: 'Sala: ${widget.classSnapshot['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
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
                                        text: 'Sunteți sigur că anulați rezervarea la ${widget.classSnapshot['className']}?',
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _cancelReservation();
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
            const SizedBox(height: 15),
            if (widget.position > 0)
              WhiteText(
                  text: 'Sunteți pe locul ${widget.position} în lista de așteptare!',
              ),
          ],
        ),
      ),
    );
  }
}
