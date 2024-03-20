import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
  DocumentReference<Map<String, dynamic>> trainer;
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

Future<bool> sendNotification(String token, String title, String text) async {
  Map<String, dynamic> notification = {
    'to': token,
    'notification': {
      'title': title,
      'body': text,
    }
  };

  try {
    Response response = await post(
      Uri.parse(
        'https://fcm.googleapis.com/fcm/send',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAND4mV1E:APA91bGOINNSiG7He1wV-xFlmextGqLV7_wFkaT2dvJtWrfWNUO-65oT11zUlBsszFNJQbKfoBOVTt1Qbs3fRxnKx3kR9K2tJAhikNqdfDxI-i8DThZ6Uw4Q_FCcZMles_pIhfrva2cq',
      },
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  } catch (error) {
    return false;
  }
}
