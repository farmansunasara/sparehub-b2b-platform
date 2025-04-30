import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/common/common.dart';
import '../../../models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _quantity = 1;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.minOrderQuantity;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  const Color(0xFF1976D2),
                  const Color(0xFFFF9800),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                widget.product.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.items.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.pushNamed(context, '/shop/cart');
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: const Color(0xFFFF9800),
                        child: Text(
                          itemCount.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Image Carousel
          SliverToBoxAdapter(
            child: Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: widget.product.images.length > 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items: widget.product.images.isEmpty
                      ? [
                          Container(
                            color: theme.inputDecorationTheme.fillColor,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                        ]
                      : widget.product.images.map((image) {
                          return Hero(
                            tag: 'product-${widget.product.id}',
                            child: CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.inputDecorationTheme.fillColor,
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        }).toList(),
                ),
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
                                ? theme.primaryColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badges
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusBadge(
                          label: widget.product.isActive ? 'Active' : 'Inactive',
                          color: widget.product.isActive ? Colors.green : Colors.grey,
                        ),
                        _buildStatusBadge(
                          label: widget.product.isApproved ? 'Approved' : 'Pending Approval',
                          color: widget.product.isApproved ? Colors.blue : Colors.orange,
                        ),
                        if (widget.product.isFeatured)
                          _buildStatusBadge(
                            label: 'Featured',
                            color: Colors.purple,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product Name and Price
                    Text(
                      widget.product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          widget.product.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: const Color(0xFFFF9800),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.product.discount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.product.formattedDiscountedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.product.discount}% OFF',
                              style: GoogleFonts.poppins(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock Status
                    _buildStatusBadge(
                      label: widget.product.isOutOfStock
                          ? 'Out of Stock'
                          : widget.product.isLowStock
                              ? 'Low Stock'
                              : 'In Stock: ${widget.product.stockQuantity}',
                      color: widget.product.isOutOfStock
                          ? Colors.red
                          : widget.product.isLowStock
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector
                    if (!widget.product.isOutOfStock && widget.product.isApproved)
                      Row(
                        children: [
                          Text(
                            'Quantity:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity <= widget.product.minOrderQuantity
                                ? null
                                : () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  },
                          ),
                          Text(
                            _quantity.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: (widget.product.isOutOfStock ||
                                    _quantity >= widget.product.stockQuantity ||
                                    (widget.product.maxOrderQuantity != null &&
                                        _quantity >= widget.product.maxOrderQuantity!))
                                ? null
                                : () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  },
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description.isEmpty
                          ? 'No description available'
                          : widget.product.description,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Product Details
                    Text(
                      'Product Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: theme.cardTheme.elevation,
                      shape: theme.cardTheme.shape,
                      color: theme.cardTheme.color,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('SKU', widget.product.sku, Icons.qr_code_outlined),
                            _buildInfoRow('Weight', widget.product.formattedWeight, Icons.scale_outlined),
                            _buildInfoRow('Dimensions', widget.product.formattedDimensions, Icons.straighten_outlined),
                            _buildInfoRow('Material', widget.product.formattedMaterial, Icons.build_outlined),
                            _buildInfoRow('Color', widget.product.formattedColor, Icons.color_lens_outlined),
                            _buildInfoRow('Shipping Cost', widget.product.formattedShippingCost, Icons.local_shipping_outlined),
                            _buildInfoRow('Shipping Time', widget.product.formattedShippingTime, Icons.access_time_outlined),
                            _buildInfoRow('Origin Country', widget.product.formattedOriginCountry, Icons.public_outlined),
                            _buildInfoRow('Min Order Qty', widget.product.minOrderQuantity.toString(), Icons.shopping_cart_outlined),
                            if (widget.product.maxOrderQuantity != null)
                              _buildInfoRow('Max Order Qty', widget.product.maxOrderQuantity.toString(), Icons.shopping_cart_outlined),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Technical Specification PDF
                    if (widget.product.technicalSpecificationPdf != null) ...[
                      Text(
                        'Technical Specification',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: theme.cardTheme.elevation,
                        shape: theme.cardTheme.shape,
                        color: theme.cardTheme.color,
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text('Product Specification', style: GoogleFonts.poppins()),
                          subtitle: Text('View detailed specifications', style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _launchUrl(widget.product.technicalSpecificationPdf),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Installation Guide PDF
                    if (widget.product.installationGuidePdf != null) ...[
                      Text(
                        'Installation Guide',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: theme.cardTheme.elevation,
                        shape: theme.cardTheme.shape,
                        color: theme.cardTheme.color,
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text('Installation Guide', style: GoogleFonts.poppins()),
                          subtitle: Text('View installation instructions', style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _launchUrl(widget.product.installationGuidePdf),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final inCart = widget.product.id != null ? cartProvider.hasProduct(widget.product.id!) : false;
          final cartQuantity = widget.product.id != null ? cartProvider.getQuantity(widget.product.id!) : 0;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
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
                  IconButton(
                    icon: const Icon(Icons.remove),
                    color: const Color(0xFFFF9800),
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
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: const Color(0xFFFF9800),
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
                    onPressed: widget.product.isOutOfStock || !widget.product.isApproved || widget.product.id == null
                        ? null
                        : () async {
                            try {
                              if (inCart) {
                                Navigator.pushNamed(context, '/shop/cart');
                              } else {
                                await cartProvider.addItem(
                                  widget.product,
                                  quantity: _quantity,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added to cart',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.green,
                                      action: SnackBarAction(
                                        label: 'View Cart',
                                        textColor: Colors.white,
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
                                    content: Text(
                                      e.toString(),
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      inCart ? 'View Cart ($cartQuantity)' : 'Add to Cart',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}