import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';

enum ReportType {
  sales,
  inventory,
  orders,
  financial,
  customers,
}

enum ReportFormat {
  pdf,
  excel,
  csv,
}

class ReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final List<String>? productIds;
  final List<String>? shopIds;
  final List<OrderStatus>? orderStatuses;
  final double? minAmount;
  final double? maxAmount;

  ReportFilter({
    this.startDate,
    this.endDate,
    this.categories,
    this.productIds,
    this.shopIds,
    this.orderStatuses,
    this.minAmount,
    this.maxAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'categories': categories,
      'productIds': productIds,
      'shopIds': shopIds,
      'orderStatuses': orderStatuses?.map((s) => s.toString()).toList(),
      'minAmount': minAmount,
      'maxAmount': maxAmount,
    };
  }
}

class Report {
  final String id;
  final String name;
  final ReportType type;
  final ReportFormat format;
  final DateTime generatedAt;
  final String downloadUrl;
  final ReportFilter filter;
  final bool isScheduled;
  final String? scheduleFrequency;

  Report({
    required this.id,
    required this.name,
    required this.type,
    required this.format,
    required this.generatedAt,
    required this.downloadUrl,
    required this.filter,
    this.isScheduled = false,
    this.scheduleFrequency,
  });
}

class ReportsProvider with ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Report> get salesReports =>
      _reports.where((r) => r.type == ReportType.sales).toList();

  List<Report> get inventoryReports =>
      _reports.where((r) => r.type == ReportType.inventory).toList();

  List<Report> get ordersReports =>
      _reports.where((r) => r.type == ReportType.orders).toList();

  List<Report> get financialReports =>
      _reports.where((r) => r.type == ReportType.financial).toList();

  List<Report> get customerReports =>
      _reports.where((r) => r.type == ReportType.customers).toList();

  Future<void> fetchReports() async {
    _setLoading(true);
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      _reports = [
        Report(
          id: '1',
          name: 'Monthly Sales Report - August 2023',
          type: ReportType.sales,
          format: ReportFormat.pdf,
          generatedAt: DateTime.now().subtract(const Duration(days: 1)),
          downloadUrl: 'https://example.com/reports/sales-aug-2023.pdf',
          filter: ReportFilter(
            startDate: DateTime(2023, 8, 1),
            endDate: DateTime(2023, 8, 31),
          ),
        ),
        Report(
          id: '2',
          name: 'Current Inventory Status',
          type: ReportType.inventory,
          format: ReportFormat.excel,
          generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          downloadUrl: 'https://example.com/reports/inventory-current.xlsx',
          filter: ReportFilter(),
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Report?> generateReport({
    required ReportType type,
    required ReportFormat format,
    required ReportFilter filter,
    String? name,
  }) async {
    _setLoading(true);
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2));
      
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name ?? _generateReportName(type),
        type: type,
        format: format,
        generatedAt: DateTime.now(),
        downloadUrl: 'https://example.com/reports/temp.pdf',
        filter: filter,
      );

      _reports.insert(0, report);
      notifyListeners();
      return report;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> scheduleReport({
    required ReportType type,
    required ReportFormat format,
    required ReportFilter filter,
    required String frequency,
    String? name,
  }) async {
    _setLoading(true);
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
      
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name ?? _generateReportName(type),
        type: type,
        format: format,
        generatedAt: DateTime.now(),
        downloadUrl: 'https://example.com/reports/scheduled.pdf',
        filter: filter,
        isScheduled: true,
        scheduleFrequency: frequency,
      );

      _reports.insert(0, report);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(milliseconds: 500));
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  String _generateReportName(ReportType type) {
    final date = DateTime.now();
    final formattedDate = '${date.day}-${date.month}-${date.year}';
    
    switch (type) {
      case ReportType.sales:
        return 'Sales Report - $formattedDate';
      case ReportType.inventory:
        return 'Inventory Report - $formattedDate';
      case ReportType.orders:
        return 'Orders Report - $formattedDate';
      case ReportType.financial:
        return 'Financial Report - $formattedDate';
      case ReportType.customers:
        return 'Customer Report - $formattedDate';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods for specific report types
  Future<Report?> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required ReportFormat format,
    List<String>? categories,
    List<String>? productIds,
  }) {
    return generateReport(
      type: ReportType.sales,
      format: format,
      filter: ReportFilter(
        startDate: startDate,
        endDate: endDate,
        categories: categories,
        productIds: productIds,
      ),
    );
  }

  Future<Report?> generateInventoryReport({
    required ReportFormat format,
    List<String>? categories,
    bool? lowStockOnly,
  }) {
    return generateReport(
      type: ReportType.inventory,
      format: format,
      filter: ReportFilter(
        categories: categories,
      ),
    );
  }

  Future<Report?> generateOrdersReport({
    required DateTime startDate,
    required DateTime endDate,
    required ReportFormat format,
    List<OrderStatus>? statuses,
    List<String>? shopIds,
  }) {
    return generateReport(
      type: ReportType.orders,
      format: format,
      filter: ReportFilter(
        startDate: startDate,
        endDate: endDate,
        orderStatuses: statuses,
        shopIds: shopIds,
      ),
    );
  }

  Future<Report?> generateFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
    required ReportFormat format,
  }) {
    return generateReport(
      type: ReportType.financial,
      format: format,
      filter: ReportFilter(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<Report?> generateCustomerReport({
    required DateTime startDate,
    required DateTime endDate,
    required ReportFormat format,
    List<String>? shopIds,
  }) {
    return generateReport(
      type: ReportType.customers,
      format: format,
      filter: ReportFilter(
        startDate: startDate,
        endDate: endDate,
        shopIds: shopIds,
      ),
    );
  }
}
