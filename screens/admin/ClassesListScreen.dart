import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/ClassUtils.dart';
import 'EditClass.dart';
import 'NewClass.dart';

class ClassesListScreen extends StatelessWidget {
  const ClassesListScreen({super.key});

  Future<String> _getTrainerName(DocumentReference ref) async {
    DocumentSnapshot trainer = await ref.get();
    Map<String, dynamic> trainerData = trainer.data() as Map<String, dynamic>;
    return '${trainerData['lastName']} ${trainerData['firstName']}';
  }

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
                context: context,
                builder: (ctx) {
                  return const NewClass();
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('end', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('end')
            .snapshots(),
        builder: (ctx, classesSnapshots) {
          if (classesSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final classes = classesSnapshots.data!.docs;

          if (!classesSnapshots.hasData || classes.isEmpty) {
            return const Center(
              child: Text('Nu există clase.'),
            );
          }

          if (classesSnapshots.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (ctx, index) => Dismissible(
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
              child: FutureBuilder(
                future: _getTrainerName(classes[index].data()['trainer']),
                builder: (ctx, trainerSnapshots) {
                  if (trainerSnapshots.hasError) {
                    return const Text('Eroare');
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Icon(
                          classes[index].data()['room'] == 'Room.aerobic'
                              ? Icons.monitor_heart
                              : Icons.fitness_center
                      ),
                      title: Text(
                        classes[index].data()['className'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                formatter.format(classes[index].data()['date'].toDate()),
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '${formatterTime.format(classes[index].data()['start'].toDate())} - ${formatterTime.format(classes[index].data()['end'].toDate())}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          Text(
                            '${trainerSnapshots.data}, ${classes[index].data()['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Persoane înscrise: ${classes[index].data()['reserved']}/${classes[index].data()['capacity']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      tileColor: Theme.of(context).colorScheme.primaryContainer,
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) {
                            return EditClass(classs: classes[index].reference);
                          },
                        );
                      },
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
