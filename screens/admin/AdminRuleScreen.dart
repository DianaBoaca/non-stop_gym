import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/screens/admin/EditRule.dart';
import 'NewRule.dart';

class AdminRuleScreen extends StatelessWidget {
  const AdminRuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedRule;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reguli și sfaturi'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const NewRule(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
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

          final rules = snapshot.data!.docs;

          if (!snapshot.hasData || rules.isEmpty) {
            return const Center(
              child: Text('Nu există reguli.'),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(rules[index]),
              onDismissed: (direction) {
                deletedRule = rules[index];
                rules[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Antrenorul a fost șters.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        rules[index].reference.set(deletedRule!.data()!);
                        deletedRule = null;
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.rule),
                  title: Text(
                    rules[index].data()['title'],
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    rules[index].data()['text'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => EditRule(rule: rules[index].reference),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
