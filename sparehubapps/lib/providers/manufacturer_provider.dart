import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import 'auth_provider.dart';

// Custom exception for validation errors
class ValidationError implements Exception {
  final String message;
  const ValidationError(this.message);
  @override
  String toString() => message;
}

class ManufacturerProvider with ChangeNotifier {
  final ApiService _apiService;
  final BuildContext context;

  // State
  List<Brand> _brands = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
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

      // Validate required fields
      if (product.name.isEmpty) throw ValidationError('Product name is required');
      if (product.sku.isEmpty) throw ValidationError('SKU is required');
      if (product.categoryId == null) throw ValidationError('Category is required');
      if (product.subcategoryId == null) throw ValidationError('Subcategory is required');
      if (images.isEmpty) throw ValidationError('At least one product image is required');

      // Validate file types
      for (var image in images) {
        final ext = image.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
          throw ValidationError('Invalid image format. Allowed formats: JPG, PNG, WEBP');
        }
      }

      if (technicalSpecificationPdf != null && !technicalSpecificationPdf.path.toLowerCase().endsWith('.pdf')) {
        throw ValidationError('Technical specification must be a PDF file');
      }

      if (installationGuidePdf != null && !installationGuidePdf.path.toLowerCase().endsWith('.pdf')) {
        throw ValidationError('Installation guide must be a PDF file');
      }

      // Prepare product data
      final productData = product.toJson();
      productData['manufacturer'] = manufacturerId;

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/products/'),
      );

      // Add product fields
      productData.forEach((key, value) {
        if (key == 'compatible_car_ids') {
          // Always include compatible_car_ids as an empty list if not provided
          request.fields[key] = json.encode(value ?? []);
        } else if (value != null) {
          if (value is List) {
            request.fields[key] = json.encode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add images with proper content type
      for (var image in images) {
        final stream = http.ByteStream(image.openRead());
        final length = await image.length();
        final ext = image.path.split('.').last.toLowerCase();
        final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
        
        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.path.split('/').last,
          contentType: MediaType.parse(contentType),
        );
        request.files.add(multipartFile);
      }

      // Add PDFs with proper content type
      if (technicalSpecificationPdf != null) {
        final stream = http.ByteStream(technicalSpecificationPdf.openRead());
        final length = await technicalSpecificationPdf.length();
        final multipartFile = http.MultipartFile(
          'technical_specification_pdf',
          stream,
          length,
          filename: technicalSpecificationPdf.path.split('/').last,
          contentType: MediaType.parse('application/pdf'),
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
          contentType: MediaType.parse('application/pdf'),
        );
        request.files.add(multipartFile);
      }

      // Send request and handle response
      final response = await _apiService.sendMultipartRequest(request);
      
      if (response == null) {
        throw ApiException(message: 'No response from server', statusCode: 500);
      }

      try {
        final newProduct = Product.fromJson(response);
        _products.add(newProduct);
        notifyListeners();
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse product data: ${e.toString()}',
          statusCode: 500
        );
      }

    } catch (e) {
      if (e is ValidationError) {
        _error = e.message;
      } else if (e is ApiException) {
        _error = e.message;
        if (e.statusCode == 401) {
          _error = 'Authentication failed. Please log in again.';
          // Notify auth provider about token expiration
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
      } else {
        _error = 'An unexpected error occurred. Please try again.';
      }
      print('Error adding product: $_error\nDetails: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateProduct({
    required Product product,
    List<File>? images,
    File? technicalSpecificationPdf,
    File? installationGuidePdf,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate required fields
      if (product.id == null) throw ValidationError('Product ID is required');
      if (product.name.isEmpty) throw ValidationError('Product name is required');
      if (product.sku.isEmpty) throw ValidationError('SKU is required');
      if (product.categoryId == null) throw ValidationError('Category is required');
      if (product.subcategoryId == null) throw ValidationError('Subcategory is required');

      // Validate file types if provided
      if (images != null) {
        for (var image in images) {
          final ext = image.path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
            throw ValidationError('Invalid image format. Allowed formats: JPG, PNG, WEBP');
          }
        }
      }

      if (technicalSpecificationPdf != null && !technicalSpecificationPdf.path.toLowerCase().endsWith('.pdf')) {
        throw ValidationError('Technical specification must be a PDF file');
      }

      if (installationGuidePdf != null && !installationGuidePdf.path.toLowerCase().endsWith('.pdf')) {
        throw ValidationError('Installation guide must be a PDF file');
      }

      // Prepare product data
      final productData = product.toJson();
      productData['manufacturer'] = manufacturerId;

      // Create multipart request for file uploads
      if (images != null || technicalSpecificationPdf != null || installationGuidePdf != null) {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('${ApiService.baseUrl}/products/${product.id}/'),
        );

      // Add product fields
      productData.forEach((key, value) {
        if (key == 'compatible_car_ids') {
          // Always include compatible_car_ids as an empty list if not provided
          request.fields[key] = json.encode(value ?? []);
        } else if (value != null) {
          if (value is List) {
            request.fields[key] = json.encode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

        // Add images with proper content type if provided
        if (images != null) {
          for (var image in images) {
            final stream = http.ByteStream(image.openRead());
            final length = await image.length();
            final ext = image.path.split('.').last.toLowerCase();
            final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
            
            final multipartFile = http.MultipartFile(
              'images',
              stream,
              length,
              filename: image.path.split('/').last,
              contentType: MediaType.parse(contentType),
            );
            request.files.add(multipartFile);
          }
        }

        // Add PDFs with proper content type if provided
        if (technicalSpecificationPdf != null) {
          final stream = http.ByteStream(technicalSpecificationPdf.openRead());
          final length = await technicalSpecificationPdf.length();
          final multipartFile = http.MultipartFile(
            'technical_specification_pdf',
            stream,
            length,
            filename: technicalSpecificationPdf.path.split('/').last,
            contentType: MediaType.parse('application/pdf'),
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
            contentType: MediaType.parse('application/pdf'),
          );
          request.files.add(multipartFile);
        }

        // Send multipart request and handle response
        final response = await _apiService.sendMultipartRequest(request);
        
        if (response == null) {
          throw ApiException(message: 'No response from server', statusCode: 500);
        }

        try {
          final updatedProduct = Product.fromJson(response);
          final index = _products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _products[index] = updatedProduct;
          }
          notifyListeners();
        } catch (e) {
          throw ApiException(
            message: 'Failed to parse product data: ${e.toString()}',
            statusCode: 500
          );
        }
      } else {
        // If no files to upload, use regular update
        final response = await _apiService.updateProduct(product.id!, productData);
        final updatedProduct = Product.fromJson(response);
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
        notifyListeners();
      }

    } catch (e) {
      if (e is ValidationError) {
        _error = e.message;
      } else if (e is ApiException) {
        _error = e.message;
        if (e.statusCode == 401) {
          _error = 'Authentication failed. Please log in again.';
          // Notify auth provider about token expiration
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
      } else {
        _error = 'An unexpected error occurred. Please try again.';
      }
      print('Error updating product: $_error\nDetails: $e');
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

  // Private fetch methods
  Future<void> _initializeData() async {
    await Future.wait([
      _fetchBrands(),
      _fetchCategories(),
      _fetchSubcategories(),
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
