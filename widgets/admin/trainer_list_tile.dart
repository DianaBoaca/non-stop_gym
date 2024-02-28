import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../edit_user.dart';

class TrainerListTile extends StatelessWidget {
  const TrainerListTile({super.key, required this.trainerQuery});

  final QueryDocumentSnapshot trainerQuery;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.fitness_center),
      title: Text(
        trainerQuery['lastName'] + ' ' + trainerQuery['firstName'],
        style: const TextStyle(fontSize: 20),
      ),
      subtitle: Row(
        children: [
          Text(
            trainerQuery['email'],
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 10),
          Text(
            trainerQuery['phone'],
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => EditUser(user: trainerQuery.reference),
        );
      },
    );
  }
}
