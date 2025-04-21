import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class OrderProvider with ChangeNotifier {
  static const String _ordersKey = 'user_orders';

  final ApiService _apiService;
  final SharedPreferences _prefs;
  final AuthProvider _authProvider;

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider(this._apiService, this._prefs, this._authProvider) {
    _loadOrders();
  }

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Order> get pendingOrders => _orders.where((order) =>
  order.status == OrderStatus.pending ||
      order.status == OrderStatus.confirmed
  ).toList();

  List<Order> get completedOrders => _orders.where((order) =>
  order.status == OrderStatus.delivered
  ).toList();

  // Load orders from storage
  Future<void> _loadOrders() async {
    try {
      final ordersJson = _prefs.getString(_ordersKey);
      if (ordersJson != null) {
        final List<dynamic> ordersList = json.decode(ordersJson);
        _orders = ordersList.map((json) => Order.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _error = 'Failed to load orders';
      notifyListeners();
    }
  }

  // Save orders to storage
  Future<void> _saveOrders() async {
    try {
      final ordersJson = json.encode(_orders.map((order) => order.toJson()).toList());
      await _prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving orders: $e');
      _error = 'Failed to save orders';
      notifyListeners();
    }
  }

  // Create new order from cart
  Future<Order?> createOrder({
    required Cart cart,
    required Address shippingAddress,
    Address? billingAddress,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Calculate order totals
      final subtotal = cart.total;
      final tax = subtotal * 0.18; // 18% GST
      final shippingCost = cart.items.fold<double>(
        0,
            (sum, item) => sum + (item.product.shippingCost * item.quantity),
      );
      final total = subtotal + tax + shippingCost;

      // Create payment record
      final payment = OrderPayment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: paymentMethod,
        status: PaymentStatus.pending,
        amount: total,
        timestamp: DateTime.now(),
      );

      // Create order
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _authProvider.currentUser?.id.toString() ?? 'unknown_user',
        shopName: _authProvider.currentUser?.name ?? 'Unknown Shop',
        items: cart.items,
        shippingAddress: shippingAddress.toOrderAddress(),
        billingAddress: billingAddress?.toOrderAddress(),
        payment: payment,
        status: OrderStatus.pending,
        subtotal: subtotal,
        tax: tax,
        shippingCost: shippingCost,
        total: total,
        createdAt: DateTime.now(),
        statusUpdates: [
          OrderStatusUpdate(
            status: OrderStatus.pending,
            comment: 'Order placed',
            timestamp: DateTime.now(),
          ),
        ],
        metadata: metadata,
      );

      // Save to API
      final response = await _apiService.createOrder(order.toJson());
      final createdOrder = Order.fromJson(response);
      _orders.add(createdOrder);
      _currentOrder = createdOrder;
      await _saveOrders();
      notifyListeners();
      return createdOrder;
    } on ApiException catch (e) {
      debugPrint('API Error creating order: ${e.message}');
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error creating order: $e');
      _error = 'Failed to create order';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {String? comment}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        throw Exception('Order not found');
      }

      // Update in API
      final response = await _apiService.updateOrderStatus(
          orderId,
          newStatus.toString().split('.').last,
          comment: comment
      );
      final serverUpdatedOrder = Order.fromJson(response);
      _orders[orderIndex] = serverUpdatedOrder;
      if (_currentOrder?.id == orderId) {
        _currentOrder = serverUpdatedOrder;
      }
      await _saveOrders();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('API Error updating order status: ${e.message}');
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      _error = 'Failed to update order status';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      comment: reason,
    );
  }

  // Return order
  Future<bool> returnOrder(String orderId, {String? reason}) async {
    return updateOrderStatus(
      orderId,
      OrderStatus.returned,
      comment: reason,
    );
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.getOrder(orderId);
      return Order.fromJson(response);
    } on ApiException catch (e) {
      debugPrint('API Error getting order: ${e.message}');
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error getting order: $e');
      _error = 'Failed to get order';
      notifyListeners();
      return null;
    }
  }

  // Get cached order by ID
  Order? getCachedOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  // Refresh orders from API
  Future<void> refreshOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ordersList = await _apiService.getOrders();
      _orders = ordersList.map((json) => Order.fromJson(json)).toList();
      await _saveOrders();
    } on ApiException catch (e) {
      debugPrint('API Error refreshing orders: ${e.message}');
      _error = e.message;
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
      _error = 'Failed to refresh orders';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // Filter orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get orders within date range
  List<Order> getOrdersByDateRange(DateTime start, DateTime end) {
    return _orders.where((order) {
      return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
    }).toList();
  }

  // Search orders
  List<Order> searchOrders(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.id.toLowerCase().contains(lowercaseQuery) ||
          order.shippingAddress.name.toLowerCase().contains(lowercaseQuery) ||
          order.items.any((item) =>
              item.product.name.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}
