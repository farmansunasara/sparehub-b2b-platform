import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  static const String _cartKey = 'cart_data';
  final SharedPreferences _prefs;
  Cart _cart = const Cart();
  bool _isLoading = false;
  String? _error;

  CartProvider(this._prefs) {
    _loadCart();
  }

  // Getters
  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CartItem> get items => _cart.items;
  double get total => _cart.total;
  int get itemCount => _cart.itemCount;
  bool get isEmpty => _cart.isEmpty;
  bool get isNotEmpty => _cart.isNotEmpty;

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final cartJson = _prefs.getString(_cartKey);
      if (cartJson != null) {
        _cart = Cart.fromJson(json.decode(cartJson));
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _error = 'Failed to load cart';
      // If there's an error loading the cart, start with an empty cart
      _cart = const Cart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh cart data
  Future<void> refreshCart() async {
    await _loadCart();
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      _error = null;
      await _prefs.setString(_cartKey, json.encode(_cart.toJson()));
    } catch (e) {
      debugPrint('Error saving cart: $e');
      _error = 'Failed to save cart';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add item to cart
  Future<void> addItem(Product product, {int quantity = 1}) async {
    if (quantity <= 0) return;

    // Check if adding this quantity would exceed available stock
    final existingItem = _cart.items.firstWhere(
          (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    final newQuantity = existingItem.quantity + quantity;
    if (newQuantity > product.stockQuantity) {
      throw Exception('Cannot add more items than available in stock');
    }

    _cart = _cart.addItem(product, quantity: quantity);
    notifyListeners();
    await _saveCart();
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity < 0) return;

    final item = _cart.items.firstWhere(
          (item) => item.product.id == productId,
      orElse: () => throw Exception('Product not found in cart'),
    );

    if (quantity > item.product.stockQuantity) {
      throw Exception('Cannot add more items than available in stock');
    }

    _cart = _cart.updateQuantity(productId, quantity);
    notifyListeners();
    await _saveCart();
  }

  // Remove item from cart
  Future<void> removeItem(String productId) async {
    _cart = _cart.removeItem(productId);
    notifyListeners();
    await _saveCart();
  }

  // Clear cart
  Future<void> clear() async {
    _cart = _cart.clear();
    notifyListeners();
    await _saveCart();
  }

  // Check if a product is in the cart
  bool hasProduct(String productId) {
    return _cart.items.any((item) => item.product.id == productId);
  }

  // Get quantity of a product in cart
  int getQuantity(String productId) {
    final item = _cart.items.firstWhere(
          (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(
          id: productId,
          name: '',
          description: '',
          sku: '',
          categoryId: 0,
          subcategoryId: 0,
          manufacturerId: 0,
          price: 0,
          stockQuantity: 0,
          weight: 0,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Validate cart items against current stock
  List<String> validateStock() {
    final List<String> outOfStockItems = [];

    for (final item in _cart.items) {
      if (item.quantity > item.product.stockQuantity) {
        outOfStockItems.add(item.product.name);
      }
    }

    return outOfStockItems;
  }

  // Calculate shipping cost
  double calculateShippingCost() {
    // TODO: Implement proper shipping cost calculation
    return _cart.items.fold(
      0,
          (sum, item) => sum + (item.product.shippingCost * item.quantity),
    );
  }

  // Calculate tax
  double calculateTax() {
    // TODO: Implement proper tax calculation
    return _cart.total * 0.18; // 18% GST
  }

  // Get order summary
  Map<String, double> getOrderSummary() {
    final subtotal = _cart.total;
    final shipping = calculateShippingCost();
    final tax = calculateTax();
    final total = subtotal + shipping + tax;

    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
    };
  }
}
