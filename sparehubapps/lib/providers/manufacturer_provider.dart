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
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    File? technicalSpecificationPdf,
    File? installationGuidePdf,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Prepare product data
      final productData = product.toJson();
      print('Product Data: $productData');
      // Validate and log compatible_car_ids
      final compatibleCarIds = productData['compatible_car_ids'] as List<dynamic>? ?? [];
      print('Compatible Car IDs: $compatibleCarIds');
      for (var id in compatibleCarIds) {
        if (id is! int) {
          throw Exception('Invalid compatible_car_id: $id is not an integer');
        }
      }

      print('Images: ${images.map((file) => file.path).toList()}');
      print('Technical PDF: ${technicalSpecificationPdf?.path}');
      print('Installation PDF: ${installationGuidePdf?.path}');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/products/'),
      );

      // Add product fields
      productData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            request.fields[key] = json.encode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add images
      for (var image in images) {
        final stream = http.ByteStream(image.openRead());
        final length = await image.length();
        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Add PDFs
      if (technicalSpecificationPdf != null) {
        final stream = http.ByteStream(technicalSpecificationPdf.openRead());
        final length = await technicalSpecificationPdf.length();
        final multipartFile = http.MultipartFile(
          'technical_specification_pdf',
          stream,
          length,
          filename: technicalSpecificationPdf.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      if (installationGuidePdf != null) {
        final stream = http.ByteStream(installationGuidePdf.openRead());
        final length = await installationGuidePdf.length();
        final multipartFile = http.MultipartFile(
          'installation_guide_pdf',
          stream,
          length,
          filename: installationGuidePdf.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send request using ApiService
      final response = await _apiService.sendMultipartRequest(request);

      final newProduct = Product.fromJson(response);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error adding product: $e');
      if (e is ApiException && e.statusCode == 401) {
        _error = 'Authentication failed. Please log in again.';
      }
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
      print('Error updating product: $e');
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
      print('Error updating product stock: $e');
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
      print('Error updating order status: $e');
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
      print('Error deleting product: $e');
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
  Future<void> refreshSubcategories({int? categoryId}) => _fetchSubcategories(categoryId: categoryId);
  Future<void> refreshCars() => _fetchCars();

  // Private fetch methods
  Future<void> _initializeData() async {
    await Future.wait([
      _fetchBrands(),
      _fetchCategories(),
      _fetchSubcategories(),
      _fetchCars(),
      _fetchProducts(),
      // _fetchOrders(), // Commented out to avoid 404 error
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
      print('Error fetching brands: $e');
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
      print('Error fetching categories: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSubcategories({int? categoryId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subcategoriesData = await _apiService.getSubcategories(categoryId: categoryId);
      _subcategories = subcategoriesData.map((json) => Subcategory.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error fetching subcategories: $e');
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
      print('Error fetching cars: $e');
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
      print('Error fetching products: $e');
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
      print('Error fetching orders: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}