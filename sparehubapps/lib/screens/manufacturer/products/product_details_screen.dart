import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/product.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../widgets/common/common.dart';
import 'product_form_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'toggle_status':
                  final provider = Provider.of<ManufacturerProvider>(
                    context,
                    listen: false,
                  );
                  final updatedProduct = product.copyWith(
                    isActive: !product.isActive,
                  );
                  await provider.updateProduct(updatedProduct);
                  break;
                case 'delete':
                  if (product.id != null) {
                    final provider = Provider.of<ManufacturerProvider>(
                      context,
                      listen: false,
                    );
                    await provider.deleteProduct(product.id!);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(product.isActive ? 'Deactivate' : 'Activate'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Images
            if (product.images.isEmpty)
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              )
            else
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      product.images[index],
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
              ),

            Padding(
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
                          color: product.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: product.isActive ? Colors.green : Colors.grey,
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
                          color: product.isApproved
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.isApproved ? 'Approved' : 'Pending Approval',
                          style: TextStyle(
                            color: product.isApproved ? Colors.blue : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (product.isFeatured)
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

                  // Basic Info
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.discount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Discount: ${product.discount}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      product.formattedDiscountedPrice,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Stock Info
                  _buildInfoCard(
                    context,
                    title: 'Stock Information',
                    content: Column(
                      children: [
                        _buildInfoRow(
                          'Current Stock',
                          product.stockQuantity.toString(),
                          icon: Icons.inventory_2_outlined,
                          warning: product.isLowStock,
                        ),
                        _buildInfoRow(
                          'Minimum Order Quantity',
                          product.minOrderQuantity.toString(),
                          icon: Icons.shopping_cart_outlined,
                        ),
                        if (product.maxOrderQuantity != null)
                          _buildInfoRow(
                            'Maximum Order Quantity',
                            product.maxOrderQuantity.toString(),
                            icon: Icons.shopping_cart_outlined,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showUpdateStockDialog(context);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Update Stock'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details
                  _buildInfoCard(
                    context,
                    title: 'Product Details',
                    content: Column(
                      children: [
                        _buildInfoRow(
                          'SKU',
                          product.sku,
                          icon: Icons.qr_code_outlined,
                        ),
                        _buildInfoRow(
                          'Weight',
                          product.formattedWeight,
                          icon: Icons.scale_outlined,
                        ),
                        _buildInfoRow(
                          'Dimensions',
                          product.formattedDimensions,
                          icon: Icons.straighten_outlined,
                        ),
                        _buildInfoRow(
                          'Material',
                          product.formattedMaterial,
                          icon: Icons.build_outlined,
                        ),
                        _buildInfoRow(
                          'Color',
                          product.formattedColor,
                          icon: Icons.color_lens_outlined,
                        ),
                        _buildInfoRow(
                          'Shipping Cost',
                          product.formattedShippingCost,
                          icon: Icons.local_shipping_outlined,
                        ),
                        _buildInfoRow(
                          'Shipping Time',
                          product.formattedShippingTime,
                          icon: Icons.access_time_outlined,
                        ),
                        _buildInfoRow(
                          'Origin Country',
                          product.formattedOriginCountry,
                          icon: Icons.public_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Technical Specification PDF
                  if (product.technicalSpecificationPdf != null)
                    _buildInfoCard(
                      context,
                      title: 'Technical Specification',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.technicalSpecificationPdf!.split('/').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(product.technicalSpecificationPdf!);
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
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('View PDF'),
                          ),
                        ],
                      ),
                    ),

                  // Installation Guide PDF
                  if (product.installationGuidePdf != null)
                    _buildInfoCard(
                      context,
                      title: 'Installation Guide',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  product.installationGuidePdf!.split('/').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(product.installationGuidePdf!);
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
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('View PDF'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required Widget content,
      }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
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
              style: TextStyle(
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
      text: product.stockQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null && newQuantity >= 0 && product.id != null) {
                final provider = Provider.of<ManufacturerProvider>(
                  context,
                  listen: false,
                );
                await provider.updateProductStock(product.id!, newQuantity);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}