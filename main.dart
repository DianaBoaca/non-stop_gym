import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/screens/admin/AdminHomeScreen.dart';
import 'package:non_stop_gym/screens/AuthScreen.dart';
import 'package:non_stop_gym/screens/ClientHomeScreen.dart';
import 'package:non_stop_gym/screens/SplashScreen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(const App());
}

Future<String> getRole() async {
  final user = FirebaseAuth.instance.currentUser!;
  final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final role = userData.data()!['role'];
  return role;
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 66, 43, 129),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 66, 43, 129)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            if (getRole().toString() == 'client') {
              return const ClientHomeScreen();
            } else if (getRole().toString() == 'admin') {
              return const AdminHomeScreen();
            }
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
