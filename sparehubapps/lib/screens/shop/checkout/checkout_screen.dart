import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/order.dart';
import '../../../providers/checkout_provider.dart';
import 'steps/address_step.dart';
import 'steps/payment_step.dart';
import 'steps/confirmation_step.dart';
import 'steps/complete_step.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        final checkoutProvider = context.read<CheckoutProvider>();
        if (checkoutProvider.currentStep != CheckoutStep.address) {
          checkoutProvider.previousStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Checkout',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1976D2),
          elevation: 4,
          leading: Builder(
            builder: (context) {
              final checkoutProvider = context.watch<CheckoutProvider>();
              return IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (checkoutProvider.currentStep == CheckoutStep.address) {
                    Navigator.pop(context);
                  } else {
                    checkoutProvider.previousStep();
                  }
                },
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Stepper indicator
            Consumer<CheckoutProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStepIndicator(
                        context,
                        'Address',
                        CheckoutStep.address,
                        provider.currentStep,
                      ),
                      _buildStepDivider(
                        context,
                        provider.currentStep.index >= CheckoutStep.payment.index,
                      ),
                      _buildStepIndicator(
                        context,
                        'Payment',
                        CheckoutStep.payment,
                        provider.currentStep,
                      ),
                      _buildStepDivider(
                        context,
                        provider.currentStep.index >= CheckoutStep.confirmation.index,
                      ),
                      _buildStepIndicator(
                        context,
                        'Confirm',
                        CheckoutStep.confirmation,
                        provider.currentStep,
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 1),

            // Current step content
            Expanded(
              child: Consumer<CheckoutProvider>(
                builder: (context, provider, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentStep(provider.currentStep),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    String label,
    CheckoutStep step,
    CheckoutStep currentStep,
  ) {
    final isCompleted = currentStep.index > step.index;
    final isActive = currentStep == step;
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFFFF9800)
                  : isActive
                      ? const Color(0xFFFF9800).withOpacity(0.1)
                      : Colors.grey[200],
              border: Border.all(
                color: isCompleted || isActive
                    ? const Color(0xFFFF9800)
                    : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      (step.index + 1).toString(),
                      style: GoogleFonts.poppins(
                        color: isActive ? const Color(0xFFFF9800) : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? const Color(0xFFFF9800) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context, bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFFFF9800) : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStep(CheckoutStep step) {
    switch (step) {
      case CheckoutStep.address:
        return const AddressStep();
      case CheckoutStep.payment:
        return const PaymentStep();
      case CheckoutStep.confirmation:
        return const ConfirmationStep();
      case CheckoutStep.complete:
        return const CompleteStep();
    }
  }
}

class CheckoutErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const CheckoutErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red[700],
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}

class CheckoutButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const CheckoutButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}