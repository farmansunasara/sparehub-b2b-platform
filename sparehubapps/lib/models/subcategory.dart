class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? icon;
  final String? image;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? slug,
    String? icon,
    String? image,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      image: image ?? this.image,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      categoryId: json['category'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'],
      image: json['image'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': categoryId,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image': image,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subcategory &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.slug == slug;
  }

  @override
  int get hashCode => id.hashCode ^ categoryId.hashCode ^ slug.hashCode;

  @override
  String toString() => 'Subcategory(id: $id, name: $name)';
}
