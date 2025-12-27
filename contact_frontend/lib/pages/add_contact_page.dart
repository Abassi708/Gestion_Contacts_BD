import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  InputDecoration style(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Nouveau Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: style('Nom', Icons.person),
                        validator: (v) =>
                            v!.isEmpty ? 'Nom obligatoire' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: style('Téléphone', Icons.phone),
                        validator: (v) =>
                            v!.isEmpty ? 'Téléphone obligatoire' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: style('Email', Icons.email),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressCtrl,
                        decoration: style('Adresse', Icons.location_on),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: style('Notes', Icons.notes),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await ApiService.addContact(
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        email: emailCtrl.text,
                        address: addressCtrl.text,
                        notes: notesCtrl.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


