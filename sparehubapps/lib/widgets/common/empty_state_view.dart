import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? subtitle;
  final double? iconSize;
  final Color? iconColor;

  const EmptyStateView({
    super.key,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.subtitle,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? 64,
              color: iconColor ?? Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructors for common empty states
  factory EmptyStateView.noData({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    String? subtitle,
  }) {
    return EmptyStateView(
      message: message,
      icon: Icons.inbox_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      subtitle: subtitle,
    );
  }

  factory EmptyStateView.noResults({
    String message = 'No results found',
    String? actionLabel,
    VoidCallback? onAction,
    String? subtitle,
  }) {
    return EmptyStateView(
      message: message,
      icon: Icons.search_off_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      subtitle: subtitle,
    );
  }

  factory EmptyStateView.noConnection({
    String message = 'No internet connection',
    String? actionLabel = 'Retry',
    VoidCallback? onAction,
    String? subtitle = 'Please check your connection and try again',
  }) {
    return EmptyStateView(
      message: message,
      icon: Icons.wifi_off_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      subtitle: subtitle,
    );
  }

  factory EmptyStateView.noPermission({
    String message = 'Access Denied',
    String? actionLabel,
    VoidCallback? onAction,
    String? subtitle = 'You don\'t have permission to access this feature',
  }) {
    return EmptyStateView(
      message: message,
      icon: Icons.lock_outline,
      actionLabel: actionLabel,
      onAction: onAction,
      subtitle: subtitle,
    );
  }

  factory EmptyStateView.underMaintenance({
    String message = 'Under Maintenance',
    String? actionLabel = 'Refresh',
    VoidCallback? onAction,
    String? subtitle = 'We\'ll be back soon!',
  }) {
    return EmptyStateView(
      message: message,
      icon: Icons.engineering_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      subtitle: subtitle,
    );
  }
}
