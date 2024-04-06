import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditRule extends StatefulWidget {
  const EditRule({super.key, this.ruleRef});

  final DocumentReference<Map<String, dynamic>>? ruleRef;

  @override
  State<EditRule> createState() => _EditRuleState();
}

class _EditRuleState extends State<EditRule> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.ruleRef != null) _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot<Map<String, dynamic>> ruleSnapshot = await widget.ruleRef!.get();

    if (ruleSnapshot.exists) {
      Map<String, dynamic> ruleMap = ruleSnapshot.data()!;

      setState(() {
        _titleController.text = ruleMap['title'];
        _textController.text = ruleMap['text'];
        _isLoading = false;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_form.currentState!.validate()) return;

    _form.currentState!.save();

    try {
      if (widget.ruleRef != null) {
        await widget.ruleRef!.set({
          'title': _titleController.text,
          'text': _textController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('rules').add({
          'title': _titleController.text,
          'text': _textController.text,
        });
      }
    } on FirebaseException catch (error) {
      _showError(error);
    }
    _changeScreen();
  }

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

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
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
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Titlu',
                            ),
                            controller: _titleController,
                            autocorrect: false,
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
                            maxLines: null,
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
