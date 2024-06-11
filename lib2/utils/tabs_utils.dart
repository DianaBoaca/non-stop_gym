import 'package:flutter/material.dart';
import '../screens/client/prices.dart';
import '../screens/trainer/trainer_classes.dart';
import '../screens/users/classes_calendar.dart';
import '../screens/users/home.dart';
import '../screens/users/reservations.dart';
import '../screens/users/rules.dart';

List<String> clientTabTitles = [
  'Rezervările mele',
  'Calendar clase',
  'Non-stop Gym',
  'Regulament',
  'Tarife'
];

List<Widget> clientActiveTabs = [
  const ReservationsListScreen(),
  const ClassesCalendarScreen(),
  const HomeScreen(),
  const RulesScreen(),
  const PriceScreen()
];

List<IconData> clientIcons = [
  Icons.access_time,
  Icons.calendar_month,
  Icons.home,
  Icons.rule,
  Icons.attach_money
];

List<String> clientTabLabels = [
  'Rezervări',
  'Calendar',
  'Acasă',
  'Regulament',
  'Tarife',
];

List<String> trainerTabTitles = [
  'Rezervările mele',
  'Clasele mele',
  'Non-stop Gym',
  'Calendar clase',
  'Regulament'
];

List<Widget> trainerActiveTabs = [
  const ReservationsListScreen(),
  const MyClassesListScreen(),
  const HomeScreen(),
  const ClassesCalendarScreen(),
  const RulesScreen()
];

List<IconData> trainerIcons = [
  Icons.access_time,
  Icons.sports_gymnastics,
  Icons.home,
  Icons.calendar_month,
  Icons.rule
];

List<String> trainerTabLabels = [
  'Rezervări',
  'Clase',
  'Acasă',
  'Calendar',
  'Regulament',
];