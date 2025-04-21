import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum NotificationType {
  order,
  product,
  stock,
  payment,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionArgs;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.actionArgs,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionArgs,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionArgs: actionArgs ?? this.actionArgs,
    );
  }
}

class NotificationsProvider with ChangeNotifier {
  final ApiService apiService;
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationsProvider({required this.apiService});

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get orderNotifications =>
      _notifications.where((n) => n.type == NotificationType.order).toList();

  List<NotificationItem> get stockNotifications =>
      _notifications.where((n) => n.type == NotificationType.stock).toList();

  List<NotificationItem> get paymentNotifications =>
      _notifications.where((n) => n.type == NotificationType.payment).toList();

  Future<void> fetchNotifications() async {
    _setLoading(true);
    try {
      // TODO: Implement API call using apiService
      // Example: final response = await apiService.getNotifications();
      await Future.delayed(const Duration(seconds: 1));
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'New Order Received',
          message: 'You have received a new order #123 from AutoParts Plus',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: NotificationType.order,
          actionRoute: '/manufacturer/orders/details',
          actionArgs: {'orderId': '123'},
        ),
        NotificationItem(
          id: '2',
          title: 'Low Stock Alert',
          message: 'Brake Pad Set is running low on stock (5 units remaining)',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.stock,
          actionRoute: '/manufacturer/products/details',
          actionArgs: {'productId': '456'},
        ),
        NotificationItem(
          id: '3',
          title: 'Payment Received',
          message: 'Payment of ₹25,000 received for order #120',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.payment,
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // TODO: Implement API call using apiService
      // Example: await apiService.markNotificationAsRead(notificationId);
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // TODO: Implement API call using apiService
      // Example: await apiService.markAllNotificationsAsRead();
      await Future.delayed(const Duration(milliseconds: 500));
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // TODO: Implement API call using apiService
      // Example: await apiService.deleteNotification(notificationId);
      await Future.delayed(const Duration(milliseconds: 500));
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      // TODO: Implement API call using apiService
      // Example: await apiService.clearAllNotifications();
      await Future.delayed(const Duration(milliseconds: 500));
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Notification Generation Methods
  void generateOrderNotification(Order order) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Order Received',
      message:
      'You have received a new order #${order.id} from ${order.shopName}',
      timestamp: DateTime.now(),
      type: NotificationType.order,
      actionRoute: '/manufacturer/orders/details',
      actionArgs: {'orderId': order.id},
    );
    _addNotification(notification);
  }

  void generateLowStockNotification(Product product) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Low Stock Alert',
      message:
      '${product.name} is running low on stock (${product.stockQuantity} units remaining)',
      timestamp: DateTime.now(),
      type: NotificationType.stock,
      actionRoute: '/manufacturer/products/details',
      actionArgs: {'productId': product.id},
    );
    _addNotification(notification);
  }

  void generatePaymentNotification(Order order) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Payment Received',
      message:
      'Payment of ₹${order.total.toStringAsFixed(2)} received for order #${order.id}',
      timestamp: DateTime.now(),
      type: NotificationType.payment,
      actionRoute: '/manufacturer/orders/details',
      actionArgs: {'orderId': order.id},
    );
    _addNotification(notification);
  }

  void _addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}