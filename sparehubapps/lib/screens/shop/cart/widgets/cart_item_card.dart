import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/cart.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100, // Increased size
                height: 100,
                child: item.product.images.isNotEmpty
                    ? Image.network(
                        item.product.images.first.isNotEmpty
                            ? item.product.images.first
                            : 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.formattedPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFFF9800),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.product.discount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.product.formattedDiscountedPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Color(0xFFFF9800), size: 20),
                      onPressed: () {
                        if (item.quantity > 1) {
                          onUpdateQuantity(item.quantity - 1);
                        }
                      },
                    ),
                    Text(
                      item.quantity.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFFFF9800), size: 20),
                      onPressed: () {
                        if (item.quantity < item.product.stockQuantity) {
                          onUpdateQuantity(item.quantity + 1);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Only ${item.product.stockQuantity} items available',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.red[700],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF9800), size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() => Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: Colors.grey[400],
        ),
      );
}