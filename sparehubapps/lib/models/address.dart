import 'package:json_annotation/json_annotation.dart';
import 'order.dart'; // Import OrderAddress

part 'address.g.dart';

enum AddressType {
  home,
  work,
  other,
}

@JsonSerializable()
class Address {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId; // Matches Django's user_id or user
  final String name;
  final String phone;
  @JsonKey(name: 'address_line1')
  final String addressLine1;
  @JsonKey(name: 'address_line2')
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  @JsonKey(fromJson: _addressTypeFromJson, toJson: _addressTypeToJson)
  final AddressType type;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Address({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.type,
    required this.isDefault,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

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
    );
  }

  static AddressType _addressTypeFromJson(String json) {
    switch (json) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      case 'other':
        return AddressType.other;
      default:
        throw ArgumentError('Invalid address type: $json');
    }
  }

  static String _addressTypeToJson(AddressType type) {
    switch (type) {
      case AddressType.home:
        return 'home';
      case AddressType.work:
        return 'work';
      case AddressType.other:
        return 'other';
    }
  }
}