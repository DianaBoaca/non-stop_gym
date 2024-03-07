import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:non_stop_gym/screens/admin/admin_home.dart';
import 'package:non_stop_gym/screens/authentification.dart';
import 'package:non_stop_gym/screens/client/client_tabs.dart';
import 'package:non_stop_gym/screens/trainer/trainer_tabs.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Non-stop Gym',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 104, 76, 159),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 104, 76, 159))
            .copyWith(background: Colors.white),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Eroare!'));
          }

          if (!snapshot.hasData) {
            return const AuthScreen();
          }

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (userSnapshot.hasError) {
                return const Text('Eroare!');
              }

              if (!userSnapshot.hasData) {
                return const AuthScreen();
              }

              final role = userSnapshot.data!.get('role');
              if (role == 'client') {
                return const ClientTabsScreen();
              } else if (role == 'admin') {
                return const AdminHomeScreen();
              } else if (role == 'trainer') {
                return const TrainerTabsScreen();
              }
              return const AuthScreen();
            },
          );
        },
      ),
    );
  }
}
