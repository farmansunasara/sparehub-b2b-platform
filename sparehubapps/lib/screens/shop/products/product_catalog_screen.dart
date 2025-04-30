import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/product.dart';
import '../../../models/category.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/common/common.dart';
import 'product_details_screen.dart';
import '../home_screen.dart'; // Import to access ShopHomeScreenState

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;
  String _sortBy = 'name';
  bool _isAscending = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ShopProvider>(context, listen: false);
      print('Fetching initial products...');
      provider.refreshProducts(reset: true);
    });

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<ShopProvider>(context, listen: false);
        if (!provider.isLoading && provider.hasMoreProducts) {
          print('Fetching more products...');
          provider.refreshProducts();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _navigateToCartTab() {
    // Find the ShopHomeScreen state to switch tabs
    final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
    if (homeScreenState != null) {
      homeScreenState.setSelectedIndex(2); // Switch to Cart tab
    } else {
      // Fallback navigation if not in ShopHomeScreen
      Navigator.pushNamed(context, '/shop/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              hintText: 'Search by name or SKU...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600]),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<ShopProvider>(context, listen: false).setSearchQuery('');
                },
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              Provider.of<ShopProvider>(context, listen: false).setSearchQuery(value);
            },
          ),
        ),

        // Sort Options and Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Sort by:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    style: GoogleFonts.poppins(),
                    items: const [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name'),
                      ),
                      DropdownMenuItem(
                        value: 'price',
                        child: Text('Price'),
                      ),
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('Newest'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                        Provider.of<ShopProvider>(context, listen: false)
                            .setSortBy(value, ascending: _isAscending);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                      });
                      Provider.of<ShopProvider>(context, listen: false)
                          .setSortBy(_sortBy, ascending: _isAscending);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                    tooltip: 'Toggle View',
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                        _animationController.forward().then((_) => _animationController.reverse());
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter',
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                  // Consumer<CartProvider>(
                  //   builder: (context, cartProvider, child) {
                  //     final itemCount = cartProvider.items.length;
                  //     return Stack(
                  //       children: [
                  //         IconButton(
                  //           icon: const Icon(Icons.shopping_cart_outlined),
                  //           tooltip: 'Cart',
                  //           onPressed: _navigateToCartTab,
                  //         ),
                  //         if (itemCount > 0)
                  //           Positioned(
                  //             right: 8,
                  //             top: 8,
                  //             child: CircleAvatar(
                  //               radius: 8,
                  //               backgroundColor: const Color(0xFFFF9800),
                  //               child: Text(
                  //                 itemCount.toString(),
                  //                 style: GoogleFonts.poppins(
                  //                   color: Colors.white,
                  //                   fontSize: 10,
                  //                   fontWeight: FontWeight.w600,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //       ],
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),

        // Product List/Grid
        Expanded(
          child: Consumer<ShopProvider>(
            builder: (context, provider, child) {
              print('ShopProvider state: isLoading=${provider.isLoading}, products=${provider.products.length}, error=${provider.error}');
              if (provider.isLoading && provider.products.isEmpty) {
                print('Showing shimmer loading');
                return _buildShimmerLoading();
              }

              if (provider.error != null) {
                print('Showing error: ${provider.error}');
                return ErrorView(
                  message: provider.error!,
                  onRetry: () {
                    provider.refreshProducts(reset: true);
                  },
                );
              }

              // Filter products to show only approved ones
              final products = provider.products.where((p) => p.isApproved).toList();
              print('Filtered products: ${products.length}, raw products: ${provider.products.length}');
              if (products.isEmpty) {
                print('Showing empty state');
                return EmptyStateView(
                  message: 'No approved products found',
                  icon: Icons.inventory_2_outlined,
                  actionLabel: 'Clear Filters',
                  onAction: () {
                    provider.resetFilters();
                    _searchController.clear();
                  },
                );
              }

              print('Showing product grid/list with ${products.length} products');
              return RefreshIndicator(
                onRefresh: () => provider.refreshProducts(reset: true),
                child: _isGridView
                    ? _buildProductGrid(products, provider)
                    : _buildProductList(products, provider),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(List<Product> products, ShopProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length + (provider.hasMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length && provider.hasMoreProducts) {
          return const Center(child: CircularProgressIndicator());
        }
        final product = products[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: _ProductGridItem(
            product: product,
            onTap: () => _navigateToProductDetails(product),
            onNavigateToCart: _navigateToCartTab,
          ),
        );
      },
    );
  }

  Widget _buildProductList(List<Product> products, ShopProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: products.length + (provider.hasMoreProducts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length && provider.hasMoreProducts) {
          return const Center(child: CircularProgressIndicator());
        }
        final product = products[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: _ProductListItem(
            product: product,
            onTap: () => _navigateToProductDetails(product),
            onNavigateToCart: _navigateToCartTab,
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _FilterBottomSheet(scrollController: scrollController);
          },
        );
      },
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onNavigateToCart;

  const _ProductGridItem({
    required this.product,
    required this.onTap,
    required this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                Expanded(
                  child: Hero(
                    tag: 'product-${product.id ?? ''}',
                    child: product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.primaryImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          )
                        : Container(
                            color: theme.inputDecorationTheme.fillColor,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.formattedPrice,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFFFF9800),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (product.discount > 0)
                                Text(
                                  product.formattedDiscountedPrice,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              final inCart = product.id != null ? cartProvider.hasProduct(product.id!) : false;
                              return IconButton(
                                icon: Icon(
                                  inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                  color: const Color(0xFFFF9800),
                                  size: 20,
                                ),
                                onPressed: product.isOutOfStock || !product.isApproved || product.id == null
                                    ? null
                                    : () async {
                                        try {
                                          if (inCart) {
                                            onNavigateToCart();
                                          } else {
                                            await cartProvider.addItem(
                                              product,
                                              quantity: product.minOrderQuantity,
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
                                                    onPressed: onNavigateToCart,
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
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.isOutOfStock
                            ? 'Out of Stock'
                            : product.isLowStock
                                ? 'Low Stock'
                                : 'In Stock: ${product.stockQuantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: product.isOutOfStock
                              ? Colors.red
                              : product.isLowStock
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onNavigateToCart;

  const _ProductListItem({
    required this.product,
    required this.onTap,
    required this.onNavigateToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Hero(
                    tag: 'product-${product.id ?? ''}',
                    child: product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.primaryImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          )
                        : Container(
                            color: theme.inputDecorationTheme.fillColor,
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),

                // Product Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.formattedPrice,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFFF9800),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (product.discount > 0)
                                  Text(
                                    product.formattedDiscountedPrice,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, child) {
                                final inCart = product.id != null ? cartProvider.hasProduct(product.id!) : false;
                                return IconButton(
                                  icon: Icon(
                                    inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                    color: const Color(0xFFFF9800),
                                    size: 20,
                                  ),
                                  onPressed: product.isOutOfStock || !product.isApproved || product.id == null
                                      ? null
                                      : () async {
                                          try {
                                            if (inCart) {
                                              onNavigateToCart();
                                            } else {
                                              await cartProvider.addItem(
                                                product,
                                                quantity: product.minOrderQuantity,
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
                                                      onPressed: onNavigateToCart,
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
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Material: ${product.formattedMaterial} | Color: ${product.formattedColor}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.isOutOfStock
                              ? 'Out of Stock'
                              : product.isLowStock
                                  ? 'Low Stock'
                                  : 'In Stock: ${product.stockQuantity}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: product.isOutOfStock
                                ? Colors.red
                                : product.isLowStock
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (product.isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final ScrollController scrollController;

  const _FilterBottomSheet({required this.scrollController});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 100000);
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];
  String _stockStatus = 'all';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShopProvider>(context, listen: false);
    _priceRange = provider.priceRange;
    _selectedCategories = provider.selectedCategories;
    _selectedBrands = provider.selectedBrands;
    _stockStatus = provider.stockStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.cardTheme.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  final provider = Provider.of<ShopProvider>(context, listen: false);
                  provider.resetFilters();
                  setState(() {
                    _priceRange = const RangeValues(0, 100000);
                    _selectedCategories = [];
                    _selectedBrands = [];
                    _stockStatus = 'all';
                  });
                },
                child: Text(
                  'Reset',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),

          // Filter Options
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // Price Range
                Text(
                  'Price Range',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  activeColor: theme.primaryColor,
                  labels: RangeLabels(
                    '₹${_priceRange.start.round()}',
                    '₹${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Categories
                Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<ShopProvider>(
                  builder: (context, provider, child) {
                    return provider.categories.isEmpty
                        ? Text(
                            'No categories available',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            children: _buildCategoryChips(provider.categories),
                          );
                  },
                ),
                const SizedBox(height: 24),

                // Brands
                Text(
                  'Brands',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<ShopProvider>(
                  builder: (context, provider, child) {
                    return provider.brands.isEmpty
                        ? Text(
                            'No brands available',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            children: provider.brands.map((brand) {
                              final isSelected = _selectedBrands.contains(brand.id.toString());
                              return FilterChip(
                                label: Text(
                                  brand.name,
                                  style: GoogleFonts.poppins(),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedBrands.add(brand.id.toString());
                                    } else {
                                      _selectedBrands.remove(brand.id.toString());
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                  },
                ),
                const SizedBox(height: 24),

                // Stock Status
                Text(
                  'Stock Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _stockStatus,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All', style: GoogleFonts.poppins()),
                    ),
                    DropdownMenuItem(
                      value: 'in_stock',
                      child: Text('In Stock', style: GoogleFonts.poppins()),
                    ),
                    DropdownMenuItem(
                      value: 'low_stock',
                      child: Text('Low Stock', style: GoogleFonts.poppins()),
                    ),
                    DropdownMenuItem(
                      value: 'out_of_stock',
                      child: Text('Out of Stock', style: GoogleFonts.poppins()),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _stockStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final provider = Provider.of<ShopProvider>(context, listen: false);
                provider.setPriceRange(_priceRange);
                provider.setSelectedCategories(_selectedCategories);
                provider.setSelectedBrands(_selectedBrands);
                provider.setStockStatus(_stockStatus);
                provider.refreshProducts(reset: true);
                Navigator.pop(context);
              },
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: MaterialStateProperty.all(const Color(0xFFFF9800)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text('Apply Filters', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips(List<Category> categories) {
    return categories.map((category) {
      final isSelected = _selectedCategories.contains(category.id.toString());
      return FilterChip(
        label: Text(
          category.name,
          style: GoogleFonts.poppins(),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedCategories.add(category.id.toString());
            } else {
              _selectedCategories.remove(category.id.toString());
            }
          });
        },
      );
    }).toList();
  }
}