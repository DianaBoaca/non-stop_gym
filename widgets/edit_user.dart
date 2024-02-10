import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key, required this.user});

  final DocumentReference user;

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      await widget.user.update({
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  void _loadData() async {
    DocumentSnapshot<Object?> userData = await widget.user.get();

    if (userData.exists) {
      Map<String, dynamic> userDataMap =
          userData.data() as Map<String, dynamic>;

      setState(() {
        _lastNameController.text = userDataMap['lastName'];
        _firstNameController.text = userDataMap['firstName'];
        _emailController.text = userDataMap['email'];
        _phoneController.text = userDataMap['phone'];
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
    return Center(
      child: SingleChildScrollView(
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
                      labelText: 'Adresă de email',
                    ),
                    controller: _emailController,
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
    );
  }
}
