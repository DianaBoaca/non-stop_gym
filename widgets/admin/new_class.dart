import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class NewClass extends StatefulWidget {
  const NewClass({super.key});

  @override
  State<NewClass> createState() => _NewClassState();
}

class _NewClassState extends State<NewClass> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _enteredName = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedStart;
  TimeOfDay? _selectedEnd;
  DocumentReference? _selectedTrainer;
  Room? _selectedRoom;

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  void _showBookingError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _changeScreen() {
    Navigator.pop(context);
  }

  void _onSave() async {
    if (_form.currentState!.validate() &&
        _selectedDate != null &&
        _selectedStart != null &&
        _selectedEnd != null &&
        _selectedTrainer != null &&
        _selectedRoom != null) {
      _form.currentState!.save();
    }

    if (await verifyTrainerAvailability('', _selectedTrainer!, _selectedDate!,
            _selectedStart!, _selectedEnd!) ==
        false) {
      _showBookingError('Antrenorul este ocupat în acel interval orar.');
      return;
    }

    if (await verifyRoomAvailability('', _selectedDate!,
            _selectedRoom!.toString(), _selectedStart!, _selectedEnd!) ==
        false) {
      _showBookingError('Sala este ocupată în acel interval orar.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('classes').add({
        'className': _enteredName,
        'date': _selectedDate,
        'start': convertToDateTime(_selectedDate!, _selectedStart!),
        'end': convertToDateTime(_selectedDate!, _selectedEnd!),
        'trainer': _selectedTrainer,
        'room': _selectedRoom.toString(),
        'capacity': _selectedRoom == Room.aerobic ? 25 : 20,
        'reserved': 0,
      });

      _changeScreen();
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _selectDate() async {
    final lastDate = DateTime(
      DateTime.now().year + 1,
      DateTime.now().month,
      DateTime.now().day,
    );
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: lastDate,
    );

    setState(() {
      _selectedDate = date;
    });
  }

  void _selectStart() async {
    if (_selectedDate == null) {
      return;
    }

    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      _selectedStart = start;
    });
  }

  double toDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  void _selectEnd() async {
    if (_selectedStart == null) {
      return;
    }

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (toDouble(_selectedStart!) < toDouble(end!)) {
      setState(() {
        _selectedEnd = end;
      });
    } else {
      _showBookingError(
          'Ora de sfârșit a clasei nu poate fi înaintea orei de începere.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nume clasă',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduceți un nume de clasă.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredName = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _selectDate,
                      child: Text(
                        _selectedDate != null
                            ? formatter.format(_selectedDate!)
                            : 'Data',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _selectedDate != null ? _selectStart : null,
                          child: Text(
                            _selectedStart != null
                                ? formatTime(_selectedStart!)
                                : 'Start',
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _selectedStart != null ? _selectEnd : null,
                          child: Text(
                            _selectedEnd != null
                                ? formatTime(_selectedEnd!)
                                : 'Final',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('role', isEqualTo: 'trainer')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return const Text('Eroare');
                              }

                              List<DropdownMenuItem<DocumentReference>>
                                  trainers = snapshot.data!.docs.map(
                                (DocumentSnapshot<Map<String, dynamic>>
                                    trainer) {
                                  return DropdownMenuItem(
                                    value: trainer.reference,
                                    child: Text(
                                      '${trainer['lastName']} ${trainer['firstName']}',
                                    ),
                                  );
                                },
                              ).toList();

                              return DropdownButton(
                                items: trainers,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    _selectedTrainer = value;
                                  });
                                },
                                value: _selectedTrainer,
                                hint: const Text('Antrenor'),
                              );
                            }),
                        const SizedBox(width: 10),
                        DropdownButton(
                          value: _selectedRoom,
                          items: Room.values
                              .map(
                                (room) => DropdownMenuItem(
                                  value: room,
                                  child: Text(room.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedRoom = value;
                            });
                          },
                          hint: const Text('Sala'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Anulează'),
                        ),
                        ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Adaugă'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
