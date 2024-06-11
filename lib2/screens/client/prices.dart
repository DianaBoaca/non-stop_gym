import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => PriceScreenState();
}

class PriceScreenState extends State<PriceScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult.single != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: !_isConnected
            ? const CircularProgressIndicator()
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('contact')
                    .doc('XZc7U6u8uXpXVJsO1hIK')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data!.data()!.isEmpty) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Eroare!');
                  }

                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.network(snapshot.data!['tarife']),
                  );
                },
              ),
    );
  }
}
