import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/edit_user.dart';
import '../../widgets/admin/new_trainer.dart';

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
                builder: (context) => const NewTrainer(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
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

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nu există antrenori.'),
            );
          }

          final trainers = snapshot.data!.docs;

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
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(
                    trainers[index].data()['lastName'] +
                        ' ' +
                        trainers[index].data()['firstName'],
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        trainers[index].data()['email'],
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        trainers[index].data()['phone'],
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
                      builder: (context) =>
                          EditUser(user: trainers[index].reference),
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
