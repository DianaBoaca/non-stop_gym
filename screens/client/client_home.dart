import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/busy_indicator.dart';
import '../../widgets/client_card.dart';
import '../../widgets/contact_details.dart';

final FirebaseFirestore _firebase = FirebaseFirestore.instance;

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int checkedInClients;
    int index;

    return SingleChildScrollView(
      child: Column(
          children: [
            StreamBuilder(
                stream: _firebase.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.hasError) {
                    return const SizedBox();
                  }

                  return ClientCard(user: snapshot.data!);
                }),
            const SizedBox(height: 30),
            StreamBuilder(
              stream: _firebase.collection('statistics').doc('4WVH8oQxUkXv0bWq3pXn').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  checkedInClients = 0;
                  return const SizedBox();
                } else {
                  checkedInClients = snapshot.data!['checkedInClients'];
                }

                double percentage = checkedInClients / 50;
                if (percentage <= 0.33) {
                  index = 0;
                } else if (percentage <= 0.66) {
                  index = 1;
                } else {
                  index = 2;
                }

                return BusyIndicator(
                    index: index,
                    percentage: percentage
                );
              },
            ),
            StreamBuilder(
              stream: _firebase.collection('contact').doc('XZc7U6u8uXpXVJsO1hIK').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.hasError) {
                  return const SizedBox();
                }

                return ContactDetails(contactDetails: snapshot.data!);
              },
            ),
          ],
      ),
    );
  }
}
