import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/class_card.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../utils/ClassUtils.dart';

Map<String, Color> colors = {
  'Cycling': Colors.purpleAccent,
  'Zumba': Colors.pink,
  'Pilates': Colors.green,
  'TRX': Colors.orange,
  'Kickbox': Colors.lightGreen,
  'Yoga': Colors.yellow,
  'Circuit Training': Colors.grey,
};

class ClassesCalendarScreen extends StatelessWidget {
  const ClassesCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('classes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final classes = snapshot.data!.docs;

        if (!snapshot.hasData || classes.isEmpty) {
          return const Center(
            child: Text('Nu există clase.'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        final List<FitnessClass> appointments = <FitnessClass>[];

        for (final doc in classes) {
          appointments.add(
            FitnessClass(
              doc.id,
              doc['className'],
              doc['start'].toDate(),
              doc['end'].toDate(),
              doc['date'].toDate(),
              colors[doc['className']]!,
              doc['capacity'],
              doc['reserved'],
              doc['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional',
              doc['trainer'],
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
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment) {
              showModalBottomSheet(
                isDismissible: true,
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ClassCard(
                  fitnessClass: details.appointments![0],
                ),
              );
            }
          },
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
    return appointments![index].start;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].end;
  }

  @override
  String getSubject(int index) {
    return appointments![index].className;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }
}
