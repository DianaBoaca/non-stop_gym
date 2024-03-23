import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key, this.userRef});

  final DocumentReference<Map<String, dynamic>>? userRef;

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userRef != null) _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await widget.userRef!.get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userMap = userSnapshot.data()!;

      setState(() {
        _lastNameController.text = userMap['lastName'];
        _firstNameController.text = userMap['firstName'];
        _phoneController.text = userMap['phone'];
        _isLoading = false;
      });
    }
  }

  void _onSave() async {
    if (!_form.currentState!.validate()) return;

    _form.currentState!.save();

    try {
      if (widget.userRef != null) {
        await widget.userRef!.update({
          'lastName': _lastNameController.text,
          'firstName': _firstNameController.text,
          'phone': _phoneController.text,
        });
      } else {
        final userCredentials =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'lastName': _lastNameController.text,
          'firstName': _firstNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'role': 'trainer',
        });
      }
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
      ),
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          if (widget.userRef == null) ...[
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Adresă de email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Introduceți o adresă de email validă.';
                                }

                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Parolă',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Parola trebuie să aibă cel puțin 6 caractere!';
                                }

                                return null;
                              },
                            ),
                          ],
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
                            controller: _firstNameController,
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
                              labelText: 'Număr de telefon',
                            ),
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length != 10) {
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
        ),
      ),
    );
  }
}
