import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/admin/edit_rule.dart';
import '../../widgets/admin/rule_list_tile.dart';

class AdminRuleScreen extends StatelessWidget {
  const AdminRuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedRule;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regulament'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const EditRule(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(rules[index]),
              onDismissed: (direction) {
                deletedRule = rules[index];
                rules[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Regula a fost ștearsă.'),
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
              child: RuleListTile(
                ruleSnapshot: rules[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
