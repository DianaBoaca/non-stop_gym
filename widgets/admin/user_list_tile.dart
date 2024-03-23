import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../edit_user.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({super.key, required this.userSnapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        userSnapshot['role'] == 'trainer' ? Icons.fitness_center : Icons.person,
      ),
      title: Text(
        userSnapshot['lastName'] + ' ' + userSnapshot['firstName'],
        style: const TextStyle(fontSize: 20),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            userSnapshot['email'],
            style: const TextStyle(fontSize: 15),
          ),
          Text(
            userSnapshot['phone'],
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
          builder: (context) => EditUser(userRef: userSnapshot.reference),
        );
      },
    );
  }
}
