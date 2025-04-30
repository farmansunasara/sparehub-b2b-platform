import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/cart.dart';
import 'cart_item_card.dart';
import 'cart_summary.dart';

class CartContent extends StatelessWidget {
  final Cart cart;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;
  final Function(String) onUndoRemove;
  final VoidCallback onCheckout;

  const CartContent({
    super.key,
    required this.cart,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onUndoRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return CartItemCard(
                key: ValueKey(item.product.id),
                item: item,
                onUpdateQuantity: (quantity) {
                  onUpdateQuantity(item.product.id!, quantity);
                },
                onRemove: () {
                  onRemoveItem(item.product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item.product.name} removed from cart',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () => onUndoRemove(item.product.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        CartSummary(
          cart: cart,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}