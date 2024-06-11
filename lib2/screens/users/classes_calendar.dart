import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:non_stop_gym/widgets/users/calendar_class_card.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../utils/class_utils.dart';

class ClassesCalendarScreen extends StatelessWidget {
  const ClassesCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('classes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Eroare!'),
          );
        }

        List<QueryDocumentSnapshot<Map<String, dynamic>>> classes = snapshot.data!.docs;
        List<FitnessClass> appointments = <FitnessClass>[];

        for (var doc in classes) {
          appointments.add(
            FitnessClass(
              doc.id,
              doc['className'],
              doc['start'].toDate(),
              doc['end'].toDate(),
              doc['date'].toDate(),
              colors[doc['className']] ?? Colors.blue,
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
            backgroundColor: Theme.of(context).colorScheme.background,
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
                builder: (context) => CalendarClassCard(
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
