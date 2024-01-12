import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            margin: const EdgeInsets.all(6),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 25,
                ),
                title: const Text(
                  'Antrenori',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const TrainersListScreen()),
                  );
                },
              ),
            ),
          Card(
            margin: const EdgeInsets.all(6),
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Clase',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ClassesListScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Clienți',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ClientsListScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.contact_page,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Contact',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ContactScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.rule,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Reguli și sfaturi',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AdminRuleScreen()),
                );
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.payment,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Tarife',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
