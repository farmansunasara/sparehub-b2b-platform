import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import 'widgets/cart_content.dart';
import 'widgets/cart_error.dart';
import 'widgets/empty_cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text('Are you sure you want to clear your cart?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            provider.clear();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cart cleared'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.remove_shopping_cart),
                label: const Text('Clear'),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
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
              onContinueShopping: () => Navigator.pop(context),
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
                  content: const Text('Item removed from cart'),
                  action: SnackBarAction(
                    label: 'Undo',
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
    );
  }
}
