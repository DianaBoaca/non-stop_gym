import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';

Future<String> getUserName(DocumentReference<Map<String, dynamic>> ref) async {
  DocumentSnapshot<Map<String, dynamic>> trainer = await ref.get();

  if (trainer.exists) {
    Map<String, dynamic> trainerData = trainer.data()!;

    return '${trainerData['lastName']} ${trainerData['firstName']}';
  }

  return 'Eroare';
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
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
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
