import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../widgets/common/common.dart';
import 'product_form_screen.dart';

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
  bool _isStockExpanded = true;
  bool _isDetailsExpanded = true;
  bool _isTechnicalExpanded = true;
  bool _isInstallationExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: widget.product),
                ),
              );
            },
            tooltip: 'Edit Product',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = Provider.of<ManufacturerProvider>(context, listen: false);
              switch (value) {
                case 'toggle_status':
                  try {
                    final updatedProduct = widget.product.copyWith(isActive: !widget.product.isActive);
                    await provider.updateProduct(product: updatedProduct); // Fixed: Named parameter
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Product ${widget.product.isActive ? 'deactivated' : 'activated'}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  break;
                case 'delete':
                  if (widget.product.id != null) {
                    try {
                      await provider.deleteProduct(widget.product.id!);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product deleted', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(
                  widget.product.isActive ? 'Deactivate' : 'Activate',
                  style: GoogleFonts.poppins(),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: GoogleFonts.poppins()),
              ),
            ],
            icon: Icon(Icons.more_vert, color: theme.appBarTheme.foregroundColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Images
            Container(
              height: 300,
              color: theme.inputDecorationTheme.fillColor,
              child: widget.product.images.isEmpty
                  ? Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              )
                  : Stack(
                children: [
                  Hero(
                    tag: 'product-${widget.product.id}',
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: widget.product.images.map((image) {
                        return Image.network(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.inputDecorationTheme.fillColor,
                            child: Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.product.images.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        widget.product.isActive ? 'Active' : 'Inactive',
                        widget.product.isActive ? Colors.green : Colors.grey,
                      ),
                      _buildBadge(
                        widget.product.isApproved ? 'Approved' : 'Pending Approval',
                        widget.product.isApproved ? Colors.blue : Colors.orange,
                      ),
                      if (widget.product.isFeatured)
                        _buildBadge('Featured', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Basic Info
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.product.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.product.formattedDiscountedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.product.discount > 0)
                    Text(
                      'Discount: ${widget.product.discount}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Stock Information
                  _buildExpansionCard(
                    context,
                    title: 'Stock Information',
                    isExpanded: _isStockExpanded,
                    onTap: () => setState(() => _isStockExpanded = !_isStockExpanded),
                    content: Column(
                      children: [
                        _buildInfoRow(
                          'Current Stock',
                          widget.product.stockQuantity.toString(),
                          icon: Icons.inventory_2_outlined,
                          warning: widget.product.isLowStock,
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showUpdateStockDialog(context);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text('Update Stock', style: GoogleFonts.poppins()),
                          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                            backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details
                  _buildExpansionCard(
                    context,
                    title: 'Product Details',
                    isExpanded: _isDetailsExpanded,
                    onTap: () => setState(() => _isDetailsExpanded = !_isDetailsExpanded),
                    content: Column(
                      children: [
                        _buildInfoRow('SKU', widget.product.sku, icon: Icons.qr_code_outlined),
                        _buildInfoRow('Weight', widget.product.formattedWeight, icon: Icons.scale_outlined),
                        _buildInfoRow('Dimensions', widget.product.formattedDimensions,
                            icon: Icons.straighten_outlined),
                        _buildInfoRow('Material', widget.product.formattedMaterial, icon: Icons.build_outlined),
                        _buildInfoRow('Color', widget.product.formattedColor, icon: Icons.color_lens_outlined),
                        _buildInfoRow('Shipping Cost', widget.product.formattedShippingCost,
                            icon: Icons.local_shipping_outlined),
                        _buildInfoRow('Shipping Time', widget.product.formattedShippingTime,
                            icon: Icons.access_time_outlined),
                        _buildInfoRow('Origin Country', widget.product.formattedOriginCountry,
                            icon: Icons.public_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Technical Specification PDF
                  if (widget.product.technicalSpecificationPdf != null)
                    _buildExpansionCard(
                      context,
                      title: 'Technical Specification',
                      isExpanded: _isTechnicalExpanded,
                      onTap: () => setState(() => _isTechnicalExpanded = !_isTechnicalExpanded),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.product.technicalSpecificationPdf!.split('/').last,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(widget.product.technicalSpecificationPdf!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not open PDF', style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.visibility_outlined),
                            label: Text('View PDF', style: GoogleFonts.poppins()),
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Installation Guide PDF
                  if (widget.product.installationGuidePdf != null)
                    _buildExpansionCard(
                      context,
                      title: 'Installation Guide',
                      isExpanded: _isInstallationExpanded,
                      onTap: () => setState(() => _isInstallationExpanded = !_isInstallationExpanded),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.product.installationGuidePdf!.split('/').last,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(widget.product.installationGuidePdf!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not open PDF', style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.visibility_outlined),
                            label: Text('View PDF', style: GoogleFonts.poppins()),
                            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExpansionCard(
      BuildContext context, {
        required String title,
        required bool isExpanded,
        required VoidCallback onTap,
        required Widget content,
      }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
            onTap: onTap,
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        IconData? icon,
        bool warning = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: warning ? Colors.orange : Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
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
                color: warning ? Colors.orange : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context) {
    final controller = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock', style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            labelText: 'New Stock Quantity',
            labelStyle: GoogleFonts.poppins(),
            border: Theme.of(context).inputDecorationTheme.border,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null && newQuantity >= 0 && widget.product.id != null) {
                final provider = Provider.of<ManufacturerProvider>(context, listen: false);
                try {
                  await provider.updateProductStock(widget.product.id!, newQuantity);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stock updated', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: Text('Update', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}