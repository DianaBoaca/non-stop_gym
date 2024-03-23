import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
