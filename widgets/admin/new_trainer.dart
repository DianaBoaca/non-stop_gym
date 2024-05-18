import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewTrainer extends StatefulWidget {
  const NewTrainer({super.key});

  @override
  State<NewTrainer> createState() => _NewTrainerState();
}

class _NewTrainerState extends State<NewTrainer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _enteredLastName;
  late String _enteredFirstName;
  late String _enteredPhone;
  late String _enteredEmail;
  late String _enteredPassword;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      UserCredential userCredentials =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'lastName': _enteredLastName,
        'firstName': _enteredFirstName,
        'email': _enteredEmail,
        'phone': _enteredPhone,
        'role': 'trainer',
      });
    } on FirebaseException catch (error) {
      _showError(error);
    }

    _changeScreen();
  }

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  void _changeScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adresă de email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Introduceți o adresă de email validă.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredEmail = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Parolă',
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Parola trebuie să aibă cel puțin 6 caractere!';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredPassword = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nume',
                      ),
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceți numele.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredLastName = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Prenume',
                      ),
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduceți prenumele.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredFirstName = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Număr de telefon',
                      ),
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length != 10) {
                          return 'Introduceți un număr valid.';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _enteredPhone = value!;
                      },
                    ),
                    const SizedBox(height: 20),
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
                          },
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
        ),
      ),
    );
  }
}
