import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/tabs_utils.dart';
import 'admin/admin_home.dart';
import 'users/user_tabs.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _enteredLastName;
  late String _enteredFirstName;
  late String _enteredPhone;
  late String _enteredEmail;
  late String _enteredPassword;
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential userCredentials;

      if (_isLogin) {
        userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userSnapshot['role'] == 'client') {
        _route(
          UserTabsScreen(
            tabTitles: clientTabTitles,
            activeTabs: clientActiveTabs,
            icons: clientIcons,
            tabLabels: clientTabLabels,
          ),
        );
      } else if (userSnapshot['role'] == 'trainer') {
        _route(
          UserTabsScreen(
            tabTitles: trainerTabTitles,
            activeTabs: trainerActiveTabs,
            icons: trainerIcons,
            tabLabels: trainerTabLabels,
          ),
        );
      } else {
        _route(const AdminHomeScreen());
      }
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String generateRandomString() {
    Random random = Random();
    String randomString = '';

    for (int i = 0; i < 10; i++) {
      randomString += random.nextInt(10).toString();
    }

    return randomString;
  }

  void _route(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _enteredEmail);
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }
  }

  void _showError(FirebaseAuthException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare de autentificare.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        if (!_isLogin) ...[
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
                        ],
                        const SizedBox(height: 20),
                        if (_isLoading) const CircularProgressIndicator(),
                        if (!_isLoading)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 156, 124, 222,
                              ),
                            ),
                            child: Text(
                                _isLogin ? 'Log in' : 'Sign up',
                              style: const TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        if (!_isLoading)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                                _isLogin ? 'Creare cont nou' : 'Am deja cont'),
                          ),
                        if (!_isLoading && _isLogin)
                          TextButton(
                            onPressed: _resetPassword,
                            child: const Text('Am uitat parola'),
                          ),
                      ],
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
