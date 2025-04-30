import 'package:flutter/foundation.dart';
import 'product.dart';

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get total => items.fold(
      0, (sum, item) => sum + (item.product.price * item.quantity));

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // NEW: Add total getter
  double get total => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Handle backend's simplified items format
    return CartItem(
      product: Product(
        id: json['product_id']?.toString() ?? '',
        name: 'Unknown Product',
        price: json['price']?.toDouble() ?? 0.0,
        description: '',
        sku: '',
        categoryId: 0,
        subcategoryId: 0,
        manufacturerId: 0,
        stockQuantity: 0,
        weight: 0.0,
      ),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product == product &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => product.hashCode ^ quantity.hashCode;
} 