import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/checkout_provider.dart';
import '../../../../models/order.dart';
import '../checkout_screen.dart';

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final checkoutProvider = context.watch<CheckoutProvider>();
    final orderSummary = cartProvider.getOrderSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: Text(
                  '₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const Divider(),

          // Price Details
          _buildPriceRow('Subtotal', orderSummary['subtotal']!),
          _buildPriceRow('Shipping', orderSummary['shipping']!),
          _buildPriceRow('Tax', orderSummary['tax']!),
          const Divider(),
          _buildPriceRow(
            'Total',
            orderSummary['total']!,
            isTotal: true,
          ),
          const SizedBox(height: 24),

          // Shipping Address
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(checkoutProvider.selectedShippingAddress?.name ?? ''),
                  Text(checkoutProvider.selectedShippingAddress?.addressLine1 ?? ''),
                  Text(
                    '${checkoutProvider.selectedShippingAddress?.city ?? ''}, ${checkoutProvider.selectedShippingAddress?.state ?? ''} ${checkoutProvider.selectedShippingAddress?.pincode ?? ''}',
                  ),
                  Text(checkoutProvider.selectedShippingAddress?.phone ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment Method
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                _getPaymentIcon(checkoutProvider.selectedPaymentMethod),
                size: 32,
              ),
              title: Text(
                _getPaymentMethodName(checkoutProvider.selectedPaymentMethod),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Place Order Button
          if (checkoutProvider.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checkoutProvider.error!,
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: checkoutProvider.isLoading
                  ? null
                  : () => checkoutProvider.placeOrder(),
              child: checkoutProvider.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.upi:
        return Icons.account_balance;
      case PaymentMethod.netBanking:
        return Icons.account_balance;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.cod:
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Card Payment';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      default:
        return 'Not Selected';
    }
  }
}
