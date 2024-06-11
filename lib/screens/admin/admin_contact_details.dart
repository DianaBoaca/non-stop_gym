import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

DocumentReference<Map<String, dynamic>> _firebase = FirebaseFirestore.instance
    .collection('contact')
    .doc('XZc7U6u8uXpXVJsO1hIK');

class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _isEditable = false;
  bool _isLoading = false;
  File? _selectedImageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot<Map<String, dynamic>> contactSnapshot = await _firebase.get();

    if (contactSnapshot.exists) {
      setState(() {
        _addressController.text = contactSnapshot['location'];
        _phoneController.text = contactSnapshot['phone'];
        _emailController.text = contactSnapshot['email'];
        _websiteController.text = contactSnapshot['website'];
        _capacityController.text = contactSnapshot['capacity'].toString();
        _imageUrl = contactSnapshot['tarife'];
        _isLoading = false;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_form.currentState!.validate()) return;

    _form.currentState!.save();

    setState(() {
      _isEditable = !_isEditable;
    });

    String url = '';

    if (_selectedImageFile != null) {
      Reference storageRef = FirebaseStorage.instance.ref().child('tarife').child('tarife2024');
      await storageRef.putFile(_selectedImageFile!);
      url = await storageRef.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });
    }

    try {
      await _firebase.update({
        'location': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
        'capacity': int.tryParse(_capacityController.text),
        'tarife': _imageUrl,
      });
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Eroare stocare date.'),
          ),
        );
      }
    }
  }

  Future<void> _selectImage() async {
    XFile? selectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage != null) {
      setState(() {
        _selectedImageFile = File(selectedImage.path);
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
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
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
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
                                  labelText: 'Adresă',
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
                                  labelText: 'Număr de telefon',
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
                                  labelText: 'Email',
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
                                  labelText: 'Website',
                                ),
                                controller: _websiteController,
                                enabled: _isEditable,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Introduceți un website.';
                                  }

                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Capacitate',
                                ),
                                controller: _capacityController,
                                enabled: _isEditable,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Introduceți un număr întreg.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _isEditable ? _selectImage : null,
                                child: Container(
                                  width: 260,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _imageUrl == null &&
                                          _selectedImageFile == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate,
                                              size: 40,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const Text('Tarife'),
                                          ],
                                        )
                                      : _selectedImageFile != null
                                          ? Image.file(_selectedImageFile!)
                                          : Image.network(_imageUrl!),
                                ),
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
