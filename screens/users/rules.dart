import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rules')
          .orderBy('title')
          .snapshots(),
      builder: (ctx, snapshot) {
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

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Nu există reguli.'),
          );
        }

        final rules = snapshot.data!.docs;

        return ListView.builder(
          itemCount: rules.length,
          itemBuilder: (ctx, index) => Card(
            elevation: 3,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(
                Icons.rule,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                rules[index].data()['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              subtitle: Text(
                rules[index].data()['text'],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        );
      },
    );
  }
}
