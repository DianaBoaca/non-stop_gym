import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key, required this.user});

  final DocumentReference user;

  @override
  State<EditUser> createState() {
    return _EditUserState();
  }
}

class _EditUserState extends State<EditUser> {
  final _form = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String role = '';

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

  @override
  void dispose() {
    _lastNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      await widget.user.set({
        'lastName': _lastNameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'role': role,
      });
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }
  }

  void _loadData() async {
    var userData = await widget.user.get();

    if (userData.exists) {
      Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;

      setState(() {
        _lastNameController.text = userDataMap['lastName'];
        _surnameController.text = userDataMap['surname'];
        _emailController.text = userDataMap['email'];
        _phoneController.text = userDataMap['phone'];
        role = userDataMap['role'];
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
                        controller: _lastNameController,
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Prenume',
                        ),
                        controller: _surnameController,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduceți prenumele.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Adresă de email',
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Introduceți o adresă de email validă.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Număr de telefon',
                        ),
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.trim().length != 10) {
                            return 'Introduceți un număr valid.';
                          }
                          return null;
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
