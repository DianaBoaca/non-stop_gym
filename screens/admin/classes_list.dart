import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/admin/class_list_tile.dart';
import 'package:non_stop_gym/widgets/admin/edit_class.dart';
import '../../utils/methods.dart';

class ClassesListScreen extends StatelessWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot<Map<String, dynamic>>? deletedClass;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listă clase'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => const EditClass(),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('end', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('end')
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

          List<QueryDocumentSnapshot<Map<String, dynamic>>> classes = snapshot.data!.docs;

          if (classes.isEmpty) {
            return const Center(
              child: Text('Nu există clase viitoare!'),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) => Dismissible(
              key: ValueKey(classes[index]),
              onDismissed: (direction) {
                deletedClass = classes[index];
                classes[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Clasa a fost ștearsă.'),
                    action: SnackBarAction(
                      label: 'Anulați',
                      onPressed: () {
                        classes[index].reference.set(deletedClass!.data()!);
                        deletedClass = null;
                      },
                    ),
                  ),
                );
              },
              child: FutureBuilder<String>(
                future: getUserName(classes[index].data()['trainer']),
                builder: (context, trainerSnapshot) {
                  if (trainerSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  if (trainerSnapshot.hasError) {
                    return const Text('Eroare');
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClassListTile(
                      fitnessClassDoc: classes[index],
                      trainerName: trainerSnapshot.data!,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
