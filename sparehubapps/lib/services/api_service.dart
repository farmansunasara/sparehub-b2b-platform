import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static String get baseUrl => _baseUrl;
  static const String _baseUrl = 'http://192.168.26.2:8000/api';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  final http.Client _client;
  final SharedPreferences _prefs;
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  final _storage = const FlutterSecureStorage();

  ApiService({
    required SharedPreferences prefs,
    http.Client? client,
  })  : _prefs = prefs,
        _client = client ?? http.Client();

  Future<String?> get authToken => _storage.read(key: _tokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    final token = await authToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      _logger.i('Using access token: $token');
    } else {
      _logger.w('No access token available');
    }
    return headers;
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<bool> _hasValidTokens() async {
    final token = await authToken;
    final refreshToken = await this.refreshToken;
    return token != null && refreshToken != null;
  }

  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final currentRefreshToken = await refreshToken;
      _logger.i('Checking refresh token availability...');

      if (currentRefreshToken == null) {
        _logger.e('No refresh token found in storage');
        throw ApiException(message: 'Authentication required', statusCode: 401);
      }

      _logger.i('Attempting to refresh token...');
      final response = await _client.post(
        Uri.parse('$_baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': currentRefreshToken}),
      );

      _logger.i('Refresh token response status: ${response.statusCode}');

      dynamic responseBody;
      try {
        responseBody = json.decode(response.body);
        if (responseBody is! Map<String, dynamic>) {
          _logger.e('Unexpected response type: ${responseBody.runtimeType}');
          throw ApiException(message: 'Authentication required', statusCode: 401);
        }
      } catch (e) {
        _logger.e('Failed to parse refresh token response: ${response.body}');
        throw ApiException(message: 'Authentication required', statusCode: 401);
      }

      if (response.statusCode == 200) {
        if (responseBody['access'] != null) {
          await setAuthToken(responseBody['access'].toString());
          _logger.i('Successfully stored new access token');
        } else {
          _logger.e('No access token in refresh response: $responseBody');
          throw ApiException(message: 'Authentication required', statusCode: 401);
        }
        if (responseBody['refresh'] != null) {
          await setRefreshToken(responseBody['refresh'].toString());
          _logger.i('Successfully stored new refresh token');
        }
        return responseBody;
      } else {
        _logger.e('Token refresh failed with status: ${response.statusCode}, body: $responseBody');
        throw ApiException(message: responseBody['detail'] ?? 'Authentication required', statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Token refresh failed with error: $e');
      await clearTokens();
      throw ApiException(message: 'Authentication required', statusCode: 401);
    }
  }

  Future<T> _handleResponse<T>(
      Future<http.Response> Function(Map<String, String> headers) request) async {
    try {
      if (!await _checkConnectivity()) {
        _logger.w('No internet connection');
        throw ApiException(message: 'No internet connection', statusCode: 503);
      }

      final headers = await _getHeaders();
      final response = await request(headers);

      if (response.headers['content-type']?.contains('text/html') ?? false) {
        _logger.e('Server returned HTML instead of JSON: ${response.body}');
        throw ApiException(message: 'Server error occurred', statusCode: response.statusCode);
      }

      dynamic body;
      try {
        body = json.decode(response.body);
        if (body is! Map<String, dynamic> && body is! List) {
          _logger.e('Unexpected response type: ${body.runtimeType}');
          throw ApiException(message: 'Invalid response format', statusCode: response.statusCode);
        }
      } catch (e) {
        _logger.e('Failed to parse JSON response: $e\nResponse: ${response.body}');
        throw ApiException(message: 'Invalid response format', statusCode: response.statusCode);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger.i('API Success: ${response.request?.url}');
        return body as T;
      }

      if (response.statusCode == 401) {
        if (await _hasValidTokens()) {
          _logger.w('Token expired, attempting refresh');
          try {
            await refreshAccessToken();
            return _handleResponse(request);
          } catch (e) {
            _logger.e('Token refresh failed: $e');
            await clearTokens();
            throw ApiException(message: 'Authentication required', statusCode: 401);
          }
        } else {
          _logger.i('No valid tokens for refresh');
          throw ApiException(message: 'Authentication required', statusCode: 401);
        }
      }

      _logger.e('API Error: ${response.statusCode} - Response Body: ${response.body}');
      String errorMessage = 'Something went wrong';
      if (body is Map<String, dynamic>) {
        if (body.containsKey('message') || body.containsKey('error') || body.containsKey('detail')) {
          errorMessage = body['message'] ?? body['error'] ?? body['detail'] ?? errorMessage;
        } else {
          errorMessage = body.entries
              .map((e) => '${e.key}: ${e.value is List ? e.value.join(", ") : e.value}')
              .join('; ');
        }
      }
      throw ApiException(message: errorMessage, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) {
        _logger.e('API Exception: ${e.message}');
        rethrow;
      }
      _logger.e('Unexpected Error: $e');
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Map<String, dynamic>> sendMultipartRequest(http.MultipartRequest request) async {
    try {
      if (!await _checkConnectivity()) {
        _logger.w('No internet connection');
        throw ApiException(message: 'No internet connection', statusCode: 503);
      }

      final token = await authToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      _logger.i('Multipart Request Fields: ${request.fields}');
      _logger.i('Multipart Request Files: ${request.files.map((file) => file.filename).toList()}');
      _logger.i('Multipart Request URL: ${request.url}');
      _logger.i('Multipart Request Headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.headers['content-type']?.contains('text/html') ?? false) {
        _logger.e('Server returned HTML instead of JSON: ${response.body}');
        throw ApiException(message: 'Server error occurred', statusCode: response.statusCode);
      }

      dynamic body;
      try {
        body = json.decode(response.body);
        if (body is! Map<String, dynamic> && body is! List) {
          _logger.e('Unexpected response type: ${body.runtimeType}');
          throw ApiException(message: 'Invalid response format', statusCode: response.statusCode);
        }
      } catch (e) {
        _logger.e('Failed to parse JSON response: $e\nResponse: ${response.body}');
        throw ApiException(message: 'Invalid response format', statusCode: response.statusCode);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger.i('API Success: ${request.url}');
        return body as Map<String, dynamic>;
      }

      if (response.statusCode == 401) {
        if (await _hasValidTokens()) {
          _logger.w('Token expired, attempting refresh');
          try {
            await refreshAccessToken();
            final newToken = await authToken;
            if (newToken != null) {
              request.headers['Authorization'] = 'Bearer $newToken';
            }
            final retryResponse = await request.send();
            final retryResult = await http.Response.fromStream(retryResponse);
            final retryBody = json.decode(retryResult.body);
            if (retryResult.statusCode >= 200 && retryResult.statusCode < 300) {
              return retryBody as Map<String, dynamic>;
            }
            throw ApiException(message: 'Retry failed', statusCode: retryResult.statusCode);
          } catch (e) {
            _logger.e('Token refresh failed: $e');
            await clearTokens();
            throw ApiException(message: 'Authentication required', statusCode: 401);
          }
        } else {
          _logger.i('No valid tokens for refresh');
          throw ApiException(message: 'Authentication required', statusCode: 401);
        }
      }

      _logger.e('API Error: ${response.statusCode} - Response Body: ${response.body}');
      String errorMessage = 'Something went wrong';
      if (body is Map<String, dynamic>) {
        if (body.containsKey('message') || body.containsKey('error') || body.containsKey('detail')) {
          errorMessage = body['message'] ?? body['error'] ?? body['detail'] ?? errorMessage;
        } else {
          errorMessage = body.entries
              .map((e) => '${e.key}: ${e.value is List ? e.value.join(", ") : e.value}')
              .join('; ');
        }
      }
      throw ApiException(message: errorMessage, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) {
        _logger.e('API Exception: ${e.message}');
        rethrow;
      }
      _logger.e('Unexpected Error: $e');
      throw ApiException(message: e.toString(), statusCode: 500);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.i('Attempting login for user: $email');

    final response = await _handleResponse<Map<String, dynamic>>((headers) => _client.post(
          Uri.parse('$_baseUrl/users/login/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': email,
            'password': password,
          }),
        ));

    _logger.i('Login response received: $response');

    try {
      if (response['access'] == null) {
        _logger.e('No access token in response: $response');
        throw ApiException(
            message: 'Invalid login response: Missing access token', statusCode: 401);
      }
      if (response['refresh'] == null) {
        _logger.e('No refresh token in response: $response');
        throw ApiException(
            message: 'Invalid login response: Missing refresh token', statusCode: 401);
      }
      if (response['user'] == null) {
        _logger.e('No user data in response: $response');
        throw ApiException(
            message: 'Invalid login response: Missing user data', statusCode: 401);
      }

      final accessToken = response['access'].toString();
      final refreshToken = response['refresh'].toString();

      await setAuthToken(accessToken);
      _logger.i('Access token stored successfully');

      await setRefreshToken(refreshToken);
      _logger.i('Refresh token stored successfully');

      return response;
    } catch (e, stackTrace) {
      _logger.e('Error processing login response: $e\nStackTrace: $stackTrace');
      await clearTokens();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerManufacturer(Map<String, dynamic> data) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.post(
          Uri.parse('$_baseUrl/users/register-manufacturer/'),
          headers: headers,
          body: json.encode(data),
        ));
  }

  Future<Map<String, dynamic>> registerShop(Map<String, dynamic> data) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.post(
          Uri.parse('$_baseUrl/users/register-shop/'),
          headers: headers,
          body: json.encode(data),
        ));
  }

  Future<void> logout() async {
    if (await _hasValidTokens()) {
      await _handleResponse<void>((headers) => _client.post(
            Uri.parse('$_baseUrl/users/logout/'),
            headers: headers,
          ));
    }
    await clearTokens();
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _handleResponse<Map<String, dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/users/profile/'),
          headers: headers,
        ));
    _logger.i('User profile response: $response');
    return response;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _handleResponse<Map<String, dynamic>>((headers) => _client.put(
          Uri.parse('$_baseUrl/users/profile/'),
          headers: headers,
          body: json.encode(data),
        ));
    _logger.i('Update profile response: $response');
    return response;
  }

  Future<List<Map<String, dynamic>>> getBrands() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/products/brands/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/products/categories/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getSubcategories({int? categoryId}) async {
    final uri = Uri.parse('$_baseUrl/products/subcategories/').replace(
      queryParameters: categoryId != null ? {'category_id': categoryId.toString()} : null,
    );
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          uri,
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCars() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/products/cars/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/products/featured/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getShopOrders({int? limit}) async {
    final uri = Uri.parse('$_baseUrl/orders/').replace(
      queryParameters: limit != null ? {'limit': limit.toString()} : null,
    );
    final response = await _handleResponse<dynamic>((headers) => _client.get(
          uri,
          headers: headers,
        ));

    if (response is Map<String, dynamic> && response.containsKey('results')) {
      return (response['results'] as List<dynamic>).cast<Map<String, dynamic>>();
    } else if (response is List<dynamic>) {
      return response.cast<Map<String, dynamic>>();
    } else {
      _logger.e('Unexpected response type for getShopOrders: ${response.runtimeType}');
      throw ApiException(message: 'Invalid response format', statusCode: 500);
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> product) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.post(
          Uri.parse('$_baseUrl/products/'),
          headers: headers,
          body: json.encode(product),
        ));
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> product) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.put(
          Uri.parse('$_baseUrl/products/$id/'),
          headers: headers,
          body: json.encode(product),
        ));
  }

  Future<void> deleteProduct(String id) async {
    await _handleResponse<void>((headers) => _client.delete(
          Uri.parse('$_baseUrl/products/$id/'),
          headers: headers,
        ));
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/products/$id/'),
          headers: headers,
        ));
  }

  Future<Map<String, dynamic>> getProducts({int page = 1, int pageSize = 20, Map<String, String>? filters}) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (filters != null) ...filters,
    };
    final uri = Uri.parse('$_baseUrl/products/').replace(queryParameters: queryParams);
    final response = await _handleResponse<Map<String, dynamic>>((headers) => _client.get(
          uri,
          headers: headers,
        ));
    _logger.i('Products API Response: $response');
    return {
      'count': response['count'] ?? 0,
      'next': response['next'],
      'previous': response['previous'],
      'results': response['results'] ?? [],
    };
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> order) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.post(
          Uri.parse('$_baseUrl/orders/'),
          headers: headers,
          body: json.encode(order),
        ));
  }

  Future<Map<String, dynamic>> updateOrder(String id, Map<String, dynamic> order) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.put(
          Uri.parse('$_baseUrl/orders/$id/'),
          headers: headers,
          body: json.encode(order),
        ));
  }

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status, {String? comment}) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.patch(
          Uri.parse('$_baseUrl/orders/$id/status/'),
          headers: headers,
          body: json.encode({
            'status': status,
            if (comment != null) 'comment': comment,
          }),
        ));
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/orders/$id/'),
          headers: headers,
        ));
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/orders/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> address) async {
    _logger.i('Creating address with payload: $address'); // Log payload
    try {
      final response = await _handleResponse<Map<String, dynamic>>((headers) => _client.post(
            Uri.parse('$_baseUrl/addresses/'),
            headers: headers,
            body: json.encode(address),
          ));
      _logger.i('Create address response: $response');
      return response;
    } catch (e) {
      _logger.e('Create address failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAddress(String id, Map<String, dynamic> address) async {
    return _handleResponse<Map<String, dynamic>>((headers) => _client.put(
          Uri.parse('$_baseUrl/addresses/$id/'),
          headers: headers,
          body: json.encode(address),
        ));
  }

  Future<void> deleteAddress(String id) async {
    await _handleResponse<void>((headers) => _client.delete(
          Uri.parse('$_baseUrl/addresses/$id/'),
          headers: headers,
        ));
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/addresses/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/notifications/'),
          headers: headers,
        ));
    return response.cast<Map<String, dynamic>>();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _handleResponse<void>((headers) => _client.patch(
          Uri.parse('$_baseUrl/notifications/$id/read/'),
          headers: headers,
        ));
  }

  Future<void> markAllNotificationsAsRead() async {
    await _handleResponse<void>((headers) => _client.patch(
          Uri.parse('$_baseUrl/notifications/read-all/'),
          headers: headers,
        ));
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _handleResponse<void>((headers) => _client.put(
          Uri.parse('$_baseUrl/settings/'),
          headers: headers,
          body: json.encode(settings),
        ));
  }

  Future<List<dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _handleResponse<List<dynamic>>((headers) => _client.get(
          Uri.parse('$_baseUrl/analytics').replace(queryParameters: queryParams),
          headers: headers,
        ));
    return response;
  }

  Future<String> uploadFile(
      List<int> bytes,
      String filename,
      String contentType,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload/'),
    );

    final headers = await _getHeaders();
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final responseBody = json.decode(response.body);
    _logger.i('File upload response: $responseBody');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody['url'] ?? responseBody['file_url'];
    } else {
      _logger.e('File upload failed: ${response.body}');
      throw ApiException(message: 'File upload failed', statusCode: response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}