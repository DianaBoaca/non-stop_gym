import 'package:flutter/material.dart';
import '../utils/ClassUtils.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.fitnessClass});

  final FitnessClass fitnessClass;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(20),
          color: fitnessClass.color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  fitnessClass.className,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatter.format(fitnessClass.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${formatterTime.format(fitnessClass.start)} - ${formatterTime.format(fitnessClass.end)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: getTrainerName(fitnessClass.trainer),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Eroare!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    }

                    return Text(
                      'Antrenor: ${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    );
                    },
                ),
                const SizedBox(height: 10),
                Text(
                  'Sala: ${fitnessClass.room}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Persoane înscrise: ${fitnessClass.reserved}/${fitnessClass.capacity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Înapoi'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Rezervă'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
