import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/methods.dart';

class AdminReservedClientsList extends StatefulWidget {
  const AdminReservedClientsList({super.key, required this.classSnapshot});

  final DocumentSnapshot<Map<String, dynamic>> classSnapshot;

  @override
  State<AdminReservedClientsList> createState() => _AdminReservedClientsListState();
}

class _AdminReservedClientsListState extends State<AdminReservedClientsList> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
     _counter = widget.classSnapshot['reserved'];
    });
  }

  Future<void> _cancelReservation(DocumentSnapshot<Map<String, dynamic>> reservationsSnapshot) async {
    int position = await calculatePosition(reservationsSnapshot);

    try {
      reservationsSnapshot.reference.delete();

      setState(() {
        _counter = _counter - 1;
      });

      if (position == 0) {
        upgradeFirstWaitingToReserved(widget.classSnapshot);
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Eroare stocare date.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .where('class', isEqualTo: widget.classSnapshot.reference)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        if (snapshot.hasError) {
          return const  Text('Eroare!');
        }

        return ListView.builder(
            shrinkWrap: true,
            itemCount: _counter,
            itemBuilder: (context, index) {
              return FutureBuilder<String>(
                  future: getUserName(snapshot.data!.docs[index]['client']),
                  builder: (context, nameSnapshot) {
                    if (nameSnapshot.connectionState == ConnectionState.waiting ||
                        nameSnapshot.data!.isEmpty) {
                      return const SizedBox();
                    }

                    if (nameSnapshot.hasError) {
                      return const Center(
                        child: Text('Eroare!'),
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                        ),
                        Expanded(
                          child: Text(
                            "${index + 1}. ${nameSnapshot.data!}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _cancelReservation(snapshot.data!.docs[index]);
                          },
                          child: const Text("X"),
                        ),
                      ],
                    );
                  });
            });
      },
    );
  }
}
