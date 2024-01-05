import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
