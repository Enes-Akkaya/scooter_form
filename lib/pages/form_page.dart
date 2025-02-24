import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scooter_form/services/auth/auth_service.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _scooterIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Map<String, bool> tasks = {
    'Batarya değişti': false,
    'Temizlik yapıldı': false,
    'Fren testi yapıldı': false,
    'Zil testi yapıldı': false,
    'Ön teker testi yapıldı': false,
    'Arka teker testi yapıldı': false,
    'Gidon testi yapıldı': false,
    'Yer değişikliği yapıldı': false,
    'Sorunlu servise gönderildi': false,
    'Dış servise gönderildi': false,
  };

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _authService.getCurrentUser();
      String userName = await _authService.getUserNameById(user!.uid);
      if (user != null) {
        // Filter tasks to only include the ones that are true
        final filteredTasks = tasks.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        await FirebaseFirestore.instance.collection('forms').add({
          'userId': user.uid,
          'userName': userName,
          'scooterId': _scooterIdController.text,
          'tasks': filteredTasks,
          'notes': _notesController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the form fields
        _scooterIdController.clear();
        _notesController.clear();
        setState(() {
          tasks = tasks.map((key, value) => MapEntry(key, false));
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form submitted successfully')));
      }
    }
  }

  void logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scooter Denetleme Formu'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _scooterIdController,
                decoration: InputDecoration(
                  labelText: 'Scooter ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen scooter IDyi girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: tasks.keys.map((String key) {
                    return CheckboxListTile(
                      title: Text(key),
                      value: tasks[key],
                      onChanged: (bool? value) {
                        setState(() {
                          tasks[key] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Ek notlar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Gönder', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
