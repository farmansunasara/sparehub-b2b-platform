import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../widgets/common/common.dart';

class ReportType {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> availableFormats;

  const ReportType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.availableFormats,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = false;
  DateTimeRange? _selectedDateRange;
  final List<String> _selectedCategories = [];

  final List<ReportType> _reportTypes = [
    ReportType(
      id: 'sales',
      name: 'Sales Report',
      description: 'Detailed analysis of sales performance',
      icon: Icons.trending_up,
      availableFormats: ['PDF', 'Excel', 'CSV'],
    ),
    ReportType(
      id: 'inventory',
      name: 'Inventory Report',
      description: 'Current stock levels and movement',
      icon: Icons.inventory_2_outlined,
      availableFormats: ['PDF', 'Excel', 'CSV'],
    ),
    ReportType(
      id: 'orders',
      name: 'Orders Report',
      description: 'Order history and status analysis',
      icon: Icons.shopping_bag_outlined,
      availableFormats: ['PDF', 'Excel'],
    ),
    ReportType(
      id: 'financial',
      name: 'Financial Report',
      description: 'Revenue, expenses, and profit analysis',
      icon: Icons.account_balance_outlined,
      availableFormats: ['PDF', 'Excel'],
    ),
    ReportType(
      id: 'customers',
      name: 'Customer Report',
      description: 'Shop behavior and order patterns',
      icon: Icons.store_outlined,
      availableFormats: ['PDF', 'Excel'],
    ),
  ];

  Future<void> _selectDateRange() async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  Future<void> _generateReport(ReportType reportType) async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate ${reportType.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Date Range:'),
            Text(
              '${_selectedDateRange!.start.toString().split(' ')[0]} to '
              '${_selectedDateRange!.end.toString().split(' ')[0]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Available Formats:'),
            Wrap(
              spacing: 8,
              children: reportType.availableFormats.map((format) {
                return ChoiceChip(
                  label: Text(format),
                  selected: false,
                  onSelected: (selected) {
                    Navigator.pop(context);
                    _showGeneratingDialog(reportType, format);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGeneratingDialog(ReportType reportType, String format) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Generating ${reportType.name} in $format format...'),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reportType.name} generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date Range',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDateRange,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined),
                              const SizedBox(width: 16),
                              Text(
                                _selectedDateRange != null
                                    ? '${_selectedDateRange!.start.toString().split(' ')[0]} to '
                                        '${_selectedDateRange!.end.toString().split(' ')[0]}'
                                    : 'Select date range',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Available Reports',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Report Types
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reportTypes.length,
                itemBuilder: (context, index) {
                  final reportType = _reportTypes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          reportType.icon,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: Text(reportType.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(reportType.description),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: reportType.availableFormats.map((format) {
                              return Chip(
                                label: Text(
                                  format,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.grey[200],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _generateReport(reportType),
                        child: const Text('Generate'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
