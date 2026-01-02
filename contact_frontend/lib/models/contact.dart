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
      // ✅ CORRECTION ICI: 'id' au lieu de '_id'
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
    };
  }

  // Pour créer un nouveau contact sans ID
  factory Contact.empty() {
    return Contact(
      id: '',
      name: '',
      phone: '',
      email: '',
      address: '',
      notes: '',
    );
  }

  // Pour copier avec modifications
  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
}


