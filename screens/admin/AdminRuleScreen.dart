import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'EditUser.dart';
import 'NewRule.dart';

class AdminRuleScreen extends StatefulWidget {
  const AdminRuleScreen({super.key});

  @override
  State<AdminRuleScreen> createState() => _AdminRuleScreenState();
}

class _AdminRuleScreenState extends State<AdminRuleScreen> {
  DocumentSnapshot<Map<String, dynamic>>? _deletedRule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reguli și sfaturi'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) {
                  return const NewRule();
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('rules').snapshots(),
        builder: (ctx, ruleSnapshots) {
          if (ruleSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rules = ruleSnapshots.data!.docs;

          if (!ruleSnapshots.hasData || rules.isEmpty) {
            return const Center(
              child: Text('Nu există reguli.'),
            );
          }

          if (ruleSnapshots.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(rules[index]),
              onDismissed: (direction) {
                _deletedRule = rules[index];
                rules[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Antrenorul a fost șters.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        rules[index].reference.set(_deletedRule!.data()!);
                        _deletedRule = null;
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
                    style: const TextStyle(fontSize: 15),
                  ),
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        return EditUser(user: rules[index].reference);
                      },
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