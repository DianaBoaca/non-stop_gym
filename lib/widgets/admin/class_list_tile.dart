import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/time_utils.dart';
import 'edit_class.dart';

class ClassListTile extends StatelessWidget {
  const ClassListTile({
    super.key,
    required this.fitnessClassDoc,
    required this.trainerName,
  });

  final DocumentSnapshot<Map<String, dynamic>> fitnessClassDoc;
  final String trainerName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        fitnessClassDoc['room'] == 'Room.aerobic'
            ? Icons.monitor_heart
            : Icons.fitness_center,
        color: const Color.fromARGB(255, 156, 124, 222),
      ),
      title: Text(
        fitnessClassDoc['className'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatter.format(fitnessClassDoc['date'].toDate()),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 20),
              Text(
                '${formatterTime.format(fitnessClassDoc['start'].toDate())} - ${formatterTime.format(fitnessClassDoc['end'].toDate())}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          Text(
            '$trainerName, ${fitnessClassDoc['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Persoane înscrise: ${fitnessClassDoc['reserved']}/${fitnessClassDoc['capacity']}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => EditClass(fitnessClassSnapshot: fitnessClassDoc),
        );
      },
    );
  }
}
