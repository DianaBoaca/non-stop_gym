import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/users/white_text.dart';
import '../../utils/class_utils.dart';
import '../../utils/methods.dart';
import '../../utils/time_utils.dart';

class CalendarClassCard extends StatefulWidget {
  const CalendarClassCard({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  @override
  State<CalendarClassCard> createState() => _CalendarClassCardState();
}

class _CalendarClassCardState extends State<CalendarClassCard> {
  bool _alreadyReserved = false;
  bool _isWaiting = false;
  bool _isLoading = false;
  bool _hasPassed = false;
  bool _isMyClass = false;
  String _trainerName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentReference<Map<String, dynamic>> classRef = FirebaseFirestore
        .instance
        .collection('classes')
        .doc(widget.fitnessClass.id);
    QuerySnapshot<Map<String, dynamic>> existingReservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('class', isEqualTo: classRef)
            .where('client', isEqualTo: userRef)
            .get();
    QuerySnapshot<Map<String, dynamic>> waitingReservations =
        await FirebaseFirestore.instance
            .collection('waitingList')
            .where('class', isEqualTo: classRef)
            .where('client', isEqualTo: userRef)
            .get();
    String name = await getUserName(widget.fitnessClass.trainer);

    setState(() {
      _alreadyReserved = existingReservations.docs.isNotEmpty;
      _isWaiting = waitingReservations.docs.isNotEmpty;
      _hasPassed = widget.fitnessClass.start.isBefore(DateTime.now());
      _isMyClass = widget.fitnessClass.trainer == userRef;
      _trainerName = name;
      _isLoading = false;
    });
  }

  Future<void> _reserveClass() async {
    DocumentSnapshot<Map<String, dynamic>> classSnapshot =
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.fitnessClass.id)
            .get();
    QuerySnapshot<Map<String, dynamic>> existingReservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('client', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('date', isEqualTo: classSnapshot['date'])
            .get();
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    try {
      if (userSnapshot['role'] == 'trainer') {
        if (await verifyTrainerAvailability(
            '',
            userSnapshot.reference,
            classSnapshot['date'].toDate(),
            convertToTimeOfDay(classSnapshot['start']),
            convertToTimeOfDay(classSnapshot['end']))
            == false) {
          _showMessage('Sunteți înscris la o altă clasă în acest interval!');
          return;
        }
      } else {
        if (await verifyHours(
            '',
            existingReservations.docs,
            classSnapshot['date'].toDate(),
            convertToTimeOfDay(classSnapshot['start']),
            convertToTimeOfDay(classSnapshot['end']))
            == false) {
          _showMessage('Sunteți înscris la o altă clasă în acest interval!');
          return;
        }
      }

      if (classSnapshot['reserved'] < classSnapshot['capacity']) {
        await FirebaseFirestore.instance.collection('reservations').add({
          'class': classSnapshot.reference,
          'client': userSnapshot.reference,
          'date': classSnapshot['date'],
          'start': classSnapshot['start'],
          'end': classSnapshot['end'],
        });

        await classSnapshot.reference.update({'reserved': FieldValue.increment(1)});

        setState(() {
          _alreadyReserved = true;
        });
      } else {
        await FirebaseFirestore.instance.collection('waitingList').add({
          'class': classSnapshot.reference,
          'client': userSnapshot.reference,
          'date': classSnapshot['date'],
          'start': classSnapshot['start'],
          'end': classSnapshot['end'],
          'time': DateTime.now(),
        });

        setState(() {
          _isWaiting = true;
        });
      }
    } on FirebaseException catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String? message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Eroare'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.fitnessClass.id)
            .snapshots(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(20),
              color: widget.fitnessClass.color,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          Text(
                            widget.fitnessClass.className,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          WhiteText(
                            text: formatter.format(widget.fitnessClass.date),
                          ),
                          const SizedBox(height: 10),
                          WhiteText(
                            text: '${formatterTime.format(widget.fitnessClass.start)} - ${formatterTime.format(widget.fitnessClass.end)}',
                          ),
                          const SizedBox(height: 10),
                          WhiteText(text: 'Antrenor: $_trainerName'),
                          const SizedBox(height: 10),
                          WhiteText(
                            text: 'Sala: ${widget.fitnessClass.room == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
                          ),
                          const SizedBox(height: 10),
                          WhiteText(
                            text: 'Persoane înscrise: ${snapshot.data!['reserved']}/${widget.fitnessClass.capacity}',
                          ),
                          const SizedBox(height: 15),
                          if (!_alreadyReserved && !_isWaiting && !_hasPassed && !_isMyClass)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Înapoi'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _reserveClass();
                                  },
                                  child: const Text('Rezervă'),
                                ),
                              ],
                            ),
                          if (_alreadyReserved || _isWaiting)
                            Text(
                              _alreadyReserved
                                  ? 'Rezervare confirmată!'
                                  : 'Sunteți pe lista de așteptare!',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlueAccent,
                                fontSize: 20,
                              ),
                            ),
                        ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
