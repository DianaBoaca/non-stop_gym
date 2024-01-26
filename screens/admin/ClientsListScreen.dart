import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'EditUser.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  DocumentSnapshot<Map<String, dynamic>>? _deletedClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clienți'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'client').orderBy('lastName').snapshots(),
        builder: (ctx, clientSnapshot) {
          if (clientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final clients = clientSnapshot.data!.docs;

          if (!clientSnapshot.hasData || clients.isEmpty) {
            return const Center(
              child: Text('Nu există clienți.'),
            );
          }

          if (clientSnapshot.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(clients[index]),
              onDismissed: (direction) {
                _deletedClient = clients[index];
                clients[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Clientul a fost șters.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        clients[index].reference.set(_deletedClient!.data()!);
                        _deletedClient = null;
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    clients[index].data()['lastName'] + ' ' + clients[index].data()['firstName'],
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        clients[index].data()['email'],
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        clients[index].data()['phone'],
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (ctx) {
                        return EditUser(user: clients[index].reference);
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