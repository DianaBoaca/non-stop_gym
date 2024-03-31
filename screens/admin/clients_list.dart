import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/admin/user_list_tile.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedClient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clienți'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'client')
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

          List<QueryDocumentSnapshot<Map<String, dynamic>>> clients =
              snapshot.data!.docs;

          if (clients.isEmpty) {
            return const Center(
              child: Text('Nu există clienți.'),
            );
          }

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(clients[index]),
              onDismissed: (direction) {
                deletedClient = clients[index];
                clients[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Clientul a fost șters.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        clients[index].reference.set(deletedClient!.data()!);
                        deletedClient = null;
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: UserListTile(userSnapshot: clients[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
