import 'package:flutter/material.dart';
import '../../../widgets/common/common.dart';

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
}

enum NotificationType {
  order,
  product,
  stock,
  payment,
  system,
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API call
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.product:
        return Icons.inventory_2_outlined;
      case NotificationType.stock:
        return Icons.warning_amber_outlined;
      case NotificationType.payment:
        return Icons.payment_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.product:
        return Colors.purple;
      case NotificationType.stock:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // TODO: Mark all as read
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _notifications.isEmpty
            ? const EmptyStateView(
          message: 'No notifications',
          icon: Icons.notifications_outlined,
        )
            : RefreshIndicator(
          onRefresh: _loadNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    if (notification.actionRoute != null) {
                      Navigator.pushNamed(
                        context,
                        notification.actionRoute!,
                        arguments: notification.actionArgs,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: _getNotificationColor(notification.type),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatTimestamp(notification.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (notification.actionRoute != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to view details',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
