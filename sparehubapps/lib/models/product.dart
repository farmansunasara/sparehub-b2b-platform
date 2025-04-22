import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals;

class Product {
  final String? id;
  final String name;
  final String description;
  final String sku;
  final int? brandId;
  final int categoryId;
  final int subcategoryId;
  final int manufacturerId;
  final double price;
  final double discount;
  final int stockQuantity;
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  final double weight;
  final String? dimensions;
  final String? material;
  final String? color;
  final String? technicalSpecificationPdf;
  final String? installationGuidePdf;
  final double shippingCost;
  final String? shippingTime;
  final String? originCountry;
  final bool isActive;
  final bool isFeatured;
  final bool isApproved;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.sku,
    this.brandId,
    required this.categoryId,
    required this.subcategoryId,
    required this.manufacturerId,
    required this.price,
    this.discount = 0.0,
    required this.stockQuantity,
    this.minOrderQuantity = 1,
    this.maxOrderQuantity,
    required this.weight,
    this.dimensions,
    this.material,
    this.color,
    this.technicalSpecificationPdf,
    this.installationGuidePdf,
    this.shippingCost = 0.0,
    this.shippingTime,
    this.originCountry,
    this.isActive = true,
    this.isFeatured = false,
    this.isApproved = false,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    int? brandId,
    int? categoryId,
    int? subcategoryId,
    int? manufacturerId,
    double? price,
    double? discount,
    int? stockQuantity,
    int? minOrderQuantity,
    int? maxOrderQuantity,
    double? weight,
    String? dimensions,
    String? material,
    String? color,
    String? technicalSpecificationPdf,
    String? installationGuidePdf,
    double? shippingCost,
    String? shippingTime,
    String? originCountry,
    bool? isActive,
    bool? isFeatured,
    bool? isApproved,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      material: material ?? this.material,
      color: color ?? this.color,
      technicalSpecificationPdf: technicalSpecificationPdf ?? this.technicalSpecificationPdf,
      installationGuidePdf: installationGuidePdf ?? this.installationGuidePdf,
      shippingCost: shippingCost ?? this.shippingCost,
      shippingTime: shippingTime ?? this.shippingTime,
      originCountry: originCountry ?? this.originCountry,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isApproved: isApproved ?? this.isApproved,
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
      'brand_id': brandId,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'manufacturer': manufacturerId,
      'price': price,
      'discount': discount,
      'stock_quantity': stockQuantity,
      'min_order_quantity': minOrderQuantity,
      'max_order_quantity': maxOrderQuantity,
      'weight': weight,
      'dimensions': dimensions,
      'material': material,
      'color': color,
      'technical_specification_pdf': technicalSpecificationPdf,
      'installation_guide_pdf': installationGuidePdf,
      'shipping_cost': shippingCost,
      'shipping_time': shippingTime,
      'origin_country': originCountry,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_approved': isApproved,
      'images': images,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sku: json['sku'] ?? '',
      brandId: json['brand'] is Map ? json['brand']['id'] : json['brand_id'],
      categoryId: json['category'] is Map 
          ? json['category']['id'] 
          : json['category_id'] ?? 0,
      subcategoryId: json['subcategory'] is Map 
          ? json['subcategory']['id'] 
          : json['subcategory_id'] ?? 0,
      manufacturerId: json['manufacturer'] is Map 
          ? json['manufacturer']['id'] 
          : (json['manufacturer'] ?? 0),
      price: json['price'] != null
          ? (json['price'] is num
              ? json['price'].toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : 0.0,
      discount: json['discount'] != null
          ? (json['discount'] is num
              ? json['discount'].toDouble()
              : double.tryParse(json['discount'].toString()) ?? 0.0)
          : 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      minOrderQuantity: json['min_order_quantity'] ?? 1,
      maxOrderQuantity: json['max_order_quantity'],
      weight: json['weight'] != null
          ? (json['weight'] is num
              ? json['weight'].toDouble()
              : double.tryParse(json['weight'].toString()) ?? 0.0)
          : 0.0,
      dimensions: json['dimensions'],
      material: json['material'],
      color: json['color'],
      technicalSpecificationPdf: json['technical_specification_pdf'],
      installationGuidePdf: json['installation_guide_pdf'],
      shippingCost: json['shipping_cost'] != null
          ? (json['shipping_cost'] is num
              ? json['shipping_cost'].toDouble()
              : double.tryParse(json['shipping_cost'].toString()) ?? 0.0)
          : 0.0,
      shippingTime: json['shipping_time'],
      originCountry: json['origin_country'],
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      isApproved: json['is_approved'] ?? false,
      images: json['images'] != null
          ? List<String>.from(json['images'].map((img) => img['image']?.toString() ?? ''))
          : [],
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
        other.brandId == brandId &&
        other.categoryId == categoryId &&
        other.subcategoryId == subcategoryId &&
        other.manufacturerId == manufacturerId &&
        other.price == price &&
        other.discount == discount &&
        other.stockQuantity == stockQuantity &&
        other.minOrderQuantity == minOrderQuantity &&
        other.maxOrderQuantity == maxOrderQuantity &&
        other.weight == weight &&
        other.dimensions == dimensions &&
        other.material == material &&
        other.color == color &&
        other.technicalSpecificationPdf == technicalSpecificationPdf &&
        other.installationGuidePdf == installationGuidePdf &&
        other.shippingCost == shippingCost &&
        other.shippingTime == shippingTime &&
        other.originCountry == originCountry &&
        other.isActive == isActive &&
        other.isFeatured == isFeatured &&
        other.isApproved == isApproved &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    sku.hashCode ^
    brandId.hashCode ^
    categoryId.hashCode ^
    subcategoryId.hashCode ^
    manufacturerId.hashCode ^
    price.hashCode ^
    discount.hashCode ^
    stockQuantity.hashCode ^
    minOrderQuantity.hashCode ^
    maxOrderQuantity.hashCode ^
    weight.hashCode ^
    dimensions.hashCode ^
    material.hashCode ^
    color.hashCode ^
    technicalSpecificationPdf.hashCode ^
    installationGuidePdf.hashCode ^
    shippingCost.hashCode ^
    shippingTime.hashCode ^
    originCountry.hashCode ^
    isActive.hashCode ^
    isFeatured.hashCode ^
    isApproved.hashCode ^
    images.hashCode;
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stockQuantity)';
  }

  // Helper methods
  bool get isLowStock => stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity <= 0;

  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  double get discountedPrice => price - (price * (discount / 100));
  String get formattedDiscountedPrice => '₹${discountedPrice.toStringAsFixed(2)}';

  String get primaryImage => images.isNotEmpty ? images.first : '';
  List<String> get additionalImages => images.length > 1 ? images.sublist(1) : [];

  String get formattedDimensions => dimensions ?? 'Not specified';
  String get formattedWeight => '$weight kg';
  String get formattedShippingCost => shippingCost > 0 ? '₹${shippingCost.toStringAsFixed(2)}' : 'Free Shipping';
  String get formattedMaterial => material ?? 'Not specified';
  String get formattedColor => color ?? 'Not specified';
  String get formattedShippingTime => shippingTime ?? 'Not specified';
  String get formattedOriginCountry => originCountry ?? 'Not specified';

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
