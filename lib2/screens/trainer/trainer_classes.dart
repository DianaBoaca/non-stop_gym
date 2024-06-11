import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/trainer/class_card.dart';
import '../../widgets/users/white_text.dart';

class MyClassesListScreen extends StatelessWidget {
  const MyClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .where('trainer', isEqualTo: userRef)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        List<QueryDocumentSnapshot<Map<String, dynamic>>> classes = snapshot.data!.docs;

        if (classes.isEmpty) {
          return const Center(
            child: WhiteText(text: 'Nu există clase viitoare!'),
          );
        }

        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return ClassCard(classSnapshot: classes[index]);
          },
        );
      },
    );
  }
}
