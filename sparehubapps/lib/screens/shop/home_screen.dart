import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../models/order.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/common.dart';
import 'products/product_catalog_screen.dart';
import 'products/product_details_screen.dart';
import 'orders/orders_screen.dart';
import 'orders/order_details_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => ShopHomeScreenState();
}

class ShopHomeScreenState extends State<ShopHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _tabs = [
    _HomeTab(
      onViewAllOrders: (context) {
        context.findAncestorStateOfType<ShopHomeScreenState>()?.setSelectedIndex(3);
      },
    ),
    const ProductCatalogScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ShopProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void didUpdateWidget(ShopHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<ShopProvider>(context, listen: false);
    await Future.wait([
      provider.refreshCategories(),
      provider.refreshFeaturedProducts(),
      provider.refreshOrders(),
    ]);
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'SpareHub';
      case 1:
        return 'Products';
      case 2:
        return 'Cart';
      case 3:
        return 'Orders';
      case 4:
        return 'Profile';
      default:
        return 'SpareHub';
    }
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.forward().then((_) => _animationController.reverse());
    });
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
            child: Text(
              _getAppBarTitle(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.items.length;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Cart',
                    onPressed: () => setSelectedIndex(2),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(0xFFFF9800),
                        child: Text(
                          itemCount.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF9800),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 12,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        onTap: setSelectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.category : Icons.category_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3 ? Icons.shopping_bag : Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 4 ? Icons.person : Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Function(BuildContext) onViewAllOrders;

  const _HomeTab({required this.onViewAllOrders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ShopProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return ErrorView(
            message: provider.error!,
            onRetry: () {
              provider.refreshCategories();
              provider.refreshFeaturedProducts();
              provider.refreshOrders();
            },
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            final shopProvider = Provider.of<ShopProvider>(context, listen: false);
            await Future.wait([
              shopProvider.refreshCategories(),
              shopProvider.refreshFeaturedProducts(),
              shopProvider.refreshOrders(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: TextEditingController(),
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        hintText: 'Search spare parts...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onSubmitted: (value) {
                        provider.setSearchQuery(value);
                        final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
                        if (homeScreenState != null) {
                          homeScreenState.setSelectedIndex(1); // Switch to Products tab
                        }
                      },
                    ),
                  ),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Categories',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: provider.categories.isEmpty
                          ? Center(
                              child: Text(
                                'No categories available',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.categories.length,
                              itemBuilder: (context, index) {
                                return _buildCategoryCard(context, provider.categories[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Featured Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Products',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
                              if (homeScreenState != null) {
                                homeScreenState.setSelectedIndex(1); // Switch to Products tab
                              }
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      provider.featuredProducts.isEmpty
                          ? Text(
                              'No featured products available',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            )
                          : SizedBox(
                              height: 330, // Increased height
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 330,
                                  viewportFraction: 0.75,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: provider.featuredProducts.length > 1,
                                  autoPlay: provider.featuredProducts.length > 1,
                                  autoPlayInterval: const Duration(seconds: 4),
                                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                ),
                                items: provider.featuredProducts
                                    .map((product) => _buildFeaturedProductCard(context, product))
                                    .toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              // Recent Orders
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Orders',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () => onViewAllOrders(context),
                            child: Text(
                              'View All',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      provider.orders.isEmpty
                          ? Text(
                              'No recent orders available',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.orders.length,
                              itemBuilder: (context, index) {
                                return _buildRecentOrderItem(context, provider.orders[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: const SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Provider.of<ShopProvider>(context, listen: false)
              .setSelectedCategories([category.id.toString()]);
          final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
          if (homeScreenState != null) {
            homeScreenState.setSelectedIndex(1); // Switch to Products tab
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: category.image ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category.name),
                          color: Colors.grey[400],
                          size: 30,
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Provider.of<ShopProvider>(context, listen: false).refreshCategories();
                          },
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRect(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: product.primaryImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Provider.of<ShopProvider>(context, listen: false).refreshFeaturedProducts();
                            },
                            child: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(3), // Further reduced padding
                  child: ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontSize: 9, // Reduced further
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 0.5), // Minimized spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  product.formattedDiscountedPrice,
                                  style: GoogleFonts.poppins(
                                    fontSize: 7, // Reduced further
                                    color: const Color(0xFFFF9800),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (product.discount > 0)
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    product.formattedPrice,
                                    style: GoogleFonts.poppins(
                                      fontSize: 5, // Reduced further
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              product.isLowStock ? 'Low Stock' : 'In Stock',
                              style: GoogleFonts.poppins(
                                fontSize: 5, // Reduced further
                                color: product.isLowStock ? Colors.red : Colors.green,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFFF9800), size: 12), // Reduced further
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final cartProvider = Provider.of<CartProvider>(context, listen: false);
                              cartProvider.addItem(product);
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
                                      final homeScreenState = context.findAncestorStateOfType<ShopHomeScreenState>();
                                      if (homeScreenState != null) {
                                        homeScreenState.setSelectedIndex(2);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const CartScreen()),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderItem(BuildContext context, Order order) {
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': Colors.amber,
      'processing': Colors.blue,
      'shipped': Colors.purple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
      'returned': Colors.grey,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (statusColors[order.status.toString().split('.').last] ?? Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: statusColors[order.status.toString().split('.').last] ?? Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (statusColors[order.status.toString().split('.').last] ?? Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toString().split('.').last,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColors[order.status.toString().split('.').last] ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'engine parts':
        return Icons.engineering;
      case 'brake system':
        return Icons.build;
      case 'transmission':
        return Icons.settings;
      case 'electrical':
        return Icons.electric_bolt;
      case 'body parts':
        return Icons.car_repair;
      default:
        return Icons.category;
    }
  }
}