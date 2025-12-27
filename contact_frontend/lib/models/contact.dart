class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'], // 🔥 TRÈS IMPORTANT
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}


