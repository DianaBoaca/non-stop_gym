import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Map<String, Color> colors = {
  'Cycling': Colors.purpleAccent,
  'Zumba': Colors.pink,
  'Pilates': Colors.green,
  'TRX': Colors.orange,
  'Kickbox': Colors.lightGreen,
  'Yoga': Colors.lime,
  'Circuit Training': Colors.grey,
};

class ClassesCalendarScreen extends StatelessWidget {
  const ClassesCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .snapshots(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final classes = snapshots.data!.docs;

        if (!snapshots.hasData || classes.isEmpty) {
          return const Center(
            child: Text('Nu există clase.'),
          );
        }

        if (snapshots.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        final List<FitnessClass> appointments = <FitnessClass>[];

        for (final doc in classes) {
          appointments.add(
            FitnessClass(
              doc['className'],
              doc['start'].toDate(),
              doc['end'].toDate(),
              colors[doc['className']] ?? Colors.white,
            ),
          );
        }

        return SfCalendar(
          view: CalendarView.day,
          dataSource: ClassDataSource(appointments),
          timeSlotViewSettings: const TimeSlotViewSettings(
            startHour: 9,
            endHour: 22,
            timeIntervalHeight: 50,
          ),
          firstDayOfWeek: 1,
          showNavigationArrow: true,
          showDatePickerButton: true,
          showTodayButton: true,
          appointmentTextStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          headerStyle: CalendarHeaderStyle(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 25,
            ),
          ),
        );
      },
    );
  }
}

class ClassDataSource extends CalendarDataSource {
  ClassDataSource(List<FitnessClass> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].className;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}

class FitnessClass {
  FitnessClass(this.className, this.from, this.to, this.background);

  String className;
  DateTime from;
  DateTime to;
  Color background;
}
