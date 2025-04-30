import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../models/product.dart';
import '../../../widgets/common/common.dart';
import 'product_form_screen.dart';
import 'product_details_screen.dart';
import 'stock_management_screen.dart';

class ProductsListScreen extends StatefulWidget {
  final bool showAppBar;

  const ProductsListScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {
    'categoryId': null,
    'stockStatus': 'All',
    'minPrice': 0.0,
    'maxPrice': double.infinity,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      provider.refreshProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(
          'Products',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.warehouse_outlined),
            tooltip: 'Stock Management',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockManagementScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.appBarTheme.foregroundColor,
          unselectedLabelColor: theme.appBarTheme.foregroundColor?.withOpacity(0.7),
          indicatorColor: const Color(0xFFFF9800), // Orange accent
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
          ],
        ),
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Material(
          elevation: 4,
          color: theme.appBarTheme.backgroundColor,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 48.0),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFF9800),
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Inactive'),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.warehouse_outlined),
                  tooltip: 'Stock Management',
                  color: theme.appBarTheme.foregroundColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StockManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Search by name or SKU...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.tune, color: Colors.grey[600]),
                        onPressed: () => _showFilterDialog(context),
                      ),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: Consumer<ManufacturerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return ErrorView(
                    message: provider.error!,
                    onRetry: _loadProducts,
                  );
                }

                final activeProducts = _filterProducts(provider.activeProducts);
                final inactiveProducts = _filterProducts(provider.inactiveProducts);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductList(activeProducts, provider),
                    _buildProductList(inactiveProducts, provider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF9800), // Orange accent
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.sku.toLowerCase().contains(_searchQuery);

      final matchesCategory = _filters['categoryId'] == null ||
          product.categoryId == _filters['categoryId'];

      final matchesStock = _filters['stockStatus'] == 'All' ||
          (_filters['stockStatus'] == 'Low Stock' && product.isLowStock) ||
          (_filters['stockStatus'] == 'In Stock' && !product.isLowStock);

      final matchesPrice = product.price >= _filters['minPrice'] &&
          product.price <= _filters['maxPrice'];

      return matchesSearch && matchesCategory && matchesStock && matchesPrice;
    }).toList();
  }

  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<ManufacturerProvider>(context, listen: false);
    String? selectedCategoryId = _filters['categoryId'];
    String selectedStockStatus = _filters['stockStatus'];
    double minPrice = _filters['minPrice'];
    double maxPrice = _filters['maxPrice'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Products', style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Filter
              Text('Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              DropdownButtonFormField<String>(
                value: selectedCategoryId,
                hint: Text('All Categories', style: GoogleFonts.poppins()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...provider.categories.map((category) => DropdownMenuItem(
                    value: category.id.toString(),
                    child: Text(category.name, style: GoogleFonts.poppins()),
                  )),
                ],
                onChanged: (value) {
                  selectedCategoryId = value;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // Stock Status Filter
              Text('Stock Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              DropdownButtonFormField<String>(
                value: selectedStockStatus,
                items: ['All', 'Low Stock', 'In Stock']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status, style: GoogleFonts.poppins()),
                ))
                    .toList(),
                onChanged: (value) {
                  selectedStockStatus = value!;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),

              // Price Range Filter
              Text('Price Range', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              RangeSlider(
                values: RangeValues(minPrice, maxPrice == double.infinity ? 10000 : maxPrice),
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  minPrice.toStringAsFixed(0),
                  maxPrice == double.infinity ? '∞' : maxPrice.toStringAsFixed(0),
                ),
                activeColor: Theme.of(context).primaryColor,
                onChanged: (values) {
                  minPrice = values.start;
                  maxPrice = values.end;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filters['categoryId'] = selectedCategoryId;
                _filters['stockStatus'] = selectedStockStatus;
                _filters['minPrice'] = minPrice;
                _filters['maxPrice'] = maxPrice == 10000 ? double.infinity : maxPrice;
              });
              Navigator.pop(context);
            },
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            child: Text('Apply', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products, ManufacturerProvider provider) {
    if (products.isEmpty) {
      return EmptyStateView(
        message: 'No products found',
        icon: Icons.inventory_2_outlined,
        actionLabel: 'Add Product',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: _buildProductCard(products[index]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Hero(
                tag: 'product-${product.id}',
                child: product.images.isNotEmpty
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                )
                    : Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFFF9800),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (product.discount > 0) ...[
                          Text(
                            product.formattedDiscountedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: product.isLowStock ? Colors.orange : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${product.stockQuantity}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: product.isLowStock ? Colors.orange : Colors.grey[600],
                                fontWeight: product.isLowStock ? FontWeight.w500 : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormScreen(product: product),
                            ),
                          );
                          break;
                        case 'activate':
                        case 'deactivate':
                          try {
                            await provider.updateProduct(
                              product: product.copyWith(isActive: !product.isActive),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Product ${product.isActive ? 'deactivated' : 'activated'}',
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
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit', style: GoogleFonts.poppins()),
                      ),
                      PopupMenuItem(
                        value: product.isActive ? 'deactivate' : 'activate',
                        child: Text(
                          product.isActive ? 'Deactivate' : 'Activate',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}