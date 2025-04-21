class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String name;
  final String phone;
  final String address;
  final String gst;
  final String? logo;
  final String? license;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.address,
    required this.gst,
    this.logo,
    this.license,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing User JSON: $json'); // Debug log
      return User(
        id: (json['id'] ?? '').toString(), // Ensure id is always a string
        username: json['username']?.toString() ?? json['email']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        name: json['companyName']?.toString() ??
            json['shopName']?.toString() ??
            json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        gst: json['gst']?.toString() ?? '',
        logo: json['logo']?.toString(),
        license: json['license']?.toString(),
        createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Error parsing User JSON: $e\nStackTrace: $stackTrace\nJSON: $json'); // Detailed debug log
      throw FormatException('Error parsing User from JSON: $e\nJSON: $json');
    }
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      print('Error parsing date: $date, Error: $e'); // Debug date parsing
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final isManufacturer = role.toLowerCase() == 'manufacturer';
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      if (isManufacturer) 'companyName': name else 'shopName': name,
      'phone': phone,
      'address': address,
      'gst': gst,
      'logo': logo,
      'license': license,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? name,
    String? phone,
    String? address,
    String? gst,
    String? logo,
    String? license,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gst: gst ?? this.gst,
      logo: logo ?? this.logo,
      license: license ?? this.license,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}