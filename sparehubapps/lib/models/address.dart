import 'package:flutter/foundation.dart';

import 'order.dart';

enum AddressType {
  home,
  work,
  other,
}

class Address {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final AddressType type;
  final bool isDefault;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.type = AddressType.home,
    this.isDefault = false,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'type': type.toString(),
      'is_default': isDefault,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      type: AddressType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AddressType.home,
      ),
      isDefault: json['is_default'] ?? false,
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Address copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
    AddressType? type,
    bool? isDefault,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.phone == phone &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.state == state &&
        other.pincode == pincode &&
        other.country == country &&
        other.type == type &&
        other.isDefault == isDefault &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        addressLine1.hashCode ^
        addressLine2.hashCode ^
        city.hashCode ^
        state.hashCode ^
        pincode.hashCode ^
        country.hashCode ^
        type.hashCode ^
        isDefault.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty ?? false) addressLine2,
      city,
      state,
      pincode,
      country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return '$name\n$parts\nPhone: $phone';
  }

  String get typeText => type.toString().split('.').last;

  bool get isHomeAddress => type == AddressType.home;
  bool get isWorkAddress => type == AddressType.work;
  bool get isOtherAddress => type == AddressType.other;

  // Convert to OrderAddress
  OrderAddress toOrderAddress() {
    return OrderAddress(
      name: name,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      pincode: pincode,
      country: country,
      isDefault: isDefault,
    );
  }
}
