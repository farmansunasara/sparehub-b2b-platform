import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;
  bool _hasMoreOrders = true;
  int _currentPage = 1;
  static const int _pageSize = 5;

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreOrders => _hasMoreOrders;

  List<Order> get pendingOrders => _orders.where((order) {
    return [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped
    ].contains(order.status);
  }).toList();

  List<Order> get completedOrders => _orders.where((order) {
    return [
      OrderStatus.delivered,
      OrderStatus.cancelled,
      OrderStatus.returned
    ].contains(order.status);
  }).toList();

  Future<void> refreshOrders({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _orders = [];
      _hasMoreOrders = true;
    }
    _setLoading(true);
    try {
      final response = await _apiService.getShopOrders(limit: _pageSize);
      final newOrders = response.map((json) => Order.fromJson(json)).toList();
      if (newOrders.length < _pageSize) {
        _hasMoreOrders = false;
      }
      _orders = reset ? newOrders : [..._orders, ...newOrders];
      _error = null;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Order?> createOrder({
    required Cart cart,
    required OrderAddress shippingAddress,
    OrderAddress? billingAddress,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final orderData = {
        'items': cart.items.map((item) => {
          'product': item.product.id,
          'quantity': item.quantity,
        }).toList(),
        'shipping_address': {
          'name': shippingAddress.name,
          'phone': shippingAddress.phone,
          'address': shippingAddress.formattedAddress,
        },
        if (billingAddress != null)
          'billing_address': {
            'name': billingAddress.name,
            'phone': billingAddress.phone,
            'address': billingAddress.formattedAddress,
          },
        'payment_method': paymentMethod.toString().split('.').last,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _apiService.createOrder(orderData);
      final order = Order.fromJson(response);
      _currentOrder = order;
      _orders = [order, ..._orders];
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      _setLoading(true);
      _error = null;

      final response = await _apiService.getOrder(orderId);
      final order = Order.fromJson(response);
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      _setLoading(true);
      _error = null;

      await _apiService.updateOrderStatus(
        orderId,
        OrderStatus.cancelled.toString().split('.').last,
        comment: reason,
      );
      await refreshOrders(reset: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> returnOrder(String orderId, {required String reason}) async {
    try {
      _setLoading(true);
      _error = null;

      await _apiService.updateOrderStatus(
        orderId,
        OrderStatus.returned.toString().split('.').last,
        comment: reason,
      );
      await refreshOrders(reset: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (!_disposed) {
      _isLoading = value;
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}