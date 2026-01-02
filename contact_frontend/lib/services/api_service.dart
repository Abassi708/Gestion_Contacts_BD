import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ApiService {
  // ⚠️ IMPORTANT: Port 8000 au lieu de 3000/3800
  static const String baseUrl = 'http://localhost:8000';
  
  // Pour Android Emulator (décommentez si besoin)
  // static const String baseUrl = 'http://10.0.2.2:8000';

  /// ================================
  /// GET : récupérer tous les contacts
  /// ================================
  static Future<List<Contact>> getContacts() async {
    try {
      final url = Uri.parse('$baseUrl/contacts');
      print('🌐 GET URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 GET STATUS: ${response.statusCode}');
      print('📥 GET BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('✅ GET SUCCESS: ${data.length} contacts retrieved');
        return data.map((e) => Contact.fromJson(e)).toList();
      } else {
        print('❌ GET ERROR: Status ${response.statusCode}');
        throw Exception('Erreur chargement contacts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ GET EXCEPTION: $e');
      throw Exception('Impossible de récupérer les contacts: $e');
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
      final url = Uri.parse('$baseUrl/contacts');
      print('🌐 POST URL: $url');
      
      final body = json.encode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
      });
      
      print('📤 POST BODY SENT: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('📥 POST STATUS: ${response.statusCode}');
      print('📥 POST BODY: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ POST SUCCESS: Contact added');
      } else {
        print('❌ POST ERROR: Status ${response.statusCode}');
        throw Exception('Erreur ajout contact: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ POST EXCEPTION: $e');
      throw Exception('Impossible d\'ajouter le contact: $e');
    }
  }

  /// ============================
  /// DELETE : supprimer un contact
  /// ============================
  static Future<void> deleteContact(String id) async {
    try {
      final url = Uri.parse('$baseUrl/contacts/$id');
      print('🌐 DELETE URL: $url');
      print('🗑️ DELETE CONTACT ID: $id');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📥 DELETE STATUS: ${response.statusCode}');
      print('📥 DELETE BODY: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ DELETE SUCCESS: Contact deleted');
      } else {
        print('❌ DELETE ERROR: Status ${response.statusCode}');
        throw Exception('Erreur suppression contact: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ DELETE EXCEPTION: $e');
      throw Exception('Impossible de supprimer le contact: $e');
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
      final url = Uri.parse('$baseUrl/contacts/$id');
      print('🌐 PUT URL: $url');
      print('✏️ UPDATE CONTACT ID: $id');
      
      final body = json.encode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
      });
      
      print('📤 PUT BODY SENT: $body');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('📥 PUT STATUS: ${response.statusCode}');
      print('📥 PUT BODY: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ PUT SUCCESS: Contact updated');
      } else {
        print('❌ PUT ERROR: Status ${response.statusCode}');
        throw Exception('Erreur modification contact: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ PUT EXCEPTION: $e');
      throw Exception('Impossible de modifier le contact: $e');
    }
  }
}




 






