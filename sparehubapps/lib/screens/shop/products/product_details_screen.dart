import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/product.dart';
import '../../../widgets/common/common.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Slider
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Slider
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: widget.product.images.isEmpty ? 1 : widget.product.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (widget.product.images.isEmpty) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      }
                      return Image.network(
                        widget.product.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Image Indicators
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.images.length,
                              (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badges
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.product.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: widget.product.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.isApproved
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.product.isApproved ? 'Approved' : 'Pending Approval',
                          style: TextStyle(
                            color: widget.product.isApproved ? Colors.blue : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.product.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Name and Price
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.product.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.product.formattedDiscountedPrice,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.product.discount}% OFF',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.product.isOutOfStock
                          ? Colors.red[50]
                          : widget.product.isLowStock
                          ? Colors.orange[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.product.isOutOfStock
                          ? 'Out of Stock'
                          : widget.product.isLowStock
                          ? 'Low Stock'
                          : 'In Stock: ${widget.product.stockQuantity}',
                      style: TextStyle(
                        color: widget.product.isOutOfStock
                            ? Colors.red[700]
                            : widget.product.isLowStock
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Product Details
                  Text(
                    'Product Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'SKU',
                            widget.product.sku,
                            icon: Icons.qr_code_outlined,
                          ),
                          _buildInfoRow(
                            'Weight',
                            widget.product.formattedWeight,
                            icon: Icons.scale_outlined,
                          ),
                          _buildInfoRow(
                            'Dimensions',
                            widget.product.formattedDimensions,
                            icon: Icons.straighten_outlined,
                          ),
                          _buildInfoRow(
                            'Material',
                            widget.product.formattedMaterial,
                            icon: Icons.build_outlined,
                          ),
                          _buildInfoRow(
                            'Color',
                            widget.product.formattedColor,
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildInfoRow(
                            'Shipping Cost',
                            widget.product.formattedShippingCost,
                            icon: Icons.local_shipping_outlined,
                          ),
                          _buildInfoRow(
                            'Shipping Time',
                            widget.product.formattedShippingTime,
                            icon: Icons.access_time_outlined,
                          ),
                          _buildInfoRow(
                            'Origin Country',
                            widget.product.formattedOriginCountry,
                            icon: Icons.public_outlined,
                          ),
                          _buildInfoRow(
                            'Minimum Order Quantity',
                            widget.product.minOrderQuantity.toString(),
                            icon: Icons.shopping_cart_outlined,
                          ),
                          if (widget.product.maxOrderQuantity != null)
                            _buildInfoRow(
                              'Maximum Order Quantity',
                              widget.product.maxOrderQuantity.toString(),
                              icon: Icons.shopping_cart_outlined,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Technical Specification PDF
                  if (widget.product.technicalSpecificationPdf != null) ...[
                    Text(
                      'Technical Specification',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        title: const Text('Product Specification'),
                        subtitle: const Text('View detailed specifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final url = Uri.parse(widget.product.technicalSpecificationPdf!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open PDF'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Installation Guide PDF
                  if (widget.product.installationGuidePdf != null) ...[
                    Text(
                      'Installation Guide',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),
                        title: const Text('Installation Guide'),
                        subtitle: const Text('View installation instructions'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final url = Uri.parse(widget.product.installationGuidePdf!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open PDF'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final inCart = cartProvider.hasProduct(widget.product.id!);
          final cartQuantity = cartProvider.getQuantity(widget.product.id!);

          return Container(
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
            child: Row(
              children: [
                if (inCart) ...[
                  // Quantity controls
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: cartQuantity <= widget.product.minOrderQuantity
                        ? null
                        : () {
                      cartProvider.updateQuantity(
                        widget.product.id!,
                        cartQuantity - 1,
                      );
                    },
                  ),
                  Text(
                    cartQuantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: (cartQuantity >= widget.product.stockQuantity ||
                        (widget.product.maxOrderQuantity != null &&
                            cartQuantity >= widget.product.maxOrderQuantity!))
                        ? null
                        : () {
                      cartProvider.updateQuantity(
                        widget.product.id!,
                        cartQuantity + 1,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.product.isOutOfStock || !widget.product.isApproved
                        ? null
                        : () async {
                      try {
                        if (inCart) {
                          // Navigate to cart
                          Navigator.pushNamed(context, '/shop/cart');
                        } else {
                          // Add to cart with minimum order quantity
                          await cartProvider.addItem(
                            widget.product,
                            quantity: widget.product.minOrderQuantity,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Added to cart'),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/shop/cart');
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(inCart ? 'View Cart' : 'Add to Cart'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        IconData? icon,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
