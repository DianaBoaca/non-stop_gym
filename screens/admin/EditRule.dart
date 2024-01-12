import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditRule extends StatefulWidget {
  const EditRule({super.key, required this.rule});

  final DocumentReference rule;

  @override
  State<EditRule> createState() {
    return _EditRuleState();
  }
}

class _EditRuleState extends State<EditRule> {
  final _form = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

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
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    try {
      await widget.rule.set({
        'title': _titleController.text,
        'text': _textController.text,
      });
    } on FirebaseAuthException catch (error) {
      _showError(error);
    }
  }

  void _loadData() async {
    var ruleData = await widget.rule.get();

    if (ruleData.exists) {
      Map<String, dynamic> userDataMap = ruleData.data() as Map<String, dynamic>;

      setState(() {
        _titleController.text = userDataMap['title'];
        _textController.text = userDataMap['text'];
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
                          labelText: 'Titlu',
                        ),
                        controller: _titleController,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduceți titlul.';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Text',
                        ),
                        controller: _textController,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        maxLines: null,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduceți textul.';
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
