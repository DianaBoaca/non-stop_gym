import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/users/rule_card.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('rules')
          .orderBy('title')
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

        List<QueryDocumentSnapshot<Map<String, dynamic>>> rules = snapshot.data!.docs;

        if (rules.isEmpty) {
          return const Center(
            child: Text('Nu există reguli.'),
          );
        }

        return ListView.builder(
          itemCount: rules.length,
          itemBuilder: (context, index) => RuleCard(ruleSnapshot: rules[index]),
        );
      },
    );
  }
}
