import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateFormat formatter = DateFormat('dd/MM/yyyy');
DateFormat formatterTime = DateFormat.jm();

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

double convertToDouble(TimeOfDay time) {
  return time.hour + time.minute / 60.0;
}

Future<bool> verifyRoomAvailability(String id, DateTime date, String room,
    TimeOfDay start, TimeOfDay end) async {
  QuerySnapshot<Map<String, dynamic>> existingClasses = await FirebaseFirestore
      .instance.collection('classes')
      .where('date', isEqualTo: date)
      .where('room', isEqualTo: room)
      .get();

  return verifyHours(id, existingClasses.docs, date, start, end);
}

Future<bool> verifyTrainerAvailability(String id, DocumentReference trainer,
    DateTime date, TimeOfDay start, TimeOfDay end) async {
  QuerySnapshot<Map<String, dynamic>> existingClasses = await FirebaseFirestore
      .instance.collection('classes')
      .where('trainer', isEqualTo: trainer)
      .where('date', isEqualTo: date)
      .get();

  return verifyHours(id, existingClasses.docs, date, start, end);
}

Future<bool> verifyHours(String id, List existingClasses, DateTime date,
    TimeOfDay start, TimeOfDay end) async {
  bool existingClass = false;

  for (var doc in existingClasses) {
    if (doc.id != id &&
        ((doc['start'].toDate().isBefore(convertToDateTime(date, start)) &&
            doc['end'].toDate().isAfter(convertToDateTime(date, start))) ||
            (doc['start'].toDate().isBefore(convertToDateTime(date, end)) &&
                doc['end'].toDate().isAfter(convertToDateTime(date, end))) ||
            (doc['start'].toDate().isAfter(convertToDateTime(date, start)) &&
                doc['start'].toDate().isBefore(convertToDateTime(date, end))) ||
            (doc['start'].toDate() == convertToDateTime(date, start))
        )
    ) {
      existingClass = true;
    }
  }

  return !existingClass;
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
