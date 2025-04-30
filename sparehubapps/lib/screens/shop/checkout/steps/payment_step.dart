import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../models/order.dart';
import '../../../../providers/checkout_provider.dart';
import '../checkout_screen.dart';

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            if (provider.error != null)
              CheckoutErrorBanner(
                message: provider.error!,
                onDismiss: () => provider.resetCheckout(),
              ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Payment Methods
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Select Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _PaymentMethodCard(
                          method: PaymentMethod.cod,
                          title: 'Cash on Delivery',
                          subtitle: 'Pay when you receive your order',
                          icon: Icons.payments_outlined,
                          isSelected:
                              provider.selectedPaymentMethod == PaymentMethod.cod,
                          onSelect: () =>
                              provider.selectPaymentMethod(PaymentMethod.cod),
                        ),
                        _PaymentMethodCard(
                          method: PaymentMethod.card,
                          title: 'Credit/Debit Card',
                          subtitle: 'Pay securely with your card',
                          icon: Icons.credit_card_outlined,
                          isSelected:
                              provider.selectedPaymentMethod == PaymentMethod.card,
                          onSelect: () =>
                              provider.selectPaymentMethod(PaymentMethod.card),
                        ),
                        _PaymentMethodCard(
                          method: PaymentMethod.upi,
                          title: 'UPI',
                          subtitle: 'Pay using any UPI app',
                          icon: Icons.account_balance_outlined,
                          isSelected:
                              provider.selectedPaymentMethod == PaymentMethod.upi,
                          onSelect: () =>
                              provider.selectPaymentMethod(PaymentMethod.upi),
                        ),
                        _PaymentMethodCard(
                          method: PaymentMethod.netBanking,
                          title: 'Net Banking',
                          subtitle: 'Pay using your bank account',
                          icon: Icons.account_balance_wallet_outlined,
                          isSelected: provider.selectedPaymentMethod ==
                              PaymentMethod.netBanking,
                          onSelect: () =>
                              provider.selectPaymentMethod(PaymentMethod.netBanking),
                        ),
                      ]),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Divider(),
                    ),
                  ),

                  // Order Summary
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Order Summary',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                'Subtotal',
                                provider.formattedSubtotal,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Shipping',
                                provider.formattedShipping,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Tax',
                                provider.formattedTax,
                              ),
                              const Divider(height: 24),
                              _buildSummaryRow(
                                'Total',
                                provider.formattedTotal,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CheckoutButton(
                label: 'Continue to Confirmation',
                onPressed: () => provider.nextStep(),
                enabled: provider.canProceedToConfirmation,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
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
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? const Color(0xFFFF9800) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentMethodCard({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onSelect(),
                activeColor: const Color(0xFFFF9800),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 28,
                color: isSelected ? const Color(0xFFFF9800) : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFFF9800) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}