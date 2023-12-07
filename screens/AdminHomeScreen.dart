import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/screens/AuthScreen.dart';

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
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 170),
          Card(
            margin: const EdgeInsets.all(6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
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
              tileColor: Theme.of(context).colorScheme.onPrimaryContainer,
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
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
              tileColor: Theme.of(context).colorScheme.primary,
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
              leading: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 25,
              ),
              title: const Text(
                'Orar clase',
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              tileColor: Theme.of(context).colorScheme.onPrimaryContainer,
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
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
              tileColor: Theme.of(context).colorScheme.primary,
              onTap: () {},
            ),
          ),
          Card(
            margin: const EdgeInsets.all(6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
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
              tileColor: Theme.of(context).colorScheme.onPrimaryContainer,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
