import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/admin/custom_container.dart';
import 'ContactScreen.dart';
import 'AdminRuleScreen.dart';
import 'ClientsListScreen.dart';
import 'TrainersListScreen.dart';
import 'package:non_stop_gym/screens/AuthScreen.dart';
import 'ClassesListScreen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non-Stop Gym'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (ctx) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomContainer(
            icon: Icons.fitness_center,
            title: 'Antrenori',
            color: Theme.of(context).colorScheme.onPrimaryContainer ,
            route: const TrainersListScreen(),
          ),
          CustomContainer(
            icon: Icons.calendar_today,
            title: 'Clase',
            color: Theme.of(context).colorScheme.primary,
            route: const ClassesListScreen(),
          ),
          CustomContainer(
            icon: Icons.person,
            title: 'Clienți',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            route: const ClientsListScreen(),
          ),
          CustomContainer(
            icon: Icons.contact_page,
            title: 'Date de contact',
            color: Theme.of(context).colorScheme.primary,
            route: const ContactScreen(),
          ),
          CustomContainer(
            icon: Icons.rule,
            title: 'Regulament',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            route: const AdminRuleScreen(),
          ),
        ],
      ),
     );
  }
}
