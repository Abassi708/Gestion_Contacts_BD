import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import 'add_contact_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late Future<List<Contact>> contacts;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      contacts = ApiService.getContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes contacts')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactPage()),
          );
          refresh();
        },
      ),
      body: FutureBuilder<List<Contact>>(
        future: contacts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: snapshot.data!.map((contact) {
              return Card(
                child: ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await ApiService.deleteContact(contact.id);
                      refresh();
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
