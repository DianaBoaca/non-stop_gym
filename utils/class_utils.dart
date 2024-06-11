import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Room { aerobic, functional }

Map<String, Color> colors = {
  'Cycling': Colors.purple.shade400,
  'Zumba': Colors.pink.shade200,
  'Pilates': Colors.green,
  'TRX': Colors.orange.shade300,
  'Kickbox': Colors.redAccent,
  'Yoga': Colors.yellow.shade300,
  'Circuit Training': Colors.grey.shade300,
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
