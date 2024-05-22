import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/admin/user_list_tile.dart';
import 'package:non_stop_gym/widgets/edit_user.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key, required this.showTrainers});

  final bool showTrainers;

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(showTrainers ? 'Antrenori' : 'Clienti'),
        actions: showTrainers ? [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const EditUser(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ]
            : [],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: showTrainers ? 'trainer' : 'client')
            .orderBy('lastName')
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

          List<QueryDocumentSnapshot<Map<String, dynamic>>> users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(
              child: Text(
                'Nu există ${showTrainers ? 'antrenori' : 'clienți'}.',
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(users[index]),
              onDismissed: (direction) {
                deletedUser = users[index];
                users[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${showTrainers ? 'Antrenorul' : 'Clientul'} a fost șters.',
                    ),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        users[index].reference.set(deletedUser!.data()!);
                        deletedUser = null;
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: UserListTile(userSnapshot: users[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
