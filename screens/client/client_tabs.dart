import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/screens/client/classes_calendar.dart';
import 'package:non_stop_gym/screens/client/prices.dart';
import '../../widgets/edit_user.dart';
import '../home.dart';
import '../authentification.dart';
import 'client_reservations.dart';
import '../rules.dart';

List<String> tabTitles = ['Rezervările mele', 'Calendar clase', 'Non-stop Gym', 'Regulament', 'Tarife'];
List<Widget> activeTabs = [const ReservationsListScreen(), const ClassesCalendarScreen(), const HomeScreen(), const RulesScreen(), const PriceScreen()];

class ClientTabsScreen extends StatefulWidget {
  const ClientTabsScreen({super.key});

  @override
  State<ClientTabsScreen> createState() =>  _ClientTabsScreenState();
}

class _ClientTabsScreenState extends State<ClientTabsScreen> {
  int _selectedTab = 2;

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(tabTitles[_selectedTab]),
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => EditUser(
                      user: FirebaseFirestore.instance.collection('users').doc(user.uid)),
                );
              },
              icon: const Icon(Icons.person),
            ),
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
              ),
            ],
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: activeTabs[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _selectTab,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Rezervări',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acasă',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule),
            label: 'Regulament',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Tarife',
          ),
        ],
      ),
    );
  }
}