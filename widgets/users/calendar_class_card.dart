import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/users/white_text.dart';
import '../../utils/class_utils.dart';

class CalendarClassCard extends StatefulWidget {
  const CalendarClassCard({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  @override
  State<CalendarClassCard> createState() => _CalendarClassCardState();
}

class _CalendarClassCardState extends State<CalendarClassCard> {
  bool _alreadyReserved = false;
  bool _isWaiting = false;
  bool _isLoading = true;
  bool _hasPassed = false;
  bool _isMyClass = false;
  String _trainerName = '';

  void _reserveClass() async {
    DocumentSnapshot<Map<String, dynamic>> classSnapshot =
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.fitnessClass.id)
            .get();
    Map<String, dynamic> classMap = classSnapshot.data()!;
    QuerySnapshot<Map<String, dynamic>> existingReservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('client', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where('date', isEqualTo: classMap['date'])
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
                classMap['date'].toDate(),
                convertToTimeOfDay(classMap['start']),
                convertToTimeOfDay(classMap['end'])) ==
            false) {
          _showMessage();
          return;
        }
      } else {
        if (await verifyHours(
                '',
                existingReservations.docs,
                classMap['date'].toDate(),
                convertToTimeOfDay(classMap['start']),
                convertToTimeOfDay(classMap['end'])) ==
            false) {
          _showMessage();
          return;
        }
      }

      if (classMap['reserved'] < classMap['capacity']) {
        await FirebaseFirestore.instance.collection('reservations').add({
          'class': classSnapshot.reference,
          'client': userSnapshot.reference,
          'date': classMap['date'],
          'start': classMap['start'],
          'end': classMap['end'],
        });

        await classSnapshot.reference
            .update({'reserved': FieldValue.increment(1)});

        setState(() {
          _alreadyReserved = true;
        });
      } else {
        await FirebaseFirestore.instance.collection('waitingList').add({
          'class': classSnapshot.reference,
          'client': userSnapshot.reference,
          'time': DateTime.now(),
          'start': classMap['start'],
          'end': classMap['end'],
        });

        setState(() {
          _isWaiting = true;
        });
      }
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _showMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sunteți înscris la o altă clasă în acest interval!'),
      ),
    );
  }

  void _loadData() async {
    DocumentReference<Map<String, dynamic>> classRef = FirebaseFirestore
        .instance
        .collection('classes')
        .doc(widget.fitnessClass.id);
    QuerySnapshot<Map<String, dynamic>> existingReservations =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('class', isEqualTo: classRef)
            .where('client', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();
    QuerySnapshot<Map<String, dynamic>> waitingReservations =
        await FirebaseFirestore.instance
            .collection('waitingList')
            .where('class', isEqualTo: classRef)
            .where('client', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();
    String name = await getUserName(widget.fitnessClass.trainer);
    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _alreadyReserved = existingReservations.docs.isNotEmpty;
      _isWaiting = waitingReservations.docs.isNotEmpty;
      _hasPassed = widget.fitnessClass.start.isBefore(DateTime.now());
      _isMyClass = widget.fitnessClass.trainer == userRef;
      _trainerName = name;
      _isLoading = false;
    });
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
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(20),
          color: widget.fitnessClass.color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const CircularProgressIndicator()
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .doc(widget.fitnessClass.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      return Column(
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
                              text: formatter
                                  .format(snapshot.data!['date'].toDate())),
                          const SizedBox(height: 10),
                          WhiteText(
                            text:
                                '${formatterTime.format(snapshot.data!['start'].toDate())} - ${formatterTime.format(snapshot.data!['end'].toDate())}',
                          ),
                          const SizedBox(height: 10),
                          WhiteText(text: 'Antrenor: $_trainerName'),
                          const SizedBox(height: 10),
                          WhiteText(
                              text:
                                  'Sala: ${snapshot.data!['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}'),
                          const SizedBox(height: 10),
                          WhiteText(
                              text:
                                  'Persoane înscrise: ${snapshot.data!['reserved']}/${snapshot.data!['capacity']}'),
                          const SizedBox(height: 15),
                          if (!_alreadyReserved &&
                              !_isWaiting &&
                              !_hasPassed &&
                              !_isMyClass)
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
                      );
                    }),
          ),
        ),
      ),
    );
  }
}
