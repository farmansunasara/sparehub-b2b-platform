import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Added missing import
import '../../../providers/cart_provider.dart';
import 'widgets/cart_content.dart';
import 'widgets/cart_error.dart';
import 'widgets/empty_cart.dart';
import '../home_screen.dart'; // Import to access ShopHomeScreenState

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Clear Cart Button
        Consumer<CartProvider>(
          builder: (context, provider, child) {
            if (provider.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Clear Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to clear your cart?',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              provider.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cart cleared',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: theme.elevatedButtonTheme.style?.copyWith(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_shopping_cart, color: Color(0xFFFF9800)),
                  label: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFFFF9800),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Cart Content
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return CartError(
                  message: provider.error!,
                  onRetry: () => provider.refreshCart(),
                );
              }

              if (provider.isEmpty) {
                return EmptyCart(
                  onContinueShopping: () {
                    // Switch to Products tab
                    final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
                    if (homeScreenState != null) {
                      homeScreenState.setSelectedIndex(1);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                );
              }

              return CartContent(
                cart: provider.cart,
                onUpdateQuantity: (productId, quantity) {
                  provider.updateQuantity(productId, quantity);
                },
                onRemoveItem: (productId) {
                  provider.removeItem(productId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Item removed from cart',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          final product = provider.cart.items
                              .firstWhere((item) => item.product.id == productId)
                              .product;
                          provider.addItem(product);
                        },
                      ),
                    ),
                  );
                },
                onUndoRemove: (productId) {
                  final product = provider.cart.items
                      .firstWhere((item) => item.product.id == productId)
                      .product;
                  provider.addItem(product);
                },
                onCheckout: () {
                  Navigator.pushNamed(context, '/shop/checkout');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}