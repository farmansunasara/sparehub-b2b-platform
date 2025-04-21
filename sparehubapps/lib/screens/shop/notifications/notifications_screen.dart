import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notifications_provider.dart';
import '../../../widgets/common/common.dart';

class ShopNotificationsScreen extends StatefulWidget {
  const ShopNotificationsScreen({super.key});

  @override
  State<ShopNotificationsScreen> createState() => _ShopNotificationsScreenState();
}

class _ShopNotificationsScreenState extends State<ShopNotificationsScreen> {
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await Provider.of<NotificationsProvider>(context, listen: false).markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking notifications as read: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadNotifications,
            ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Consumer<NotificationsProvider>(
          builder: (context, provider, child) {
            final notifications = provider.notifications;

            if (notifications.isEmpty) {
              return const Center(
                child: Text('No notifications'),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        notification.type == NotificationType.order
                            ? Icons.shopping_bag_outlined
                            : Icons.notifications_outlined,
                        color: notification.isRead
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                          notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.message),
                          const SizedBox(height: 4),
                          Text(
                            notification.timestamp.toLocal().toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () async {
                        if (!notification.isRead) {
                          await provider.markAsRead(notification.id);
                        }
                        if (notification.type == NotificationType.order && mounted) {
                          Navigator.pushNamed(
                            context,
                            '/shop/orders/details',
                            arguments: notification.actionArgs != null ? notification.actionArgs!['orderId'] : null,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
