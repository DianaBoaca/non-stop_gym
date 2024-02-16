import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../widgets/client/busy_indicator.dart';
import '../../widgets/client/client_card.dart';
import '../../widgets/client/contact_details.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  late DocumentSnapshot<Map<String, dynamic>> _clientSnapshot;
  late DocumentSnapshot<Map<String, dynamic>> _contactSnapshot;
  late DocumentSnapshot<Map<String, dynamic>> _indicatorSnapshot;
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

    setState(() {
      _clientSnapshot = client;
      _indicatorSnapshot = indicator;
      _contactSnapshot = contact;
      _isLoading = false;
    });
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
        : SingleChildScrollView(
            child: Column(
              children: [
                ClientCard(user: _clientSnapshot),
                const SizedBox(height: 30),
                BusyIndicator(statistics: _indicatorSnapshot),
                const SizedBox(height: 15),
                ContactDetails(contactDetails: _contactSnapshot),
              ],
            ),
          );
  }
}
