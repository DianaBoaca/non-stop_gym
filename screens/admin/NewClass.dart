import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/ClassUtils.dart';

class NewClass extends StatefulWidget {
  const NewClass({super.key});

  @override
  State<NewClass> createState() {
    return _NewClassState();
  }
}

class _NewClassState extends State<NewClass> {
  final _form = GlobalKey<FormState>();
  String _enteredName = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedStart;
  TimeOfDay? _selectedEnd;
  DocumentReference? _selectedTrainer;
  Room? _selectedRoom;
  int _counter = 0;

  void _showError(FirebaseAuthException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.message ?? 'Eroare stocare date.',
        ),
      ),
    );
  }

  void _changeScreen() {
    Navigator.pop(context);
  }

  void _onSave() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    if(_selectedDate == null || _selectedStart == null || _selectedEnd == null || _selectedTrainer == null || _selectedRoom == null) {
      return;
    }

    _form.currentState!.save();

    try {
      await FirebaseFirestore.instance.collection('classes').add({
        'className': _enteredName,
        'date': _selectedDate,
        'start': convert(_selectedDate!, _selectedStart!),
        'end': convert(_selectedDate!, _selectedEnd!),
        'trainer': _selectedTrainer,
        'room': _selectedRoom.toString(),
        'capacity': _selectedRoom == Room.aerobic ? 25 : 20,
        'reserved': _counter,
      });
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }

    _changeScreen();
  }

  void _selectDate() async {
    final lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);
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
    return time.hour + time.minute/60.0;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
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
                          child: Text(_selectedDate != null
                              ? formatter.format(_selectedDate!)
                              : 'Data'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _selectedDate != null ? _selectStart : null,
                              child: Text(_selectedStart != null
                                  ? formatTime(_selectedStart!)
                                  : 'Start'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _selectedStart != null ? _selectEnd : null,
                              child: Text(_selectedEnd != null
                                  ? formatTime(_selectedEnd!)
                                  : 'Final'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreamBuilder(
                                stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'trainer').snapshots(),
                                builder: (ctx, trainerSnapshots) {
                                  if (trainerSnapshots.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (trainerSnapshots.hasError) {
                                    return const Text('Eroare');
                                  }

                                  List<DropdownMenuItem<DocumentReference>> trainers = trainerSnapshots.data!.docs.map(
                                        (DocumentSnapshot<Map<String, dynamic>> trainer) {
                                      return DropdownMenuItem(
                                        value: trainer.reference,
                                        child: Text('${trainer['lastName']} ${trainer['surname']}',
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
                              items: Room.values.map(
                                    (room) => DropdownMenuItem(
                                  value: room,
                                  child: Text(room.name),
                                ),
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoom = value!;
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
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
            ],
          ),
        ),
    );
  }
}
