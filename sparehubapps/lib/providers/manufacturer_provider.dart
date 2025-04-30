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
import 'package:logger/logger.dart';

class ValidationError implements Exception {
  final String message;
  const ValidationError(this.message);
  @override
  String toString() => message;
}

class ManufacturerProvider with ChangeNotifier {
  final ApiService _apiService;
  final BuildContext context;
  final Logger _logger = Logger();

  List<Brand> _brands = [];
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  Map<String, dynamic>? _manufacturerProfile;
  List<dynamic>? _analytics;
  bool _isLoading = false;
  String? _error;

  ManufacturerProvider({
    required SharedPreferences prefs,
    required this.context,
  }) : _apiService = ApiService(prefs: prefs) {
    _initializeData();
  }

  List<Brand> get brands => _brands;
  List<Category> get categories => _categories;
  List<Subcategory> get subcategories => _subcategories;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  Map<String, dynamic>? get manufacturerProfile => _manufacturerProfile;
  List<dynamic>? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get manufacturerId => Provider.of<AuthProvider>(context, listen: false).currentUser?.id.toString() ?? '';

  List<Product> get activeProducts => _products.where((p) => p.isActive).toList();
  List<Product> get inactiveProducts => _products.where((p) => !p.isActive).toList();

  List<Subcategory> getSubcategories(int categoryId) {
    return _subcategories.where((s) => s.categoryId == categoryId).toList();
  }

  List<Order> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<Order> get processingOrders => _orders.where((o) => o.status == OrderStatus.processing).toList();
  List<Order> get shippedOrders => _orders.where((o) => o.status == OrderStatus.shipped).toList();
  List<Order> get deliveredOrders => _orders.where((o) => o.status == OrderStatus.delivered).toList();

  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled && o.status != OrderStatus.returned)
      .fold(0.0, (sum, order) => sum + order.total);

  int get totalOrders => _orders.length;

  int get lowStockProducts => _products
      .where((p) => p.stockQuantity < 10 && p.isActive)
      .length;

  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<List<http.MultipartFile>> _prepareFiles(List<File> images, File? technicalPdf, File? installationPdf) async {
    final List<http.MultipartFile> files = [];

    for (var image in images) {
      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

      files.add(http.MultipartFile.fromBytes(
        'images',
        bytes,
        filename: image.path.split('/').last,
        contentType: MediaType.parse(contentType),
      ));
    }

    if (technicalPdf != null) {
      final bytes = await technicalPdf.readAsBytes();
      files.add(http.MultipartFile.fromBytes(
        'technical_specification_pdf',
        bytes,
        filename: technicalPdf.path.split('/').last,
        contentType: MediaType.parse('application/pdf'),
      ));
    }

    if (installationPdf != null) {
      final bytes = await installationPdf.readAsBytes();
      files.add(http.MultipartFile.fromBytes(
        'installation_guide_pdf',
        bytes,
        filename: installationPdf.path.split('/').last,
        contentType: MediaType.parse('application/pdf'),
      ));
    }

    return files;
  }

  Future<void> addProduct({
    required Product product,
    required List<File> images,
    File? technicalSpecificationPdf,
    File? installationGuidePdf,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      if (product.name.isEmpty) throw ValidationError('Product name is required');
      if (product.sku.isEmpty) throw ValidationError('SKU is required');
      if (product.categoryId == 0) throw ValidationError('Category is required');
      if (product.subcategoryId == 0) throw ValidationError('Subcategory is required');
      if (images.isEmpty) throw ValidationError('At least one product image is required');

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

      final productData = product.toJson();
      productData['manufacturer'] = manufacturerId;
      productData['category_id'] = product.categoryId.toString();
      productData['subcategory_id'] = product.subcategoryId.toString();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/products/'),
      );

      productData.forEach((key, value) {
        if (value != null) {
          if (key == 'images') return;
          if (key == 'compatible_car_ids') {
            request.fields[key] = json.encode(value ?? []);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      _logger.i('Sending multipart request with fields: ${request.fields}');

      final files = await _prepareFiles(images, technicalSpecificationPdf, installationGuidePdf);
      request.files.addAll(files);

      final response = await _apiService.sendMultipartRequest(request);

      try {
        final newProduct = Product.fromJson(response);
        _products.add(newProduct);
        _safeNotifyListeners();
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse product data: ${e.toString()}',
          statusCode: 500,
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is ValidationError) {
        errorMessage = e.message;
      } else if (e is ApiException) {
        errorMessage = e.message;
        if (e.statusCode == 401) {
          errorMessage = 'Authentication failed. Please log in again.';
          Provider.of<AuthProvider>(context, listen: false).logout();
        } else if (e.statusCode == 400) {
          try {
            final errorData = jsonDecode(e.message.split('Response Body: ')[1]);
            if (errorData is Map<String, dynamic>) {
              final errors = <String>[];
              errorData.forEach((key, value) {
                if (key == 'non_field_errors') {
                  errors.add(value is List ? value.join('; ') : value.toString());
                } else {
                  errors.add('$key: ${value is List ? value.join('; ') : value}');
                }
              });
              errorMessage = errors.join('; ');
            }
          } catch (_) {
            errorMessage = 'Invalid product data. Please check all fields.';
          }
        }
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _error = errorMessage;
      _logger.e('Error adding product: $_error\nDetails: $e');
      _safeNotifyListeners();
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
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
      _safeNotifyListeners();

      if (product.id == null) throw ValidationError('Product ID is required');
      if (product.name.isEmpty) throw ValidationError('Product name is required');
      if (product.sku.isEmpty) throw ValidationError('SKU is required');
      if (product.categoryId == 0) throw ValidationError('Category is required');
      if (product.subcategoryId == 0) throw ValidationError('Subcategory is required');

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

      final productData = product.toJson();
      productData['manufacturer'] = manufacturerId;
      productData['category_id'] = product.categoryId.toString();
      productData['subcategory_id'] = product.subcategoryId.toString();

      if (images != null || technicalSpecificationPdf != null || installationGuidePdf != null) {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('${ApiService.baseUrl}/products/${product.id}/'),
        );

        productData.forEach((key, value) {
          if (key == 'images') return;
          if (key == 'compatible_car_ids') {
            request.fields[key] = json.encode(value ?? []);
          } else if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        _logger.i('Sending multipart request with fields: ${request.fields}');

        final files = await _prepareFiles(
          images ?? [],
          technicalSpecificationPdf,
          installationGuidePdf,
        );
        request.files.addAll(files);

        final response = await _apiService.sendMultipartRequest(request);

        try {
          final updatedProduct = Product.fromJson(response);
          final index = _products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _products[index] = updatedProduct;
          }
          _safeNotifyListeners();
        } catch (e) {
          throw ApiException(
            message: 'Failed to parse product data: ${e.toString()}',
            statusCode: 500,
          );
        }
      } else {
        final response = await _apiService.updateProduct(product.id!, productData);
        final updatedProduct = Product.fromJson(response);
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
        _safeNotifyListeners();
      }
    } catch (e) {
      String errorMessage;
      if (e is ValidationError) {
        errorMessage = e.message;
      } else if (e is ApiException) {
        errorMessage = e.message;
        if (e.statusCode == 401) {
          errorMessage = 'Authentication failed. Please log in again.';
          Provider.of<AuthProvider>(context, listen: false).logout();
        } else if (e.statusCode == 400) {
          try {
            final errorData = jsonDecode(e.message.split('Response Body: ')[1]);
            if (errorData is Map<String, dynamic>) {
              final errors = <String>[];
              errorData.forEach((key, value) {
                if (key == 'non_field_errors') {
                  errors.add(value is List ? value.join('; ') : value.toString());
                } else {
                  errors.add('$key: ${value is List ? value.join('; ') : value}');
                }
              });
              errorMessage = errors.join('; ');
            }
          } catch (_) {
            errorMessage = 'Invalid product data. Please check all fields.';
          }
        }
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _error = errorMessage;
      _logger.e('Error updating product: $_error\nDetails: $e');
      _safeNotifyListeners();
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateProductStock(String? productId, int newQuantity) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

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
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error updating product stock: $e');
      _safeNotifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final response = await _apiService.updateOrderStatus(
        orderId,
        newStatus.toString().split('.').last,
      );
      final updatedOrder = Order.fromJson(response);
      final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error updating order status: $e');
      _safeNotifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      await _apiService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error deleting product: $e');
      _safeNotifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> getManufacturerProfile() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final response = await _apiService.getUserProfile();
      _manufacturerProfile = response;
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching manufacturer profile: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final response = await _apiService.getAnalytics();
      _analytics = response;
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching analytics: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  Future<void> refreshProducts() => _fetchProducts();
  Future<void> refreshOrders() => _fetchOrders();
  Future<void> refreshBrands() => _fetchBrands();
  Future<void> refreshCategories() => _fetchCategories();
  Future<void> refreshSubcategories({int? categoryId}) => _fetchSubcategories(categoryId: categoryId);

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchBrands(),
      _fetchCategories(),
      _fetchSubcategories(),
      _fetchProducts(),
      _fetchOrders(),
      getManufacturerProfile(),
      refreshAnalytics(),
    ]);
  }

  Future<void> _fetchBrands() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final brandsData = await _apiService.getBrands();
      _brands = brandsData.map((json) => Brand.fromJson(json)).toList();
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching brands: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final categoriesData = await _apiService.getCategories();
      _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching categories: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _fetchSubcategories({int? categoryId}) async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final subcategoriesData = await _apiService.getSubcategories(categoryId: categoryId);
      _subcategories = subcategoriesData.map((json) => Subcategory.fromJson(json)).toList();
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching subcategories: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final productsData = await _apiService.getProducts();
      _products = (productsData['results'] as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching products: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _fetchOrders() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final ordersData = await _apiService.getOrders();
      _orders = ordersData.map((json) => Order.fromJson(json)).toList();
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _logger.e('Error fetching orders: $e');
      _safeNotifyListeners();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }
}