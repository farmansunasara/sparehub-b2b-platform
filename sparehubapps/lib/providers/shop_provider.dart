import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Brand> _brands = [];
  List<Category> _categories = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  static const int _pageSize = 20;

  // Filter states
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 100000);
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];
  String _stockStatus = 'all'; // 'all', 'in_stock', 'low_stock', 'out_of_stock'
  String _sortBy = 'name';
  bool _sortAscending = true;

  ShopProvider(this._apiService) {
    _initializeData();
  }

  // Getters
  List<Product> get products => _filterAndSortProducts();
  List<Product> get featuredProducts => _featuredProducts;
  List<Brand> get brands => _brands;
  List<Category> get categories => _categories;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreProducts => _hasMoreProducts;

  // Filter getters
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedBrands => _selectedBrands;
  String get stockStatus => _stockStatus;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  Future<void> _initializeData() async {
    try {
      _setLoading(true);
      // Fetch critical data sequentially to avoid _isLoading conflicts
      await refreshCategories();
      await refreshFeaturedProducts();
      await refreshOrders();
      await refreshProducts(); // Immediate fetch
      await refreshBrands();
    } catch (e) {
      print('Initialization error: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProducts({bool reset = false}) async {
    if (!_hasMoreProducts) {
      print('Skipping refreshProducts: hasMoreProducts=false');
      return;
    }
    if (reset) {
      _products = [];
      _currentPage = 1;
      _hasMoreProducts = true;
    }
    try {
      _setLoading(true);
      _error = null;

      print('Fetching products: page=$_currentPage, pageSize=$_pageSize');
      final productsData = await _apiService.getProducts(page: _currentPage, pageSize: _pageSize);
      print('Products API response: $productsData');
      
      if (productsData['results'] == null || productsData['results'] is! List) {
        print('Invalid products response: results is null or not a list');
        _hasMoreProducts = false;
        return;
      }

      final newProducts = await compute(_parseProducts, productsData['results'] as List<dynamic>);
      print('Parsed ${newProducts.length} new products');
      _products = reset ? newProducts : [..._products, ...newProducts];
      _hasMoreProducts = productsData['next'] != null;
      _currentPage++;
    } catch (e) {
      print('Error fetching products: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  static List<Product> _parseProducts(List<dynamic> productsData) {
    return productsData.map((json) {
      try {
        return Product.fromJson(json);
      } catch (e) {
        print('Error parsing product: $e, json: $json');
        rethrow;
      }
    }).toList();
  }

  Future<void> refreshFeaturedProducts() async {
    try {
      _setLoading(true);
      _error = null;

      print('Fetching featured products');
      final productsData = await _apiService.getFeaturedProducts();
      print('Featured products response: $productsData');
      _featuredProducts = await compute(_parseProducts, productsData);
    } catch (e) {
      print('Error fetching featured products: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshBrands() async {
    try {
      _setLoading(true);
      _error = null;

      print('Fetching brands');
      final brandsData = await _apiService.getBrands();
      print('Brands response: $brandsData');
      _brands = brandsData.map((json) => Brand.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching brands: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCategories() async {
    try {
      _setLoading(true);
      _error = null;

      print('Fetching categories');
      final categoriesData = await _apiService.getCategories();
      print('Categories response: $categoriesData');
      _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshOrders() async {
    try {
      _setLoading(true);
      _error = null;

      print('Fetching orders');
      final ordersData = await _apiService.getShopOrders(limit: 5);
      print('Orders response: $ordersData');
      _orders = ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    print('Set search query: $_searchQuery');
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    print('Set price range: ${_priceRange.start} - ${_priceRange.end}');
    notifyListeners();
  }

  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    print('Set selected categories: $_selectedCategories');
    notifyListeners();
  }

  void setSelectedBrands(List<String> brands) {
    _selectedBrands = brands;
    print('Set selected brands: $_selectedBrands');
    notifyListeners();
  }

  void setStockStatus(String status) {
    _stockStatus = status;
    print('Set stock status: $_stockStatus');
    notifyListeners();
  }

  void setSortBy(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    }
    print('Set sort by: $_sortBy, ascending: $_sortAscending');
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _priceRange = const RangeValues(0, 100000);
    _selectedCategories = [];
    _selectedBrands = [];
    _stockStatus = 'all';
    _sortBy = 'name';
    _sortAscending = true;
    print('Filters reset');
    notifyListeners();
  }

  List<Product> _filterAndSortProducts() {
    List<Product> filteredProducts = List.from(_products);
    print('Filtering products: raw count=${_products.length}');

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = Product.searchProducts(filteredProducts, _searchQuery);
      print('After search filter: ${filteredProducts.length} products');
    }

    // Apply price range filter
    filteredProducts = Product.filterByPriceRange(
      filteredProducts,
      _priceRange.start,
      _priceRange.end,
    );
    print('After price filter: ${filteredProducts.length} products');

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.categoryId != null &&
            _selectedCategories.contains(product.categoryId.toString());
      }).toList();
      print('After category filter: ${filteredProducts.length} products');
    }

    // Apply brand filter
    if (_selectedBrands.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.brandId != null &&
            _selectedBrands.contains(product.brandId.toString());
      }).toList();
      print('After brand filter: ${filteredProducts.length} products');
    }

    // Apply stock status filter
    switch (_stockStatus) {
      case 'in_stock':
        filteredProducts = filteredProducts.where((product) => !product.isOutOfStock && !product.isLowStock).toList();
        break;
      case 'low_stock':
        filteredProducts = filteredProducts.where((product) => product.isLowStock).toList();
        break;
      case 'out_of_stock':
        filteredProducts = filteredProducts.where((product) => product.isOutOfStock).toList();
        break;
    }
    print('After stock status filter: ${filteredProducts.length} products');

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filteredProducts = Product.sortByName(
          filteredProducts,
          ascending: _sortAscending,
        );
        break;
      case 'price':
        filteredProducts = Product.sortByPrice(
          filteredProducts,
          ascending: _sortAscending,
        );
        break;
      case 'newest':
        filteredProducts.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return _sortAscending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        });
        break;
    }
    print('After sorting: ${filteredProducts.length} products');

    return filteredProducts;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}