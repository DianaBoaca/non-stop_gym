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
        leading: Icon(
          Icons.rule,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          ruleSnapshot['title'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlueAccent,
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
