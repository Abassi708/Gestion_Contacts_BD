import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ApiService {
  // ⚠️ Chrome / Windows
  static const String baseUrl = 'http://localhost:3000';

  // ⚠️ Android Emulator (si besoin)
  // static const String baseUrl = 'http://10.0.2.2:3000';

  /// ================================
  /// GET : récupérer tous les contacts
  /// ================================
  static Future<List<Contact>> getContacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contacts'),
      );

      print('GET STATUS: ${response.statusCode}');
      print('GET BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Contact.fromJson(e)).toList();
      } else {
        throw Exception('Erreur chargement contacts');
      }
    } catch (e) {
      print('GET ERROR: $e');
      throw Exception('Impossible de récupérer les contacts');
    }
  }

  /// ============================
  /// POST : ajouter un contact
  /// ============================
  static Future<void> addContact({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'notes': notes,
        }),
      );

      print('POST STATUS: ${response.statusCode}');
      print('POST BODY: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Erreur ajout contact');
      }
    } catch (e) {
      print('POST ERROR: $e');
      throw Exception('Impossible d’ajouter le contact');
    }
  }

  /// ============================
  /// DELETE : supprimer un contact
  /// ============================
  static Future<void> deleteContact(String id) async {
    try {
      print('SUPPRESSION CONTACT ID: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/contacts/$id'),
      );

      print('DELETE STATUS: ${response.statusCode}');
      print('DELETE BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Erreur suppression contact');
      }
    } catch (e) {
      print('DELETE ERROR: $e');
      throw Exception('Impossible de supprimer le contact');
    }
  }

  /// ============================
/// PUT : modifier un contact
/// ============================
static Future<void> updateContact({
  required String id,
  required String name,
  required String phone,
  required String email,
  required String address,
  required String notes,
}) async {
  try {
    print('MISE À JOUR CONTACT ID: $id');
    
    final response = await http.put(
      Uri.parse('$baseUrl/contacts/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
      }),
    );

    print('PUT STATUS: ${response.statusCode}');
    print('PUT BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erreur modification contact');
    }
  } catch (e) {
    print('PUT ERROR: $e');
    throw Exception('Impossible de modifier le contact');
  }
}
}




 






