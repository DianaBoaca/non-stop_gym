import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

DocumentReference<Map<String, dynamic>> firebase = FirebaseFirestore.instance.collection('statistics').doc('4WVH8oQxUkXv0bWq3pXn');

class ClientCard extends StatefulWidget {
  const ClientCard({super.key});

  @override
  State<ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  late bool _checkedIn;
  final String _checkInTimeKey = 'checkInTime';
  late Timer _timer;

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.',),
      ),
    );
  }

  void _showMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:  Text('Check-${_checkedIn ? 'in' : 'out'} înregistrat.'),
      ),
    );
  }

  void _automaticCheckOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? checkInTime = prefs.getInt(_checkInTimeKey);

    if (_checkedIn && checkInTime != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedTime = currentTime - checkInTime;

      if (elapsedTime >= 2 * 60 * 60 * 1000) {
        _timer.cancel();
        _checkIn();
      }
    }
  }

  void _checkIn() async {
    setState(() {
      _checkedIn = !_checkedIn;
    });

    try {
      await firebase.update({
        'checkedInClients': _checkedIn ? FieldValue.increment(1) : FieldValue.increment(-1),
      });

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'checkedIn': _checkedIn,
      });

    } on FirebaseException catch (error) {
      _showError(error);
      return;
    }

    _showMessage();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_checkedIn) {
      prefs.setInt(_checkInTimeKey, DateTime.now().millisecondsSinceEpoch);
      _timer = Timer.periodic(const Duration(hours: 2), (Timer timer) {
        _automaticCheckOut();
      });
    }
  }

  void _loadData() async {
    DocumentSnapshot<Object?> userData = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();

    if (userData.exists) {
      Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;

      setState(() {
        _checkedIn = userDataMap['checkedIn'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   User user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting && snapshot.hasData) {
          return FlipCard(
            fill: Fill.fillBack,
            side: CardSide.FRONT,
            speed: 1000,
            front: Card(
              margin: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: QrImageView(
                        data: user.uid,
                        backgroundColor: Colors.white,
                        size: 150,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            snapshot.data!['lastName'] + ' ' + snapshot.data!['firstName'],
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 23,
                            ),
                          ),
                          Text(
                            snapshot.data!['id'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            back: Card(
              margin: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: OutlinedButton(
                    onPressed: _checkIn,
                    child: const Text(
                      'Scanează',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
