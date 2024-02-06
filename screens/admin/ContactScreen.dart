import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseFirestore.instance.collection('contact').doc('XZc7U6u8uXpXVJsO1hIK');

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() {
    return _ContactScreenState();
  }
}

class _ContactScreenState extends State<ContactScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isEditable = false;
  final _form = GlobalKey<FormState>();
  File? _selectedImageFile;
  String? _imageUrl;

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
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onSave() async {
    String url = '';

    setState(() {
      _isEditable = !_isEditable;
    });

    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    }

    if (_selectedImageFile != null) {
      Reference storageRef = FirebaseStorage.instance.ref()
          .child('tarife')
          .child('tarife2024.jpg');
      await storageRef.putFile(_selectedImageFile!);
      url = await storageRef.getDownloadURL();
      try {
        await _firebase.update({
          'location': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'website': _websiteController.text,
          'tarife': url,
        });
      } on FirebaseException catch (error) {
        _showError(error);
      }
    }
  }


  void _loadData() async {
    var contactDetails = await _firebase.get();

    if (contactDetails.exists) {
      setState(() {
        _addressController.text = contactDetails.data()!['location'];
        _phoneController.text = contactDetails.data()!['phone'];
        _emailController.text = contactDetails.data()!['email'];
        _websiteController.text = contactDetails.data()!['website'];
        _imageUrl = contactDetails.data()!['tarife'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _selectImage() async {
    final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _selectedImageFile = File(selectedImage.path);
      });
    }
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Adresă',
                            //labelStyle: _isEditable ? null : const TextStyle(color: Colors.black),
                            // disabledBorder: _isEditable
                            //     ? null
                            //     : const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          ),
                          controller: _addressController,
                          enabled: _isEditable,
                          keyboardType: TextInputType.streetAddress,
                          //style: _isEditable ? null : const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Introduceți o adresă.';
                            }
                            return null;
                            },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Număr de telefon'),
                          controller: _phoneController,
                          enabled: _isEditable,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty || value.trim().length != 10) {
                              return 'Introduceți un număr valid.';
                            }
                            return null;
                            },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          controller: _emailController,
                          enabled: _isEditable,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty || !value.contains('@')) {
                              return 'Introduceți o adresă de email validă.';
                            }
                            return null;
                            },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Website'),
                          controller: _websiteController,
                          enabled: _isEditable,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Introduceți un website.';
                            }
                            return null;
                            },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _isEditable ? _selectImage : null,
                          child: Container(
                            width: 140,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: _imageUrl == null && _selectedImageFile == null
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
