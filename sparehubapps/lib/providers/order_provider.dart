import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  OrderProvider(this._apiService);

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Order> get pendingOrders => _orders.where((order) =>
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.confirmed ||
      order.status == OrderStatus.processing ||
      order.status == OrderStatus.shipped).toList();

  List<Order> get completedOrders => _orders.where((order) =>
      order.status == OrderStatus.delivered ||
      order.status == OrderStatus.cancelled ||
      order.status == OrderStatus.returned).toList();

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getOrders();
      _orders = response.map((json) => Order.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _error = 'Failed to fetch orders';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getOrder(orderId);
      final order = Order.fromJson(response);
      return order;
    } catch (e) {
      debugPrint('Error fetching order $orderId: $e');
      _error = 'Failed to fetch order';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      final orderPayload = {
        'items': cart.items
            .map((item) => {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                })
            .toList(),
        'shipping_address': shippingAddress.toJson(),
        'billing_address': billingAddress?.toJson(),
        'payment': {
          'method': paymentMethod.toString().split('.').last,
          'status': 'pending',
          'amount': cart.total,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'status': 'pending',
        'subtotal': cart.total,
        'tax': cart.total * 0.18,
        'shipping_cost': cart.items.fold<double>(
          0,
          (sum, item) => sum + (item.product.shippingCost * item.quantity),
        ),
        'total': cart.total +
            (cart.total * 0.18) +
            cart.items.fold<double>(
              0,
              (sum, item) => sum + (item.product.shippingCost * item.quantity),
            ),
        'metadata': metadata,
      };

      debugPrint('Creating order with payload: $orderPayload');

      final response = await _apiService.createOrder(orderPayload);
      debugPrint('Create order response: $response');
      if (response == null) {
        debugPrint('Error: API response is null');
        throw Exception('Failed to create order: Null response');
      }
      final order = Order.fromJson(response);
      _orders.add(order);
      _currentOrder = order;
      notifyListeners();
      return order;
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

  Future<Order?> createOrderFromPayload(Map<String, dynamic> payload) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.createOrder(payload);
      debugPrint('Create order from payload response: $response'); // Log raw response
      Order order;
      if (response == null || response.isEmpty) {
        debugPrint('Warning: API response is null or empty, creating minimal Order');
        // Create a minimal Order object from payload
        order = Order(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
          userId: payload['user'].toString(),
          shopName: payload['shop_name'] ?? 'SpareHub Shop',
          items: (payload['items'] as List<dynamic>)
              .map((item) => CartItem.fromJson({
                    'product': {
                      'id': item['product_id'],
                      'price': item['price'],
                      'name': 'Unknown Product', // Fallback name
                    },
                    'quantity': item['quantity'],
                  }))
              .toList(),
          shippingAddress: OrderAddress.fromJson(payload['shipping_address']),
          billingAddress: payload['billing_address'] != null
              ? OrderAddress.fromJson(payload['billing_address'])
              : null,
          payment: OrderPayment.fromJson({
            ...payload['payment'],
            'id': 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary payment ID
          }),
          status: OrderStatus.pending,
          subtotal: payload['subtotal']?.toDouble() ?? 0.0,
          tax: payload['tax']?.toDouble() ?? 0.0,
          shippingCost: payload['shipping_cost']?.toDouble() ?? 0.0,
          total: payload['total']?.toDouble() ?? 0.0,
          createdAt: DateTime.now(),
          statusUpdates: [],
          metadata: payload['metadata'],
        );
      } else if (response is! Map<String, dynamic>) {
        debugPrint('Error: Unexpected response type: ${response.runtimeType}');
        throw Exception('Failed to create order: Invalid response format');
      } else {
        order = Order.fromJson(response);
      }
      _orders.add(order);
      _currentOrder = order;
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('Error creating order from payload: $e');
      _error = 'Failed to create order: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? comment}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.updateOrderStatus(
        orderId,
        status.toString().split('.').last,
        comment: comment,
      );
      final updatedOrder = Order.fromJson(response);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating order status: $e');
      _error = 'Failed to update order status';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.cancelled,
        comment: reason ?? 'Order cancelled by user',
      );
      return true;
    } catch (e) {
      debugPrint('Error cancelling order $orderId: $e');
      return false;
    }
  }

  Future<bool> returnOrder(String orderId, {String? reason}) async {
    try {
      await updateOrderStatus(
        orderId,
        OrderStatus.returned,
        comment: reason ?? 'Order returned by user',
      );
      return true;
    } catch (e) {
      debugPrint('Error returning order $orderId: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }
}