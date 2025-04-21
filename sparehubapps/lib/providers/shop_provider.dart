import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/brand.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  List<Brand> _brands = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Filter states
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 100000);
  List<String> _selectedCategories = [];
  List<String> _selectedBrands = [];
  String _sortBy = 'name';
  bool _sortAscending = true;

  ShopProvider(this._apiService) {
    _initializeData();
  }

  // Getters
  List<Product> get products => _filterAndSortProducts();
  List<Brand> get brands => _brands;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedBrands => _selectedBrands;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  Future<void> _initializeData() async {
    await Future.wait([
      refreshProducts(),
      refreshBrands(),
      refreshCategories(),
    ]);
  }

  Future<void> refreshProducts() async {
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

  Future<void> refreshBrands() async {
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

  Future<void> refreshCategories() async {
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

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setSelectedBrands(List<String> brands) {
    _selectedBrands = brands;
    notifyListeners();
  }

  void setSortBy(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    }
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _priceRange = const RangeValues(0, 100000);
    _selectedCategories = [];
    _selectedBrands = [];
    _sortBy = 'name';
    _sortAscending = true;
    notifyListeners();
  }

  List<Product> _filterAndSortProducts() {
    List<Product> filteredProducts = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = Product.searchProducts(filteredProducts, _searchQuery);
    }

    // Apply price range filter
    filteredProducts = Product.filterByPriceRange(
      filteredProducts,
      _priceRange.start,
      _priceRange.end,
    );

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return _selectedCategories.contains(product.categoryId.toString());
      }).toList();
    }

    // Apply brand filter
    if (_selectedBrands.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.brandId != null &&
            _selectedBrands.contains(product.brandId.toString());
      }).toList();
    }

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

    return filteredProducts;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
