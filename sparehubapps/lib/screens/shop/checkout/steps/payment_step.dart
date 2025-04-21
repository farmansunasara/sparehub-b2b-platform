import 'package:flutter/material.dart';
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
                  const SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Select Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Card(
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
                    color: Colors.black.withOpacity(0.05),
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
    final style = isTotal
        ? const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
        : const TextStyle(fontSize: 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
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
      child: InkWell(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey[300]!,
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
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 28,
                color: isSelected ? theme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.primaryColor : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
