import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthError implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AuthError(this.message, {this.code, this.details});

  @override
  String toString() => 'AuthError: $message${code != null ? ' (Code: $code)' : ''}';
}

class AuthProvider with ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final ApiService _apiService;
  final SharedPreferences _prefs;
  final _storage = const FlutterSecureStorage();
  final _logger = Logger();

  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _error;
  Timer? _tokenRefreshTimer;

  AuthProvider({required SharedPreferences prefs})
      : _prefs = prefs,
        _apiService = ApiService(prefs: prefs) {
    _initializeAuth();
  }

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> _hasValidTokens() async {
    final token = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    return token != null && refreshToken != null;
  }

  Future<void> _initializeAuth() async {
    try {
      _logger.i('Initializing authentication state...');
      _status = AuthStatus.loading;
      notifyListeners();

      if (await _hasValidTokens()) {
        _logger.i('Found stored tokens, attempting to initialize session...');
        try {
          final token = await _storage.read(key: _tokenKey);
          final refreshToken = await _storage.read(key: _refreshTokenKey);

          await _apiService.setAuthToken(token!);
          await _apiService.setRefreshToken(refreshToken!);

          try {
            await loadProfile();
            _setupTokenRefresh();
            _status = AuthStatus.authenticated;
            _logger.i('Successfully initialized auth session');
          } catch (e) {
            if (e.toString().contains('Authentication required')) {
              _logger.i('Stored tokens are invalid, clearing auth state');
              await _clearAuthState();
            } else {
              _logger.e('Error loading profile: $e');
              throw e;
            }
          }
        } catch (e) {
          _logger.e('Failed to initialize auth session: $e');
          await _clearAuthState();
        }
      } else {
        _logger.i('No stored tokens found');
        await _clearAuthState();
      }
    } catch (e) {
      _logger.e('Error initializing auth: $e');
      await _clearAuthState();
      _handleError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> _clearAuthState() async {
    _logger.i('Clearing auth state...');
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _prefs.remove(_userKey);
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _tokenRefreshTimer?.cancel();
    notifyListeners();
  }

  Future<void> _refreshToken() async {
    try {
      _logger.i('Attempting to refresh tokens...');
      final response = await _apiService.refreshAccessToken();

      if (response['access'] != null) {
        await _storage.write(key: _tokenKey, value: response['access'].toString());
        _logger.i('Successfully stored new access token');
      } else {
        _logger.e('No access token in refresh response');
        throw AuthError('No access token in refresh response');
      }
      if (response['refresh'] != null) {
        await _storage.write(key: _refreshTokenKey, value: response['refresh'].toString());
        _logger.i('Successfully stored new refresh token');
      }
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      await logout();
      throw AuthError('Failed to refresh tokens', details: e);
    }
  }

  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 55),
      (timer) async {
        try {
          await _refreshToken();
          _logger.i('Successfully refreshed tokens via timer');
        } catch (e) {
          _logger.e('Failed to refresh tokens via timer: $e');
          timer.cancel();
          await logout();
        }
      },
    );
  }

  Future<void> loadProfile() async {
    try {
      _setLoading();

      final cachedUserStr = _prefs.getString(_userKey);
      if (cachedUserStr != null) {
        try {
          final cachedUserMap = json.decode(cachedUserStr) as Map<String, dynamic>;
          _currentUser = User.fromJson(cachedUserMap);
          notifyListeners();
        } catch (e) {
          _logger.w('Error loading cached user data: $e');
        }
      }

      final response = await _apiService.getUserProfile();
      _logger.i('Profile API response: $response');
      try {
        _currentUser = User.fromJson(response);
        await _prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      } catch (e) {
        _logger.e('Error parsing profile data: $e\nResponse: $response');
        throw AuthError('Failed to parse profile data: ${e.toString()}');
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> login(String email, String password, {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        _setLoading();

        if (!_isValidEmail(email)) {
          throw AuthError('Invalid email format');
        }
        if (!_isValidPassword(password)) {
          throw AuthError('Password must be at least 8 characters');
        }

        final response = await _apiService.login(email, password);
        _logger.i('Login response: $response');

        if (response['access'] != null) {
          await _storage.write(key: _tokenKey, value: response['access'].toString());
          _logger.i('Access token stored successfully');
        } else {
          _logger.e('No access token in login response');
          throw AuthError('No access token in login response');
        }
        if (response['refresh'] != null) {
          await _storage.write(key: _refreshTokenKey, value: response['refresh'].toString());
          _logger.i('Refresh token stored successfully');
        } else {
          _logger.e('No refresh token in login response');
          throw AuthError('No refresh token in login response');
        }

        if (response['user'] != null) {
          try {
            final userData = response['user'] as Map<String, dynamic>;
            _logger.i('Parsing user data: $userData');
            _currentUser = User.fromJson(userData);
            await _prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
          } catch (e, stackTrace) {
            _logger.e('Error parsing user data: $e\nStackTrace: $stackTrace\nResponse: ${response['user']}');
            throw AuthError('Failed to parse user data: ${e.toString()}', details: e);
          }
        } else {
          _logger.e('No user data in login response');
          throw AuthError('No user data in login response');
        }

        _status = AuthStatus.authenticated;
        _setupTokenRefresh();
        notifyListeners();
        return;
      } catch (e, stackTrace) {
        attempts++;
        _logger.e('Login attempt $attempts failed: $e\nStackTrace: $stackTrace');
        if (attempts >= maxRetries) {
          _handleError(e);
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String gst,
    String? license,
    XFile? logo,
  }) async {
    try {
      _setLoading();

      if (!_isValidEmail(email)) {
        throw AuthError('Invalid email format');
      }
      if (!_isValidPhone(phone)) {
        throw AuthError('Invalid phone number format');
      }

      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'gst': gst,
        if (_currentUser?.role.toLowerCase() == 'manufacturer') 'companyName': name,
        if (_currentUser?.role.toLowerCase() == 'shop') 'shopName': name,
      };

      if (_currentUser?.role.toLowerCase() == 'shop' && license != null) {
        data['license'] = license;
      }

      if (logo != null) {
        try {
          final bytes = await logo.readAsBytes();
          final fileUrl = await _apiService.uploadFile(
            bytes,
            logo.name,
            'image/${logo.name.split('.').last}',
          );
          data['logo'] = fileUrl;
        } catch (e) {
          _logger.e('Error uploading logo: $e');
          throw AuthError('Failed to upload logo: ${e.toString()}');
        }
      }

      final response = await _apiService.updateProfile(data);
      _logger.i('Update profile response: $response');

      try {
        _currentUser = User.fromJson(response);
        await _prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      } catch (e) {
        _logger.e('Error parsing updated user data: $e\nResponse: $response');
        throw AuthError('Failed to parse updated user data: ${e.toString()}');
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading();

      if (await _hasValidTokens()) {
        try {
          await _apiService.logout();
        } catch (e) {
          _logger.w('Error during logout API call: $e');
        }
      }

      await _clearAuthState();
    } catch (e) {
      _logger.e('Error during logout: $e');
      await _clearAuthState();
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    _error = error is AuthError ? error.message : error.toString();
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _setLoading() {
    _error = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone.replaceAll(RegExp(r'\s|-'), ''));
  }
}