import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseFirestore.instance.collection('contact').doc('XZc7U6u8uXpXVJsO1hIK');

class AdminContactScreen extends StatefulWidget {
  const AdminContactScreen({super.key});

  @override
  State<AdminContactScreen> createState() {
    return _AdminContactScreenState();
  }
}

class _AdminContactScreenState extends State<AdminContactScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  var _isEditable = false;
  final _form = GlobalKey<FormState>();

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.message ?? 'Eroare de autentificare.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onSave() async {
    setState(() {
      _isEditable = !_isEditable;
    });

    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      await _firebase.set({
        'location': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
      });
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _loadData() async {
    var contactDetails = await _firebase.get();

    if (contactDetails.exists) {
      _addressController.text = contactDetails.data()!['location'];
      _phoneController.text = contactDetails.data()!['phone'];
      _emailController.text = contactDetails.data()!['email'];
      _websiteController.text = contactDetails.data()!['website'];
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
      appBar: AppBar(
        title: const Text('Contact'),
        actions: [
          IconButton(
            onPressed: _onSave,
            icon: Icon(_isEditable ? Icons.save : Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Adresă'
                            ),
                            controller: _addressController,
                            enabled: _isEditable,
                            keyboardType: TextInputType.streetAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introduceți o adresă.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Număr de telefon'
                            ),
                            controller: _phoneController,
                            enabled: _isEditable,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length != 10) {
                                return 'Introduceți un număr valid.';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email'
                            ),
                            controller: _emailController,
                            enabled: _isEditable,
                            keyboardType: TextInputType.emailAddress,
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
                                labelText: 'Website'
                            ),
                            controller: _websiteController,
                            enabled: _isEditable,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Introduceți un website.';
                              }
                              return null;
                            },
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
