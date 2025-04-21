import 'brand.dart';

class Car {
  final int id;
  final Brand brand;
  final String name;
  final String model;
  final int year;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Car({
    required this.id,
    required this.brand,
    required this.name,
    required this.model,
    required this.year,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Car copyWith({
    int? id,
    Brand? brand,
    String? name,
    String? model,
    int? year,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      model: model ?? this.model,
      year: year ?? this.year,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: Brand.fromJson(json['brand']),
      name: json['name'],
      model: json['model'],
      year: json['year'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand.toJson(),
      'name': name,
      'model': model,
      'year': year,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car &&
        other.id == id &&
        other.brand == brand &&
        other.name == name &&
        other.model == model &&
        other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    brand.hashCode ^
    name.hashCode ^
    model.hashCode ^
    year.hashCode;
  }

  @override
  String toString() {
    return 'Car(id: $id, brand: ${brand.name}, name: $name, model: $model, year: $year)';
  }

  // Helper methods
  String get fullName => '${brand.name} $name $model $year';
  String get displayName => '$name $model';
}
