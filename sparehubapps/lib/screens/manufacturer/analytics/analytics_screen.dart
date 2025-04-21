import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    _loadData();
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
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Analytics'),
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
              child: Text(period),
            )).toList(),
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
                child: Text(period),
              )).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedPeriod),
                    const Icon(Icons.arrow_drop_down),
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
                            value: '₹${provider.totalRevenue.toStringAsFixed(2)}',
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
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateRevenueData(provider.orders),
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Products',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ...provider.products
                                .take(5)
                                .map((product) => ListTile(
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
                              title: Text(product.name),
                              subtitle: Text('Stock: ${product.stockQuantity}'),
                              trailing: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                                .toList(),
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
    return Card(
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
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

  List<FlSpot> _generateRevenueData(List<Order> orders) {
    // TODO: Implement actual revenue data generation
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 1),
      const FlSpot(2, 4),
      const FlSpot(3, 2),
      const FlSpot(4, 5),
      const FlSpot(5, 3),
      const FlSpot(6, 4),
    ];
  }

  List<PieChartSectionData> _generateOrderStatusData(List<Order> orders) {
    final statusCounts = {
      OrderStatus.pending: orders.where((o) => o.status == OrderStatus.pending).length,
      OrderStatus.processing: orders.where((o) => o.status == OrderStatus.processing).length,
      OrderStatus.shipped: orders.where((o) => o.status == OrderStatus.shipped).length,
      OrderStatus.delivered: orders.where((o) => o.status == OrderStatus.delivered).length,
    };

    final colors = {
      OrderStatus.pending: Colors.orange,
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
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}
