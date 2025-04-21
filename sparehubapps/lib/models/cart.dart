import 'package:flutter/foundation.dart' show listEquals;
import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.discountedPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
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

class Cart {
  final List<CartItem> items;

  const Cart({
    this.items = const [],
  });

  double get total => items.fold(
    0,
        (sum, item) => sum + item.total,
  );

  int get itemCount => items.fold(
    0,
        (sum, item) => sum + item.quantity,
  );

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    List<CartItem>? items,
  }) {
    return Cart(
      items: items ?? this.items,
    );
  }

  Cart addItem(Product product, {int quantity = 1}) {
    final items = List<CartItem>.from(this.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItem(
        product: product,
        quantity: quantity,
      ));
    }

    return copyWith(items: items);
  }

  Cart updateQuantity(String productId, int quantity) {
    final items = List<CartItem>.from(this.items);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (quantity > 0) {
        items[index] = items[index].copyWith(quantity: quantity);
      } else {
        items.removeAt(index);
      }
    }

    return copyWith(items: items);
  }

  Cart removeItem(String productId) {
    final items = List<CartItem>.from(this.items)
      ..removeWhere((item) => item.product.id == productId);
    return copyWith(items: items);
  }

  Cart clear() {
    return const Cart();
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;
}
