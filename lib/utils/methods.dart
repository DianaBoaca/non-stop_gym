import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

Future<String> getUserName(DocumentReference<Map<String, dynamic>> ref) async {
  DocumentSnapshot<Map<String, dynamic>> user = await ref.get();

  if (user.exists) {
    Map<String, dynamic> trainerData = user.data()!;

    return '${trainerData['lastName']} ${trainerData['firstName']}';
  }

  return 'Eroare';
}

Future<String> fetchApiKey(String service) async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  return remoteConfig.getString(service);
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
    String key = await fetchApiKey('fcm');
    Response response = await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=$key',
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

Future<int> calculatePosition(DocumentSnapshot<Map<String, dynamic>> reservationsSnapshot) async {
  QuerySnapshot<Map<String, dynamic>> waitingQuery = await FirebaseFirestore.instance
      .collection('waitingList')
      .orderBy('time')
      .get();

  if (waitingQuery.docs.every((doc) => doc.reference != reservationsSnapshot.reference)) {
    return 0;
  }

  int position = waitingQuery.docs.indexWhere((doc) => doc.reference == reservationsSnapshot.reference);

  return position + 1;
}

void upgradeFirstWaitingToReserved(DocumentSnapshot<Map<String, dynamic>> fitnessClassSnapshot) async {
  fitnessClassSnapshot.reference.update({'reserved': FieldValue.increment(-1)});

  QuerySnapshot<Map<String, dynamic>> waitingListSnapshot =
      await FirebaseFirestore.instance
          .collection('waitingList')
          .where('class', isEqualTo: fitnessClassSnapshot.reference)
          .orderBy('time')
          .get();

  if (waitingListSnapshot.docs.isNotEmpty) {
    DocumentSnapshot<Map<String, dynamic>> first = waitingListSnapshot.docs.first;

    await FirebaseFirestore.instance.collection('reservations').add({
      'class': fitnessClassSnapshot.reference,
      'client': first['client'],
      'date': fitnessClassSnapshot['date'],
      'start': fitnessClassSnapshot['start'],
      'end': fitnessClassSnapshot['end'],
    });

    fitnessClassSnapshot.reference.update({'reserved': FieldValue.increment(1)});

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(first['client'])
            .get();

    sendNotification(
      userSnapshot['token'],
      'Rezervare confirmată',
      'A fost eliberat un loc la clasa de ${fitnessClassSnapshot['className']}. Rezervarea este confirmată!',
    );

    await first.reference.delete();
  }
}
