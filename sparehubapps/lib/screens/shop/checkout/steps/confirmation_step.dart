import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderSummary['items'].length,
            itemBuilder: (context, index) {
              final item = orderSummary['items'][index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item['productName'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Quantity: ${item['quantity']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Text(
                  '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Price Details
          _buildPriceRow('Subtotal', orderSummary['subtotal']),
          _buildPriceRow('Shipping', orderSummary['shipping']),
          _buildPriceRow('Tax', orderSummary['tax']),
          const Divider(),
          _buildPriceRow(
            'Total',
            orderSummary['total'],
            isTotal: true,
          ),
          const SizedBox(height: 24),

          // Shipping Address
          Text(
            'Shipping Address',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkoutProvider.selectedShippingAddress?.name ?? 'Not provided',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    checkoutProvider.selectedShippingAddress?.addressLine1 ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${checkoutProvider.selectedShippingAddress?.city ?? ''}, ${checkoutProvider.selectedShippingAddress?.state ?? ''} ${checkoutProvider.selectedShippingAddress?.pincode ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    checkoutProvider.selectedShippingAddress?.phone ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment Method
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                _getPaymentIcon(checkoutProvider.selectedPaymentMethod),
                size: 32,
                color: const Color(0xFFFF9800),
              ),
              title: Text(
                _getPaymentMethodName(checkoutProvider.selectedPaymentMethod),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Error Message
          if (checkoutProvider.error != null)
            CheckoutErrorBanner(
              message: checkoutProvider.error!,
              onDismiss: () => checkoutProvider.resetCheckout(),
            ),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: checkoutProvider.isLoading
                  ? null
                  : () => checkoutProvider.placeOrder(),
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: checkoutProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Place Order',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? const Color(0xFFFF9800) : Colors.black87,
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