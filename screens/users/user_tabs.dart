import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../widgets/edit_user.dart';
import '../authentication.dart';

class UserTabsScreen extends StatefulWidget {
  const UserTabsScreen({
    super.key,
    required this.tabTitles,
    required this.activeTabs,
    required this.tabLabels,
    required this.icons,
  });

  final List<String> tabTitles;
  final List<Widget> activeTabs;
  final List<IconData> icons;
  final List<String> tabLabels;

  @override
  State<UserTabsScreen> createState() => _UserTabsScreenState();
}

class _UserTabsScreenState extends State<UserTabsScreen> {
  int _selectedTab = 2;

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (mounted) _selectTab(0);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.tabTitles[_selectedTab]),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => EditUser(
                    userRef: FirebaseFirestore.instance.collection('users').doc(user.uid)),
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
      body: widget.activeTabs[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _selectTab,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        currentIndex: _selectedTab,
        items: [
          BottomNavigationBarItem(
            icon: Icon(widget.icons[0]),
            label: widget.tabLabels[0],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.icons[1]),
            label: widget.tabLabels[1],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.icons[2]),
            label: widget.tabLabels[2],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.icons[3]),
            label: widget.tabLabels[3],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.icons[4]),
            label: widget.tabLabels[4],
          ),
        ],
      ),
    );
  }
}
