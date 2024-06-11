import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_rule.dart';

class RuleListTile extends StatelessWidget {
  const RuleListTile({super.key, required this.ruleSnapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> ruleSnapshot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(
          Icons.rule,
          color: Color.fromARGB(255, 156, 124, 222),
        ),
        title: Text(
          ruleSnapshot['title'],
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          ruleSnapshot['text'],
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => EditRule(ruleRef: ruleSnapshot.reference),
          );
        },
      ),
    );
  }
}
