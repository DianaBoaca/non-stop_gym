import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../widgets/users/busy_indicator.dart';
import '../../widgets/client/client_card.dart';
import '../../widgets/users/contact_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DocumentSnapshot<Map<String, dynamic>> _clientSnapshot;
  late DocumentSnapshot<Map<String, dynamic>> _contactSnapshot;
  late int _checkedInClients;
  late bool _isClient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot<Map<String, dynamic>> client = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    DocumentSnapshot<Map<String, dynamic>> statistics = await FirebaseFirestore
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
        _checkedInClients = statistics['checkedInClients'];
        _contactSnapshot = contact;
        _isClient = client['role'] == 'client';
        _isLoading = false;
      });
    }
  }

  Future<void> setNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'token': token});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        setNotifications();
        return _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: _isClient ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                children: [
                  if (_isClient) ClientCard(user: _clientSnapshot),
                  BusyIndicator(checkedInClients: _checkedInClients),
                  if (!_isClient) const SizedBox(height: 50),
                  ContactDetails(contactDetails: _contactSnapshot),
                ],
        );
      },
    );
  }
}
