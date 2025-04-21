import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/car.dart';
import 'auth_provider.dart';

class ManufacturerProvider with ChangeNotifier {
  final ApiService _apiService;
  final BuildContext context;

  // State
  List<Brand> _brands = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  List<Car> _cars = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  ManufacturerProvider({
    required SharedPreferences prefs,
    required this.context,
  }) : _apiService = ApiService(prefs: prefs) {
    _initializeData();
  }

  // Getters
  List<Brand> get brands => _brands;
  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;
  List<Car> get cars => _cars;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get manufacturerId => Provider.of<AuthProvider>(context, listen: false).currentUser?.id.toString() ?? '';

  // Products by status
  List<Product> get activeProducts => _products.where((p) => p.isActive).toList();
  List<Product> get inactiveProducts => _products.where((p) => !p.isActive).toList();

  // Helper methods
  List<Subcategory> getSubcategories(int categoryId) {
    return _subcategories.where((s) => s.categoryId == categoryId).toList();
  }

  // Orders by status
  List<Order> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<Order> get processingOrders => _orders.where((o) => o.status == OrderStatus.processing).toList();
  List<Order> get shippedOrders => _orders.where((o) => o.status == OrderStatus.shipped).toList();
  List<Order> get deliveredOrders => _orders.where((o) => o.status == OrderStatus.delivered).toList();

  // Analytics
  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, order) => sum + order.total);

  int get totalOrders => _orders.length;

  int get lowStockProducts => _products
      .where((p) => p.stockQuantity < 10 && p.isActive)
      .length;

  // Product methods
  Future<void> addProduct({
    required Product product,
    required List<File> images,
    File? technicalSpecificationPdf,  // Added PDF parameter
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload PDF if provided
      String? pdfUrl;
      if (technicalSpecificationPdf != null) {
        final bytes = await technicalSpecificationPdf.readAsBytes();
        final filename = technicalSpecificationPdf.path.split('/').last;
        pdfUrl = await _apiService.uploadFile(
          bytes,
          filename,
          'application/pdf',
        );
      }

      // Upload images
      final imageUrls = await Future.wait(
        images.map((file) async {
          final bytes = await file.readAsBytes();
          final filename = file.path.split('/').last;
          return _apiService.uploadFile(
            bytes,
            filename,
            'image/${filename.split('.').last}',
          );
        }),
      );

      // Create product with uploaded files
      final productToCreate = product.copyWith(
        images: imageUrls,
        technicalSpecificationPdf: pdfUrl,  // Add PDF URL to product
      );

      final response = await _apiService.createProduct(productToCreate.toJson());
      final newProduct = Product.fromJson(response);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.updateProduct(product.id!, product.toJson());
      final updatedProduct = Product.fromJson(response);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProductStock(String? productId, int newQuantity) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (productId == null) {
        throw Exception('Product ID is required');
      }

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = _products[index].copyWith(stockQuantity: newQuantity);
        final response = await _apiService.updateProduct(productId, updatedProduct.toJson());
        _products[index] = Product.fromJson(response);
      } else {
        throw Exception('Product not found');
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.updateOrderStatus(
        orderId,
        newStatus.toString().split('.').last,
      );
      final updatedOrder = Order.fromJson(response);
      final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh methods
  Future<void> refreshProducts() => _fetchProducts();
  Future<void> refreshOrders() => _fetchOrders();
  Future<void> refreshBrands() => _fetchBrands();
  Future<void> refreshCategories() => _fetchCategories();
  Future<void> refreshSubcategories() => _fetchSubcategories();
  Future<void> refreshCars() => _fetchCars();

  // Private fetch methods
  Future<void> _initializeData() async {
    await Future.wait([
      _fetchBrands(),
      _fetchCategories(),
      _fetchSubcategories(),
      _fetchCars(),
      _fetchProducts(),
      _fetchOrders(),
    ]);
  }

  Future<void> _fetchBrands() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final brandsData = await _apiService.getBrands();
      _brands = brandsData.map((json) => Brand.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final categoriesData = await _apiService.getCategories();
      _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSubcategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subcategoriesData = await _apiService.getSubcategories();
      _subcategories = subcategoriesData.map((json) => Subcategory.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCars() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final carsData = await _apiService.getCars();
      _cars = carsData.map((json) => Car.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final productsData = await _apiService.getProducts();
      _products = productsData.map((json) => Product.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ordersData = await _apiService.getOrders();
      _orders = ordersData.map((json) => Order.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
