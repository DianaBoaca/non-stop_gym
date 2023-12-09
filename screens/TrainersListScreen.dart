import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/screens/NewTrainer.dart';

final _firebase = FirebaseAuth.instance;

class TrainersListScreen extends StatefulWidget {
  const TrainersListScreen({super.key});

  @override
  State<TrainersListScreen> createState() => _TrainersListScreenState();
}

class _TrainersListScreenState extends State<TrainersListScreen> {
  void _openAddTrainerOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return const NewTrainer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listă antrenori'),
        actions: [
          IconButton(
            onPressed: _openAddTrainerOverlay,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'trainer').snapshots(),
        builder: (ctx, trainerSnapshots) {
          if (trainerSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final trainers = trainerSnapshots.data!.docs;

          if (!trainerSnapshots.hasData || trainers.isEmpty) {
            return const Center(
              child: Text('Nu există antrenori.'),
            );
          }

          if (trainerSnapshots.hasError) {
            return const Center(
              child: Text('Eroare!'),
            );
          }

          return ListView.builder(
            itemCount: trainers.length,
            itemBuilder: (ctx, index) => ListTile(
              title: Text(trainers[index].data()['lastName'] + ' ' + trainers[index].data()['surname']),
              subtitle: Row(
                children: [
                  Text(trainers[index].data()['email']),
                  const SizedBox(width: 20),
                  Text(trainers[index].data()['phone']),
                ],
              ),
              tileColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }
}