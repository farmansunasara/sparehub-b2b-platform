import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart.dart';

class CartProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  Cart _cart = Cart(items: []);
  bool _isLoading = false;
  String? _error;
  static const String _cartKey = 'cart_data';

  CartProvider(this._prefs) {
    _loadCart();
  }

  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cart.items.isEmpty;
  List<CartItem> get items => _cart.items;
  double get total => _cart.total;

  Future<void> _loadCart() async {
    try {
      _setLoading(true);
      _error = null;

      final cartJson = _prefs.getString(_cartKey);
      if (cartJson != null) {
        final cartData = json.decode(cartJson) as Map<String, dynamic>;
        final itemsData = cartData['items'] as List<dynamic>? ?? [];
        final cartItems = itemsData.map((item) {
          final itemData = item as Map<String, dynamic>;
          final productData = itemData['product'] as Map<String, dynamic>;
          return CartItem(
            product: Product.fromJson({
              ...productData,
              'id': productData['id'].toString(), // Ensure ID is String
            }),
            quantity: itemData['quantity'] as int,
          );
        }).toList();
        _cart = Cart(items: cartItems);
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      _error = 'Failed to load cart';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCart() async {
    await _loadCart();
  }

  bool hasProduct(String? productId) {
    if (productId == null) return false;
    return _cart.items.any((item) => item.product.id == productId);
  }

  int getQuantity(String? productId) {
    if (productId == null) return 0;
    final item = _cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(
          id: '',
          name: '',
          description: '',
          sku: '',
          categoryId: 0,
          subcategoryId: 0,
          manufacturerId: 0,
          price: 0.0,
          stockQuantity: 0,
          weight: 0.0,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  Map<String, dynamic> getOrderSummary() {
    final subtotal = _cart.total;
    const shipping = 50.0; // Placeholder: Adjust based on actual logic
    const taxRate = 0.18; // 18% GST, adjust as needed
    final tax = subtotal * taxRate;
    final total = subtotal + shipping + tax;

    return {
      'items': _cart.items.map((item) => {
            'productName': item.product.name,
            'quantity': item.quantity,
            'price': item.product.price,
          }).toList(),
      'itemCount': _cart.items.length,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
    };
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    try {
      _setLoading(true);
      _error = null;

      if (product.id == null) {
        throw Exception('Product ID is null');
      }

      final existingItemIndex = _cart.items.indexWhere((item) => item.product.id == product.id);
      if (existingItemIndex >= 0) {
        _cart.items[existingItemIndex] = _cart.items[existingItemIndex].copyWith(
          quantity: _cart.items[existingItemIndex].quantity + quantity,
        );
      } else {
        _cart.items.add(CartItem(product: product, quantity: quantity));
      }

      await _saveCart();
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
      _error = 'Failed to add item to cart: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      _setLoading(true);
      _error = null;

      final itemIndex = _cart.items.indexWhere((item) => item.product.id == productId);
      if (itemIndex >= 0) {
        if (quantity <= 0) {
          _cart.items.removeAt(itemIndex);
        } else {
          _cart.items[itemIndex] = _cart.items[itemIndex].copyWith(quantity: quantity);
        }
        await _saveCart();
      }
    } catch (e) {
      debugPrint('Error updating cart quantity: $e');
      _error = 'Failed to update cart';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      _setLoading(true);
      _error = null;

      _cart.items.removeWhere((item) => item.product.id == productId);
      await _saveCart();
    } catch (e) {
      debugPrint('Error removing item from cart: $e');
      _error = 'Failed to remove item from cart';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clear() async {
    try {
      _setLoading(true);
      _error = null;

      _cart = Cart(items: []);
      await _saveCart();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      _error = 'Failed to clear cart';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveCart() async {
    try {
      final cartJson = json.encode({
        'items': _cart.items.map((item) => {
          'product': {
            'id': item.product.id,
            'name': item.product.name,
            'price': item.product.price,
            'discount': item.product.discount,
            'stockQuantity': item.product.stockQuantity,
            'images': item.product.images,
            'categoryId': item.product.categoryId,
            'brandId': item.product.brandId,
            'isLowStock': item.product.isLowStock,
            'isOutOfStock': item.product.isOutOfStock,
            'createdAt': item.product.createdAt?.toIso8601String(),
            'updatedAt': item.product.updatedAt?.toIso8601String(),
            'minOrderQuantity': item.product.minOrderQuantity,
            'maxOrderQuantity': item.product.maxOrderQuantity,
            'isApproved': item.product.isApproved,
            'isActive': item.product.isActive,
            'isFeatured': item.product.isFeatured,
            'sku': item.product.sku,
            'description': item.product.description,
            'technicalSpecificationPdf': item.product.technicalSpecificationPdf,
            'installationGuidePdf': item.product.installationGuidePdf,
            'weight': item.product.weight,
            'dimensions': item.product.dimensions,
            'material': item.product.material,
            'color': item.product.color,
            'shippingCost': item.product.shippingCost,
            'shippingTime': item.product.shippingTime,
            'originCountry': item.product.originCountry,
            'subcategoryId': item.product.subcategoryId,
            'manufacturerId': item.product.manufacturerId,
          },
          'quantity': item.quantity,
        }).toList(),
      });
      await _prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
      _error = 'Failed to save cart';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}