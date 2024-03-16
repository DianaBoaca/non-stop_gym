import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:non_stop_gym/widgets/trainer/reserved_clients_list.dart';
import '../../utils/class_utils.dart';
import '../users/white_text.dart';

class ClassCard extends StatefulWidget {
  const ClassCard({super.key, required this.classSnapshot});

  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  Future<bool> sendNotification(String token, String title, String text) async {
    String jsonCredentials =
        await rootBundle.loadString('517570860ed0e887014067b5f426e130a86d7436');
    ServiceAccountCredentials credentials =
        ServiceAccountCredentials.fromJson(jsonCredentials);
    AutoRefreshingAuthClient client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );
    Map<String, Map<String, Object>> notification = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': text,
        }
      }
    };
    Response response = await client.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/224380999505/messages:send'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notification),
    );

    client.close();

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<void> _cancelClass() async {
    try {
      widget.classSnapshot.reference.delete();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clasa a fost anulată.'),
        ),
      );

      QuerySnapshot<Map<String, dynamic>> waitingListSnapshot =
          await FirebaseFirestore.instance
              .collection('waitingList')
              .where('class', isEqualTo: widget.classSnapshot.reference)
              .get();
      for (QueryDocumentSnapshot waiting in waitingListSnapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(waiting['client'])
                .get();
        sendNotification(
          userSnapshot['token'],
          'Anulare clasă',
          'Clasa de ${widget.classSnapshot['className']} a fost anulată!',
        );

        waiting.reference.delete();
      }

      QuerySnapshot<Map<String, dynamic>> reservationsSnapshot =
          await FirebaseFirestore.instance
              .collection('reservations')
              .where('class', isEqualTo: widget.classSnapshot.reference)
              .get();
      for (QueryDocumentSnapshot reservation in reservationsSnapshot.docs) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(reservation['client'])
                .get();
        sendNotification(
          userSnapshot['token'],
          'Anulare clasă',
          'Clasa de ${widget.classSnapshot['className']} a fost anulată!',
        );

        reservation.reference.delete();
      }
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) =>
              ReservedClientsList(classSnapshot: widget.classSnapshot),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        color: colors[widget.classSnapshot['className']] ?? Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.classSnapshot['className'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      WhiteText(
                        text: formatter
                            .format(widget.classSnapshot['date'].toDate()),
                      ),
                      const SizedBox(height: 15),
                      WhiteText(
                        text:
                            '${formatterTime.format(widget.classSnapshot['start'].toDate())} - ${formatterTime.format(widget.classSnapshot['end'].toDate())}',
                      ),
                      const SizedBox(height: 15),
                      WhiteText(
                        text:
                            'Sala: ${widget.classSnapshot['room'] == 'Room.aerobic' ? 'Aerobic' : 'Functional'}',
                      ),
                      const SizedBox(height: 15),
                      WhiteText(
                        text:
                            'Persoane înscrise: ${widget.classSnapshot['reserved']}/${widget.classSnapshot['capacity']}',
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: const Text('Anulează'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Card(
                                margin: const EdgeInsets.all(20),
                                color:
                                    colors[widget.classSnapshot['className']],
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      WhiteText(
                                          text:
                                              'Sunteți sigur că anulați clasa de ${widget.classSnapshot['className']}?'),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _cancelClass();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Da'),
                                          ),
                                          const SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Nu'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
