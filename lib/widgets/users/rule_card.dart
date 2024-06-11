import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RuleCard extends StatelessWidget {
  const RuleCard({
    super.key,
    required this.ruleSnapshot,
  });

  final DocumentSnapshot<Map<String, dynamic>> ruleSnapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(
          Icons.rule,
          color: Color.fromARGB(255, 156, 124, 222),
        ),
        title: Text(
          ruleSnapshot['title'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          ruleSnapshot['text'],
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        tileColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
