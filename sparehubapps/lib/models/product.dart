import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals, mapEquals;

class Product {
  final String? id;
  final String name;
  final String description;
  final String sku;
  final String? modelNumber;
  final int? brandId;
  final int categoryId;
  final int subcategoryId;
  final int manufacturerId;
  final List<int> compatibleCarIds;
  final List<String> categories;
  final double price;
  final double discount;
  final int stockQuantity;
  final int minOrderQuantity;
  final Map<String, dynamic> specifications;
  final String? technicalSpecificationPdf;
  final double weight;
  final String? dimensions;
  final double shippingCost;
  final bool isActive;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.sku,
    this.modelNumber,
    this.brandId,
    required this.categoryId,
    required this.subcategoryId,
    required this.manufacturerId,
    required this.compatibleCarIds,
    this.categories = const [],
    required this.price,
    this.discount = 0.0,
    required this.stockQuantity,
    this.minOrderQuantity = 1,
    this.specifications = const {},
    this.technicalSpecificationPdf,
    required this.weight,
    this.dimensions,
    this.shippingCost = 0.0,
    this.isActive = true,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? modelNumber,
    int? brandId,
    int? categoryId,
    int? subcategoryId,
    int? manufacturerId,
    List<int>? compatibleCarIds,
    List<String>? categories,
    double? price,
    double? discount,
    int? stockQuantity,
    int? minOrderQuantity,
    Map<String, dynamic>? specifications,
    String? technicalSpecificationPdf,
    double? weight,
    String? dimensions,
    double? shippingCost,
    bool? isActive,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      modelNumber: modelNumber ?? this.modelNumber,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      compatibleCarIds: compatibleCarIds ?? this.compatibleCarIds,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      specifications: specifications ?? this.specifications,
      technicalSpecificationPdf: technicalSpecificationPdf ?? this.technicalSpecificationPdf,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      shippingCost: shippingCost ?? this.shippingCost,
      isActive: isActive ?? this.isActive,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'model_number': modelNumber,
      'brand': brandId,
      'category': categoryId,
      'subcategory': subcategoryId,
      'manufacturer': manufacturerId,
      'compatible_cars': compatibleCarIds,
      'categories': categories,
      'price': price,
      'discount': discount,
      'stock': stockQuantity,
      'min_order_quantity': minOrderQuantity,
      'specifications': specifications,
      'technical_specification_pdf': technicalSpecificationPdf,
      'weight': weight,
      'dimensions': dimensions,
      'shipping_cost': shippingCost,
      'is_active': isActive,
      'images': images,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      sku: json['sku'],
      modelNumber: json['model_number'],
      brandId: json['brand'],
      categoryId: json['category'],
      subcategoryId: json['subcategory'],
      manufacturerId: json['manufacturer'],
      compatibleCarIds: List<int>.from(json['compatible_cars'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock'] ?? 0,
      minOrderQuantity: json['min_order_quantity'] ?? 1,
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      technicalSpecificationPdf: json['technical_specification_pdf'],
      weight: (json['weight'] as num).toDouble(),
      dimensions: json['dimensions'],
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Product.fromJsonString(String jsonString) {
    return Product.fromJson(json.decode(jsonString));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.sku == sku &&
        other.modelNumber == modelNumber &&
        other.brandId == brandId &&
        other.categoryId == categoryId &&
        other.subcategoryId == subcategoryId &&
        other.manufacturerId == manufacturerId &&
        listEquals(other.compatibleCarIds, compatibleCarIds) &&
        listEquals(other.categories, categories) &&
        other.price == price &&
        other.discount == discount &&
        other.stockQuantity == stockQuantity &&
        other.minOrderQuantity == minOrderQuantity &&
        mapEquals(other.specifications, specifications) &&
        other.technicalSpecificationPdf == technicalSpecificationPdf &&
        other.weight == weight &&
        other.dimensions == dimensions &&
        other.shippingCost == shippingCost &&
        other.isActive == isActive &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    sku.hashCode ^
    modelNumber.hashCode ^
    brandId.hashCode ^
    categoryId.hashCode ^
    subcategoryId.hashCode ^
    manufacturerId.hashCode ^
    compatibleCarIds.hashCode ^
    categories.hashCode ^
    price.hashCode ^
    discount.hashCode ^
    stockQuantity.hashCode ^
    minOrderQuantity.hashCode ^
    specifications.hashCode ^
    technicalSpecificationPdf.hashCode ^
    weight.hashCode ^
    dimensions.hashCode ^
    shippingCost.hashCode ^
    isActive.hashCode ^
    images.hashCode;
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stockQuantity)';
  }

  // Helper methods
  bool get isLowStock => stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity <= 0;

  // Compatibility getters for old field names
  int get stock => stockQuantity;
  bool get availability => isActive;
  Map<String, dynamic> get technicalSpecifications => specifications;

  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  double get discountedPrice => price - (price * (discount / 100));
  String get formattedDiscountedPrice => '₹${discountedPrice.toStringAsFixed(2)}';

  String get primaryImage => images.isNotEmpty ? images.first : '';
  List<String> get additionalImages => images.length > 1 ? images.sublist(1) : [];

  String get formattedDimensions => dimensions ?? 'Not specified';
  String get formattedWeight => '$weight kg';
  String get formattedShippingCost => shippingCost > 0 ? '₹${shippingCost.toStringAsFixed(2)}' : 'Free Shipping';

  static List<Product> sortByName(List<Product> products, {bool ascending = true}) {
    products.sort((a, b) => ascending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
    return products;
  }

  static List<Product> sortByPrice(List<Product> products, {bool ascending = true}) {
    products.sort((a, b) => ascending
        ? a.discountedPrice.compareTo(b.discountedPrice)
        : b.discountedPrice.compareTo(a.discountedPrice));
    return products;
  }

  static List<Product> sortByStock(List<Product> products, {bool ascending = true}) {
    products.sort((a, b) => ascending
        ? a.stockQuantity.compareTo(b.stockQuantity)
        : b.stockQuantity.compareTo(a.stockQuantity));
    return products;
  }

  static List<Product> filterByPriceRange(
      List<Product> products,
      double minPrice,
      double maxPrice,
      ) {
    return products
        .where((p) => p.discountedPrice >= minPrice && p.discountedPrice <= maxPrice)
        .toList();
  }

  static List<Product> filterByStock(List<Product> products, int minStock) {
    return products.where((p) => p.stockQuantity >= minStock).toList();
  }

  static List<Product> searchProducts(List<Product> products, String query) {
    final lowercaseQuery = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
          p.description.toLowerCase().contains(lowercaseQuery) ||
          p.sku.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
