import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:non_stop_gym/screens/admin/admin_home.dart';
import 'package:non_stop_gym/screens/client/client_tabs.dart';
import 'dart:math';

String generateRandomString() {
  Random random = Random();
  String randomString = '';

  for (int i = 0; i < 10; i++) {
    randomString += random.nextInt(10).toString();
  }

  return randomString;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  String _enteredLastName = '';
  String _enteredFirstName = '';
  String _enteredPhone = '';
  String _enteredEmail = '';
  String _enteredPassword = '';
  bool _isAuthenticating = false;

  void _showError(FirebaseAuthException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare de autentificare.'),
      ),
    );
  }

  void _route(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        final userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
          'role': 'client',
          'checkedIn': false,
          'id': generateRandomString(),
        });
      }

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      String role = userData.data()!['role'];
      if (role == 'client') {
        _route(const ClientTabsScreen());
      } else {
        _route(const AdminHomeScreen());
      }
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }

    setState(() {
      _isAuthenticating = false;
    });
  }

  void _reset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _enteredEmail);
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                width: 325,
                child: Image.asset('assets/images/logo.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Adresă de email',
                            ),
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
                            onSaved: (value) {
                              _enteredEmail = value!;
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
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Nume',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
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
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Prenume',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
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
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Număr de telefon',
                              ),
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
                              onSaved: (value) {
                                _enteredPhone = value!;
                              },
                            ),
                          const SizedBox(height: 20),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Text(_isLogin
                                  ? 'Log in'
                                  : 'Sign up'
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Creare cont nou'
                                  : 'Am deja cont'
                              ),
                            ),
                          if (!_isAuthenticating && _isLogin)
                            TextButton(
                              onPressed: _reset,
                              child: const Text('Am uitat parola'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
