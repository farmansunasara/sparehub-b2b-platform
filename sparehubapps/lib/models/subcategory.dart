class Subcategory {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.image,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? slug,
    String? image,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      categoryId: json['category'] != null ? json['category']['id'] : json['category_id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'image': image,
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