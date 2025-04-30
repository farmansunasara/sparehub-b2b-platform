import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/order.dart';
import '../../providers/manufacturer_provider.dart';
import '../../screens/manufacturer/notifications/notifications_screen.dart';
import '../../screens/manufacturer/profile/profile_screen.dart';
import '../../screens/manufacturer/settings/settings_screen.dart';
import '../../screens/manufacturer/orders/orders_screen.dart';
import '../../screens/manufacturer/orders/order_details_screen.dart';
import '../../screens/manufacturer/products/product_form_screen.dart';
import '../../screens/manufacturer/products/stock_management_screen.dart';
import '../../screens/manufacturer/products/products_list_screen.dart';
import '../../screens/manufacturer/analytics/analytics_screen.dart';
import '../../widgets/common/common.dart';

class ManufacturerHomeScreen extends StatefulWidget {
  const ManufacturerHomeScreen({super.key});

  @override
  State<ManufacturerHomeScreen> createState() => _ManufacturerHomeScreenState();
}

class _ManufacturerHomeScreenState extends State<ManufacturerHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
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
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      provider.refreshProducts();
      provider.refreshOrders();
      provider.refreshAnalytics();
      provider.getManufacturerProfile();
    });
  }

  @override
  void didUpdateWidget(ManufacturerHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation on tab change
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'SpareHub';
      case 1:
        return 'Products';
      case 2:
        return 'Orders';
      case 3:
        return 'Analytics';
      default:
        return 'SpareHub';
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
                  const Color(0xFF1976D2), // Primary blue
                  const Color(0xFFFF9800), // Orange accent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _getAppBarTitle(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white, // Base color for gradient
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          Consumer<ManufacturerProvider>(
            builder: (context, provider, child) {
              final logoUrl = provider.manufacturerProfile?['logo'];
              final companyName = provider.manufacturerProfile?['company_name'] ?? 'M';
              return IconButton(
                icon: logoUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: logoUrl,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: theme.primaryColor,
                            child: Text(
                              companyName[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        child: Text(
                          companyName[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Consumer<ManufacturerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return ErrorView(
                  message: provider.error!,
                  onRetry: () {
                    provider.refreshProducts();
                    provider.refreshOrders();
                    provider.refreshAnalytics();
                    provider.getManufacturerProfile();
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await provider.refreshProducts();
                  await provider.refreshOrders();
                  await provider.refreshAnalytics();
                  await provider.getManufacturerProfile();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatsSection(context, provider),
                      _buildRecentOrdersSection(context, provider),
                      _buildQuickActionsSection(context),
                    ],
                  ),
                ),
              );
            },
          ),
          const ProductsListScreen(showAppBar: false),
          const OrdersScreen(showAppBar: false),
          const AnalyticsScreen(showAppBar: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: theme.cardTheme.color,
        elevation: 8,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _animationController.forward().then((_) => _animationController.reverse());
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.inventory_2 : Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 2 ? Icons.shopping_bag : Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3 ? Icons.analytics : Icons.analytics_outlined),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, ManufacturerProvider provider) {
    final theme = Theme.of(context);
    final totalOrders = provider.totalOrders;
    final totalRevenue = provider.totalRevenue;
    final productCount = provider.activeProducts.length;
    final lowStockCount = provider.lowStockProducts;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '₹${(totalRevenue / 100000).toStringAsFixed(1)}L',
                  Icons.currency_rupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Products',
                  productCount.toString(),
                  Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  lowStockCount.toString(),
                  Icons.warning_amber_outlined,
                  isWarning: lowStockCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isWarning = false}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isWarning ? Colors.orange : theme.primaryColor,
                ),
                const Spacer(),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? Colors.orange : theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context, ManufacturerProvider provider) {
    final theme = Theme.of(context);
    // Sort orders by createdAt (descending) and take 5
    final recentOrders = provider.orders
        .where((order) => order.status != OrderStatus.cancelled && order.status != OrderStatus.returned)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final displayOrders = recentOrders.take(5).toList();

    return Padding(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          displayOrders.isEmpty
              ? Text(
                  'No recent orders available.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                )
              : _buildRecentOrdersList(displayOrders),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(List<Order> orders) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: Theme.of(context).cardTheme.elevation,
            shape: Theme.of(context).cardTheme.shape,
            color: Theme.of(context).cardTheme.color,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                'Order #${order.id}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${order.shopName} - ₹${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: _buildOrderStatus(order.status.toString().split('.').last),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatus(String status) {
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': Colors.amber,
      'processing': Colors.blue,
      'shipped': Colors.purple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
      'returned': Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (statusColors[status.toLowerCase()] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColors[status.toLowerCase()] ?? Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Add Product',
                  Icons.add_box_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductFormScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'Update Stock',
                  Icons.inventory_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StockManagementScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Orders',
                  Icons.shopping_bag_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  'Analytics',
                  Icons.analytics_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, {required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}