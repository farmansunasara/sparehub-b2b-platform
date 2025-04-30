import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../widgets/common/common.dart';
import '../../../utils/string_extensions.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = false;

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      await provider.updateOrderStatus(widget.order.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order status updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _updateOrderStatus(newStatus),
            ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.id}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Status',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOrderStatusStepper(widget.order.status),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shop Information
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shop Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Shop Name', widget.order.shopName),
                        const SizedBox(height: 8),
                        _buildInfoRow('Order Date', _formatDate(widget.order.createdAt)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Items
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Items',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.order.items.length,
                          separatorBuilder: (context, index) => const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final item = widget.order.items[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 24),
                        _buildInfoRow('Subtotal', '₹${widget.order.subtotal.toStringAsFixed(2)}'),
                        _buildInfoRow('Tax', '₹${widget.order.tax.toStringAsFixed(2)}'),
                        _buildInfoRow('Shipping', '₹${widget.order.shippingCost.toStringAsFixed(2)}'),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Total',
                          '₹${widget.order.total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Information
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Payment Method', widget.order.paymentMethodText.capitalize()),
                        const SizedBox(height: 8),
                        _buildInfoRow('Payment Status', widget.order.paymentStatusText.capitalize()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shipping Address
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: theme.cardTheme.elevation,
                  shape: theme.cardTheme.shape,
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Address',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.order.shippingAddress.formattedAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (widget.order.canCancel || widget.order.canReturn)
                Row(
                  children: [
                    if (widget.order.canCancel)
                      Expanded(
                        child: Semantics(
                          label: 'Update order status',
                          child: ElevatedButton(
                            onPressed: () => _updateOrderStatus(_getNextStatus(widget.order.status)),
                            style: theme.elevatedButtonTheme.style?.copyWith(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            child: Text(
                              _getNextStatusButtonText(widget.order.status),
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                      ),
                    if (widget.order.canCancel) const SizedBox(width: 16),
                    if (widget.order.canCancel || widget.order.canReturn)
                      Expanded(
                        child: Semantics(
                          label: widget.order.canReturn ? 'Return order' : 'Cancel order',
                          child: OutlinedButton(
                            onPressed: () => _updateOrderStatus(
                              widget.order.canReturn ? OrderStatus.returned : OrderStatus.cancelled,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.order.canReturn ? 'Return Order' : 'Cancel Order',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusStepper(OrderStatus currentStatus) {
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    return Row(
      children: allStatuses.map((status) {
        final isCompleted = status.index <= currentStatus.index;
        final isLast = status == allStatuses.last;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isCompleted
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      child: Icon(
                        _getStatusIcon(status),
                        size: 16,
                        color: isCompleted ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatOrderStatus(status),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? const Color(0xFFFF9800) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.sync;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  OrderStatus _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.processing;
      case OrderStatus.processing:
        return OrderStatus.shipped;
      case OrderStatus.shipped:
        return OrderStatus.delivered;
      default:
        return currentStatus;
    }
  }

  String _getNextStatusButtonText(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return 'Confirm Order';
      case OrderStatus.confirmed:
        return 'Start Processing';
      case OrderStatus.processing:
        return 'Mark as Shipped';
      case OrderStatus.shipped:
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  String _formatOrderStatus(OrderStatus status) {
    return status.toString().split('.').last.capitalize();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}