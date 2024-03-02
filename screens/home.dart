import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../widgets/client/busy_indicator.dart';
import '../widgets/client/client_card.dart';
import '../widgets/client/client_contact_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DocumentSnapshot<Map<String, dynamic>> _clientSnapshot;
  late DocumentSnapshot<Map<String, dynamic>> _contactSnapshot;
  late DocumentSnapshot<Map<String, dynamic>> _indicatorSnapshot;
  late bool _isClient;
  bool _isLoading = true;

  Future<void> _loadData() async {
    DocumentSnapshot<Map<String, dynamic>> client = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    DocumentSnapshot<Map<String, dynamic>> indicator = await FirebaseFirestore
        .instance
        .collection('statistics')
        .doc('4WVH8oQxUkXv0bWq3pXn')
        .get();
    DocumentSnapshot<Map<String, dynamic>> contact = await FirebaseFirestore
        .instance
        .collection('contact')
        .doc('XZc7U6u8uXpXVJsO1hIK')
        .get();

    if (mounted) {
      setState(() {
        _clientSnapshot = client;
        _indicatorSnapshot = indicator;
        _contactSnapshot = contact;
        _isClient = client['role'] == 'client';
        _isLoading = false;
      });
    }
  }

  void _setNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'token': token});
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _setNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isClient) ClientCard(user: _clientSnapshot),
              BusyIndicator(statistics: _indicatorSnapshot),
              ContactDetails(contactDetails: _contactSnapshot),
            ],
          );
  }
}
