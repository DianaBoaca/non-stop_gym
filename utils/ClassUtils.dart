import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final formatter = DateFormat('dd/MM/yyyy');
final formatterTime = DateFormat.jm();

enum Room { aerobic, functional }

DateTime convert(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
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

Future<bool> verifyRoomAvailability(DateTime date, String room, TimeOfDay start, TimeOfDay end) {
  final existingClasses = FirebaseFirestore.instance.collection('classes')
                          .where('date', isEqualTo: date)
                          .where('room', isEqualTo: room);

  return verifyHours(existingClasses, date, start, end);
}

Future<bool> verifyTrainerAvailability(DocumentReference trainer, DateTime date, TimeOfDay start, TimeOfDay end) {
  final existingClasses = FirebaseFirestore.instance.collection('classes')
                          .where('room', isEqualTo: trainer)
                          .where('date', isEqualTo: date);

  return verifyHours(existingClasses, date, start, end);
}

Future<bool> verifyHours(Query<Map<String, dynamic>> existingClasses, DateTime date,TimeOfDay start, TimeOfDay end) async {
  final existingClassBeforeStart = await existingClasses.where('start', isLessThanOrEqualTo: convert(date, start)).get();

  final existingClassBeforeEnd = await existingClasses.where('end', isGreaterThan: convert(date, start)).get();

  final existingClassAfterStart = await existingClasses.where('start', isLessThan: convert(date, end)).get();

  final existingClassAfterEnd = await existingClasses.where('end', isGreaterThanOrEqualTo: convert(date, end)).get();

  if ((existingClassBeforeStart.docs.isNotEmpty && existingClassBeforeEnd.docs.isNotEmpty)
      || (existingClassAfterStart.docs.isNotEmpty && existingClassAfterEnd.docs.isNotEmpty)) {
    return false;
  }

  return true;
}
