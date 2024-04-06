import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/time_utils.dart';
import '../../utils/class_utils.dart';

class EditClass extends StatefulWidget {
  const EditClass({super.key, this.fitnessClassRef});

  final DocumentReference<Map<String, dynamic>>? fitnessClassRef;

  @override
  State<EditClass> createState() => _EditClassState();
}

class _EditClassState extends State<EditClass> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStart;
  TimeOfDay? _selectedEnd;
  DocumentReference? _selectedTrainer;
  Room? _selectedRoom;
  int? _counter;

  @override
  void initState() {
    super.initState();
    if (widget.fitnessClassRef != null) _loadData();
  }

  Future<void> _loadData() async {
    DocumentSnapshot<Map<String, dynamic>> fitnessClassSnapshot =
        await widget.fitnessClassRef!.get();

    if (fitnessClassSnapshot.exists) {
      Map<String, dynamic> fitnessClassMap = fitnessClassSnapshot.data()!;

      setState(() {
        _nameController.text = fitnessClassMap['className'];
        _selectedDate = fitnessClassMap['date'].toDate();
        _selectedStart = TimeOfDay.fromDateTime(fitnessClassMap['start'].toDate());
        _selectedEnd = TimeOfDay.fromDateTime(fitnessClassMap['end'].toDate());
        _selectedTrainer = fitnessClassMap['trainer'];
        _selectedRoom = fitnessClassMap['room'] == 'Room.aerobic'
            ? Room.aerobic
            : Room.functional;
        _counter = fitnessClassMap['reserved'];
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime lastDate = DateTime(
      DateTime.now().year + 1,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectStart() async {
    if (_selectedDate == null) {
      return;
    }

    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (start != null) {
      setState(() {
        _selectedStart = start;
      });
    }
  }

  Future<void> _selectEnd() async {
    if (_selectedStart == null) {
      return;
    }

    TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (end != null) {
      if (toDouble(_selectedStart!) > toDouble(end)) {
        _showError('Ora de sfârșit a clasei nu poate fi înaintea orei de începere.');
      }

      setState(() {
        _selectedEnd = end;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_form.currentState!.validate() ||
        _selectedDate == null ||
        _selectedStart == null ||
        _selectedEnd == null ||
        _selectedTrainer == null ||
        _selectedRoom == null) return;

    _form.currentState!.save();

    if (await verifyTrainerAvailability(
            widget.fitnessClassRef != null ? widget.fitnessClassRef!.id : '',
            _selectedTrainer!,
            _selectedDate!,
            _selectedStart!,
            _selectedEnd!) ==
        false) {
      _showError('Antrenorul este ocupat în acel interval orar.');
      return;
    }

    if (await verifyRoomAvailability(
            widget.fitnessClassRef != null ? widget.fitnessClassRef!.id : '',
            _selectedDate!,
            _selectedRoom!.toString(),
            _selectedStart!,
            _selectedEnd!) ==
        false) {
      _showError('Sala este ocupată în acel interval orar.');
      return;
    }

    try {
      if (widget.fitnessClassRef != null) {
        await widget.fitnessClassRef!.set({
          'className': _nameController.text,
          'date': _selectedDate,
          'start': convertToDateTime(_selectedDate!, _selectedStart!),
          'end': convertToDateTime(_selectedDate!, _selectedEnd!),
          'trainer': _selectedTrainer,
          'room': _selectedRoom.toString(),
          'capacity': _selectedRoom == Room.aerobic ? 25 : 20,
          'reserved': _counter,
        });
      } else {
        await FirebaseFirestore.instance.collection('classes').add({
          'className': _nameController.text,
          'date': _selectedDate,
          'start': convertToDateTime(_selectedDate!, _selectedStart!),
          'end': convertToDateTime(_selectedDate!, _selectedEnd!),
          'trainer': _selectedTrainer,
          'room': _selectedRoom.toString(),
          'capacity': _selectedRoom == Room.aerobic ? 25 : 20,
          'reserved': 0,
        });
      }

      _changeScreen();
    } on FirebaseException catch (error) {
      _showError(error.message);
    }
  }

  void _changeScreen() {
    Navigator.pop(context);
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Eroare'),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'trainer')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  if (snapshot.hasError) {
                    return const Text('Eroare');
                  }

                  List<DropdownMenuItem<DocumentReference>> trainers = snapshot
                      .data!.docs
                      .map((DocumentSnapshot<Map<String, dynamic>> trainer) {
                    return DropdownMenuItem(
                      value: trainer.reference,
                      child: Text(
                        '${trainer['lastName']} ${trainer['firstName']}',
                      ),
                    );
                  }).toList();

                  return SingleChildScrollView(
                    child: Card(
                      margin: const EdgeInsets.all(20),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Nume',
                                ),
                                controller: _nameController,
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Introduceți numele.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
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
                                    onPressed: _selectStart,
                                    child: Text(
                                      _selectedStart != null
                                          ? formatTime(_selectedStart!)
                                          : 'Start',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: _selectEnd,
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
                                  DropdownButton(
                                    items: trainers,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedTrainer = value;
                                        });
                                      }
                                    },
                                    value: _selectedTrainer,
                                    hint: const Text('Antrenor'),
                                  ),
                                  const SizedBox(width: 10),
                                  DropdownButton(
                                    value: _selectedRoom,
                                    items: Room.values
                                        .map(
                                          (room) => DropdownMenuItem(
                                            value: room,
                                            child: Text(room.name),
                                          ),
                                        ).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedRoom = value;
                                        });
                                      }
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
                                    child: const Text('Salvează'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
