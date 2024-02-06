import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/ClassUtils.dart';

class EditClass extends StatefulWidget {
  const EditClass({super.key, required this.classs});

  final DocumentReference classs;

  @override
  State<EditClass> createState() {
    return _EditClassState();
  }
}

class _EditClassState extends State<EditClass> {
  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStart;
  TimeOfDay? _selectedEnd;
  DocumentReference? _selectedTrainer;
  Room? _selectedRoom;
  int _counter = 0;

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date'),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      await widget.classs.set({
        'className': _nameController.text,
        'date': _selectedDate,
        'start': convert(_selectedDate!, _selectedStart!),
        'end': convert(_selectedDate!, _selectedEnd!),
        'trainer': _selectedTrainer,
        'room': _selectedRoom.toString(),
        'capacity': _selectedRoom == Room.aerobic ? 25 : 20,
        'reserved': _counter,
      });
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _selectDate() async {
    final lastDate = DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
    final date = await showDatePicker(
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

  void _selectStart() async {
    if (_selectedDate == null) {
      return;
    }

    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (await verifyRoomAvailability(_selectedDate!, _selectedRoom.toString(), _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Sala este ocupată în acel interval orar.');
    } else if (await verifyTrainerAvailability(_selectedTrainer!, _selectedDate!, _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Antrenorul este ocupat în acel interval orar.');
    }
    else if (start != null) {
      setState(() {
        _selectedStart = start;
      });
    }
  }

  void _selectEnd() async {
    if (_selectedStart == null) {
      return;
    }

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (toDouble(_selectedStart!) > toDouble(end!)) {
      _showBookingError('Ora de sfârșit a clasei nu poate fi înaintea orei de începere.');
    } else if(await verifyRoomAvailability(_selectedDate!, _selectedRoom.toString(), _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Sala este ocupată în acel interval orar.');
    } else if (await verifyTrainerAvailability(_selectedTrainer!, _selectedDate!, _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Antrenorul este ocupat în acel interval orar.');
    } else {
      setState(() {
        _selectedEnd = end;
    });
    }
  }

  void _selectTrainer(DocumentReference value) async {
    if(await verifyTrainerAvailability(value, _selectedDate!, _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Antrenorul este ocupat în acel interval orar.');
    } else {
      setState(() {
        _selectedTrainer = value;
      });
    }
  }

  void _selectRoom(Room value) async {
    if(await verifyRoomAvailability(_selectedDate!, value.toString(), _selectedStart!, _selectedEnd!) == false) {
      _showBookingError('Sala este ocupată în acel interval orar.');
    } else {
      setState(() {
        _selectedRoom = value;
      });
    }
  }

  void _loadData() async {
    var classData = await widget.classs.get();

    if (classData.exists) {
      Map<String, dynamic> classDataMap = classData.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = classDataMap['className'];
        _selectedDate = classDataMap['date'].toDate();
        _selectedStart = TimeOfDay.fromDateTime(classDataMap['start'].toDate());
        _selectedEnd = TimeOfDay.fromDateTime(classDataMap['end'].toDate());
        _selectedTrainer = classDataMap['trainer'];
        _selectedRoom = classDataMap['room'] == 'Room.aerobic' ? Room.aerobic : Room.functional;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
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
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
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
                        child: Text(_selectedDate != null
                            ? formatter.format(_selectedDate!)
                            : 'Data'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _selectStart,
                            child: Text(_selectedStart != null
                                ? formatTime(_selectedStart!)
                                : 'Start'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _selectEnd,
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
                                if (trainerSnapshots.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (trainerSnapshots.hasError) {
                                  return const Text('Eroare');
                                }

                                List<DropdownMenuItem<DocumentReference>> trainers = trainerSnapshots.data!.docs.map(
                                  (DocumentSnapshot<Map<String, dynamic>> trainer) {
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
                                    if (value != null) {
                                      _selectTrainer(value);
                                    }
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
                              if(value != null) {
                                _selectRoom(value);
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
                            onPressed: () {
                              _onSave();
                              Navigator.pop(context);
                            },
                            child: const Text('Salvează'),
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
        //),
      ),
    );
  }
}
