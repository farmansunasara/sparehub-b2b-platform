import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../widgets/common/common.dart';

class StockManagementScreen extends StatefulWidget {
  final bool showAppBar;

  const StockManagementScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  bool _isLoading = false;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      await provider.refreshProducts();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStock(Product product, int newQuantity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      await provider.updateProductStock(product.id, newQuantity);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpdateStockDialog(Product product) {
    final controller = TextEditingController(
      text: product.stockQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Stock: ${product.stockQuantity}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(controller.text);
              if (quantity != null) {
                Navigator.pop(context);
                _updateStock(product, quantity);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: Icon(
              _showLowStockOnly
                  ? Icons.warning_amber_rounded
                  : Icons.warning_amber_outlined,
            ),
            onPressed: () {
              setState(() {
                _showLowStockOnly = !_showLowStockOnly;
              });
            },
            tooltip: 'Show Low Stock Only',
          ),
        ],
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Material(
          elevation: 4,
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                _showLowStockOnly
                    ? Icons.warning_amber_rounded
                    : Icons.warning_amber_outlined,
              ),
              onPressed: () {
                setState(() {
                  _showLowStockOnly = !_showLowStockOnly;
                });
              },
              tooltip: 'Show Low Stock Only',
            ),
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: Consumer<ManufacturerProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return ErrorView(
                  message: provider.error!,
                  onRetry: _loadProducts,
                );
              }

              final products = _showLowStockOnly
                  ? provider.products.where((p) => p.stockQuantity < 10).toList()
                  : provider.products;

              if (products.isEmpty) {
                return const EmptyStateView(
                  message: 'No products found',
                  icon: Icons.inventory_2_outlined,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isLowStock = product.stockQuantity < 10;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: product.images.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.primaryImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        )
                            : Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey[400],
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          color: isLowStock ? Colors.orange : Colors.grey[600],
                          fontWeight: isLowStock ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showUpdateStockDialog(product),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
