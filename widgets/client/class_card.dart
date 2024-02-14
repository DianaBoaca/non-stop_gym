import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/client/white_text.dart';
import '../../utils/ClassUtils.dart';

class ClassCard extends StatefulWidget {
  const ClassCard({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  bool _alreadyReserved = false;
  bool _isWaiting = false;
  bool _isLoading = true;
  String _trainer = '';

  void _reserveClass() async {
    DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    DocumentReference<Map<String, dynamic>> classRef = FirebaseFirestore
        .instance
        .collection('classes')
        .doc(widget.fitnessClass.id);
    DocumentSnapshot<Map<String, dynamic>> classSnapshot = await classRef.get();
    Map<String, dynamic> classMap = classSnapshot.data()!;
    Query<Map<String, dynamic>> existingClasses = FirebaseFirestore.instance
        .collection('reservations')
        .where('client', isEqualTo: userRef)
        .where('date', isEqualTo: classMap['date']);

    try {
      if(await verifyHours(existingClasses, classMap['date'].toDate(), convertToTimeOfDay(classMap['start']), convertToTimeOfDay(classMap['end'])) == false) {
        _showMessage();
      } else if (classMap['reserved'] < classMap['capacity']) {
        await FirebaseFirestore.instance.collection('reservations').add({
          'class': classRef,
          'client': FirebaseAuth.instance.currentUser!.uid,
          'date': classMap['date'],
          'start': classMap['start'],
          'end': classMap['end'],
        });

        await classRef.update({'reserved': FieldValue.increment(1)});

        setState(() {
          _alreadyReserved = true;
        });
      } else {
        await FirebaseFirestore.instance.collection('waitingList').add({
          'class': classRef,
          'client': FirebaseAuth.instance.currentUser!.uid,
          'time': DateTime.now(),
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
    String name = await getTrainerName(widget.fitnessClass.trainer);

    setState(() {
      _alreadyReserved = existingReservations.docs.isNotEmpty;
      _isWaiting = waitingReservations.docs.isNotEmpty;
      _trainer = name;
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
                  stream: FirebaseFirestore
                      .instance
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
                              text: formatter.format(snapshot.data!['date'].toDate())),
                          const SizedBox(height: 10),
                          WhiteText(
                            text:
                                '${formatterTime.format(snapshot.data!['start'].toDate())} - ${formatterTime.format(snapshot.data!['end'].toDate())}',
                          ),
                          const SizedBox(height: 10),
                          WhiteText(text: 'Antrenor: $_trainer'),
                          const SizedBox(height: 10),
                          WhiteText(text: 'Sala: ${snapshot.data!['room'] =='Room.aerobic' ? 'Aerobic' : 'Functional'}'),
                          const SizedBox(height: 10),
                          WhiteText(
                              text:
                                  'Persoane înscrise: ${snapshot.data!['reserved']}/${snapshot.data!['capacity']}'),
                          const SizedBox(height: 15),
                          if (!_alreadyReserved && !_isWaiting)
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
                  }
                ),
          ),
        ),
      ),
    );
  }
}
