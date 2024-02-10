import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewRule extends StatefulWidget {
  const NewRule({super.key});

  @override
  State<NewRule> createState() => _NewRuleState();
}

class _NewRuleState extends State<NewRule> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  String _enteredTitle = '';
  String _enteredText = '';

  void _showError(FirebaseException error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'Eroare stocare date.'),
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

    _form.currentState!.save();

    try {
      await FirebaseFirestore.instance.collection('rules').add({
        'title': _enteredTitle,
        'text': _enteredText,
      });

      _changeScreen();
    } on FirebaseException catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Titlu',
                    ),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduceți titlul.';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _enteredTitle = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Text',
                    ),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduceți textul.';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _enteredText = value!;
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
      ),
    );
  }
}
