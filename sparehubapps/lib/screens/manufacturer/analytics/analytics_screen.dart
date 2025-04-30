import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../models/order.dart';
import '../../../widgets/common/common.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool showAppBar;

  const AnalyticsScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Defer data loading to after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ManufacturerProvider>(context, listen: false);
      await Future.wait([
        provider.refreshOrders(),
        provider.refreshProducts(),
        provider.refreshAnalytics(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              'Today',
              'This Week',
              'This Month',
              'This Year',
            ].map((period) => PopupMenuItem(
              value: period,
              child: Text(
                period,
                style: GoogleFonts.poppins(),
              ),
            )).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Material(
          elevation: 4,
          color: theme.appBarTheme.backgroundColor,
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<String>(
              initialValue: _selectedPeriod,
              onSelected: (value) {
                setState(() {
                  _selectedPeriod = value;
                });
              },
              itemBuilder: (context) => [
                'Today',
                'This Week',
                'This Month',
                'This Year',
              ].map((period) => PopupMenuItem(
                value: period,
                child: Text(
                  period,
                  style: GoogleFonts.poppins(),
                ),
              )).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFFF9800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: Consumer<ManufacturerProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return ErrorView(
                  message: provider.error!,
                  onRetry: _loadData,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Total Revenue',
                            value: '₹${(provider.totalRevenue / 100000).toStringAsFixed(1)}L',
                            icon: Icons.currency_rupee,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Total Orders',
                            value: provider.totalOrders.toString(),
                            icon: Icons.shopping_bag_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Active Products',
                            value: provider.activeProducts.length.toString(),
                            icon: Icons.inventory_2_outlined,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Low Stock',
                            value: provider.lowStockProducts.toString(),
                            icon: Icons.warning_amber_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    // Revenue Chart
                    _buildChartCard(
                      context,
                      title: 'Revenue Trend',
                      chart: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateRevenueData(provider.analytics ?? []),
                              isCurved: true,
                              color: theme.primaryColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Order Status Distribution
                    _buildChartCard(
                      context,
                      title: 'Order Status Distribution',
                      chart: PieChart(
                        PieChartData(
                          sections: _generateOrderStatusData(provider.orders),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Top Products
                    Card(
                      elevation: theme.cardTheme.elevation,
                      shape: theme.cardTheme.shape,
                      color: theme.cardTheme.color,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Products',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...provider.products.take(5).map((product) => ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.grey[400],
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Stock: ${product.stockQuantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildChartCard(
      BuildContext context, {
        required String title,
        required Widget chart,
      }) {
    final theme = Theme.of(context);
    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateRevenueData(List<dynamic> analytics) {
    // Example: Assume analytics is a list of maps with 'date' and 'revenue'
    return analytics.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final revenue = (data['revenue'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), revenue);
    }).toList();
  }

  List<PieChartSectionData> _generateOrderStatusData(List<Order> orders) {
    final statusCounts = {
      OrderStatus.pending: orders.where((o) => o.status == OrderStatus.pending).length,
      OrderStatus.confirmed: orders.where((o) => o.status == OrderStatus.confirmed).length,
      OrderStatus.processing: orders.where((o) => o.status == OrderStatus.processing).length,
      OrderStatus.shipped: orders.where((o) => o.status == OrderStatus.shipped).length,
      OrderStatus.delivered: orders.where((o) => o.status == OrderStatus.delivered).length,
    };

    final colors = {
      OrderStatus.pending: Colors.orange,
      OrderStatus.confirmed: Colors.amber,
      OrderStatus.processing: Colors.blue,
      OrderStatus.shipped: Colors.purple,
      OrderStatus.delivered: Colors.green,
    };

    return statusCounts.entries.map((entry) {
      final percentage = orders.isEmpty ? 0.0 : (entry.value / orders.length) * 100;
      return PieChartSectionData(
        color: colors[entry.key],
        value: percentage.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}