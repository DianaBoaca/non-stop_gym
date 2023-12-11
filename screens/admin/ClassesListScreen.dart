import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'NewClass.dart';

class ClassesListScreen extends StatefulWidget {
  const ClassesListScreen({super.key});

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  void _openAddClassOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return const NewClass();
      },
    );
  }

  Future<String> _getTrainerName(DocumentReference ref) async {
    DocumentSnapshot trainer = await ref.get();
    Map<String, dynamic> trainerData = trainer.data() as Map<String, dynamic>;
    return '${trainerData['lastName']} ${trainerData['surname']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listă clase'),
        actions: [
          IconButton(
            onPressed: _openAddClassOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('classes').where('end', isLessThan: DateTime.now()).snapshots(),
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
                classes[index].reference.delete();
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clasa a fost ștearsă.'),
                  ),
                );
              },
              child: FutureBuilder(
                future: _getTrainerName(classes[index].data()['trainer']),
                builder: (ctx, trainerSnapshots) {
                  if (trainerSnapshots.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (trainerSnapshots.hasError) {
                    return const Text('Eroare');
                  }

                  return ListTile(
                    leading: Icon(classes[index].data()['room'] == Room.aerobic
                        ? Icons.monitor_heart_outlined
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
                            Text(formatter.format(classes[index].data()['date'].toDate())),
                            const SizedBox(width: 20),
                            Text('${formatterTime.format(classes[index].data()['start'].toDate())} - ${formatterTime.format(classes[index].data()['end'].toDate())}'),
                          ],
                        ),
                        Text('${trainerSnapshots.data}, ${classes[index].data()['room'] == Room.aerobic
                            ? 'Aerobic'
                            : 'Functional'}'
                        ),
                        Text('Persoane înscrise: ${classes[index].data()['reserved']}/${classes[index].data()['capacity']}'),
                      ],
                    ),
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
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
