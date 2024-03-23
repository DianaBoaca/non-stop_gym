import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/admin/user_list_tile.dart';
import 'package:non_stop_gym/widgets/edit_user.dart';

class TrainersListScreen extends StatelessWidget {
  const TrainersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedTrainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenori'),
        actions: [
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
        ],
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'trainer')
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

          List<QueryDocumentSnapshot<Map<String, dynamic>>> trainers = snapshot.data!.docs;

          if (trainers.isEmpty) {
            return const Center(
              child: Text('Nu există antrenori.'),
            );
          }

          return ListView.builder(
            itemCount: trainers.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(trainers[index]),
              onDismissed: (direction) {
                deletedTrainer = trainers[index];
                trainers[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Antrenorul a fost șters.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        trainers[index].reference.set(deletedTrainer!.data()!);
                        deletedTrainer = null;
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: UserListTile(userSnapshot: trainers[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
