import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final formatter = DateFormat('dd/MM/yyyy');
final formatterTime = DateFormat.jm();

enum Room { aerobic, functional }

Map<String, Color> colors = {
  'Cycling': Colors.purpleAccent,
  'Zumba': Colors.pink,
  'Pilates': Colors.green,
  'TRX': Colors.orange,
  'Kickbox': Colors.lightGreen,
  'Yoga': Colors.yellow,
  'Circuit Training': Colors.grey,
};

class FitnessClass {
  FitnessClass(
    this.id,
    this.className,
    this.start,
    this.end,
    this.date,
    this.color,
    this.capacity,
    this.reserved,
    this.room,
    this.trainer,
  );

  String id;
  String className;
  DateTime start;
  DateTime end;
  DateTime date;
  Color color;
  int capacity;
  int reserved;
  String room;
  DocumentReference trainer;
}

Future<String> getUserName(DocumentReference ref) async {
  DocumentSnapshot trainer = await ref.get();
  Map<String, dynamic> trainerData = trainer.data() as Map<String, dynamic>;
  return '${trainerData['lastName']} ${trainerData['firstName']}';
}

DateTime convertToDateTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

TimeOfDay convertToTimeOfDay(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

String formatTime(TimeOfDay time) {
  return formatterTime.format(DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    time.hour,
    time.minute,
  ));
}

double toDouble(TimeOfDay time) {
  return time.hour + time.minute / 60.0;
}

Future<bool> verifyRoomAvailability(String id, DateTime date, String room,
    TimeOfDay start, TimeOfDay end) async {
  final existingClasses = await FirebaseFirestore.instance
      .collection('classes')
      .where('date', isEqualTo: date)
      .where('room', isEqualTo: room)
      .get();

  return verifyHours(id, existingClasses.docs, date, start, end);
}

Future<bool> verifyTrainerAvailability(String id, DocumentReference trainer,
    DateTime date, TimeOfDay start, TimeOfDay end) async {
  final existingClasses = await FirebaseFirestore.instance
      .collection('classes')
      .where('trainer', isEqualTo: trainer)
      .where('date', isEqualTo: date)
      .get();

  return verifyHours(id, existingClasses.docs, date, start, end);
}

Future<bool> verifyHours(String id, List existingClasses, DateTime date,
    TimeOfDay start, TimeOfDay end) async {
  bool existingClassBeforeStart = false,
      existingClassAfterStart = false,
      existingClass = false;
  for (var doc in existingClasses) {
    if (doc.id != id) {
      if (doc['start'].toDate().isBefore(convertToDateTime(date, start)) &&
          doc['end'].toDate().isAfter(convertToDateTime(date, start))) {
        existingClassBeforeStart = true;
      }

      if (doc['start'].toDate().isBefore(convertToDateTime(date, end)) &&
          doc['end'].toDate().isAfter(convertToDateTime(date, end))) {
        existingClassAfterStart = true;
      }

      if (doc['start'].toDate().isAfter(convertToDateTime(date, start)) &&
          doc['start'].toDate().isBefore(convertToDateTime(date, end))) {
        existingClass = true;
      }
    }
  }

  if (existingClassBeforeStart || existingClassAfterStart || existingClass) {
    return false;
  }

  return true;
}
