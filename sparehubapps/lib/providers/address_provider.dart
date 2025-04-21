import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressProvider with ChangeNotifier {
  static const String _addressesKey = 'user_addresses';

  final ApiService _apiService;
  final SharedPreferences _prefs;

  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  AddressProvider(this._apiService, this._prefs) {
    _loadAddresses();
  }

  List<Address> get addresses => List.unmodifiable(_addresses);
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere(
            (address) => address.isDefault,
        orElse: () => _addresses.isNotEmpty ? _addresses.first : throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }

  List<Address> get homeAddresses => _addresses
      .where((address) => address.type == AddressType.home)
      .toList();

  List<Address> get workAddresses => _addresses
      .where((address) => address.type == AddressType.work)
      .toList();

  Future<void> _loadAddresses() async {
    try {
      final addressesJson = _prefs.getString(_addressesKey);
      if (addressesJson != null) {
        final List<dynamic> addressesList = json.decode(addressesJson);
        _addresses = addressesList
            .map((json) => Address.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
      await refreshAddresses();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
      _error = 'Failed to load addresses';
      notifyListeners();
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final addressesJson = json.encode(
        _addresses.map((address) => address.toJson()).toList(),
      );
      await _prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      debugPrint('Error saving addresses: $e');
      _error = 'Failed to save addresses';
      notifyListeners();
    }
  }

  Future<bool> addAddress(Address address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_addresses.isEmpty || address.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }

      final response = await _apiService.createAddress(address.toJson());
      final createdAddress = Address.fromJson(response);
      _addresses.add(createdAddress);

      if (_addresses.length == 1) {
        _selectedAddress = createdAddress;
      }

      await _saveAddresses();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('API Error adding address: ${e.message}');
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error adding address: $e');
      _error = 'Failed to add address';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(Address address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index == -1) throw Exception('Address not found');

      if (address.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }

      final response = await _apiService.updateAddress(address.id!, address.toJson());
      final updatedAddress = Address.fromJson(response);
      _addresses[index] = updatedAddress;

      if (_selectedAddress?.id == updatedAddress.id) {
        _selectedAddress = updatedAddress;
      }

      await _saveAddresses();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('API Error updating address: ${e.message}');
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error updating address: $e');
      _error = 'Failed to update address';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.deleteAddress(addressId);

      _addresses.removeWhere((a) => a.id == addressId);
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = defaultAddress;
      }

      await _saveAddresses();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      debugPrint('API Error deleting address: ${e.message}');
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      _error = 'Failed to delete address';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(String addressId) {
    try {
      _selectedAddress = _addresses.firstWhere(
            (address) => address.id == addressId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting address: $e');
      _error = 'Address not found';
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final address = _addresses.firstWhere(
            (a) => a.id == addressId,
      );
      return await updateAddress(address.copyWith(isDefault: true));
    } catch (e) {
      debugPrint('Error setting default address: $e');
      _error = 'Failed to set default address';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshAddresses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final addressesList = await _apiService.getAddresses();
      _addresses = addressesList
          .map((json) => Address.fromJson(json as Map<String, dynamic>))
          .toList();

      if (_selectedAddress != null &&
          !_addresses.any((a) => a.id == _selectedAddress!.id)) {
        _selectedAddress = defaultAddress;
      }

      await _saveAddresses();
    } on ApiException catch (e) {
      debugPrint('API Error refreshing addresses: ${e.message}');
      _error = e.message;
    } catch (e) {
      debugPrint('Error refreshing addresses: $e');
      _error = 'Failed to refresh addresses';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedAddress() {
    _selectedAddress = null;
    notifyListeners();
  }

  Address? getAddressById(String addressId) {
    try {
      return _addresses.firstWhere((a) => a.id == addressId);
    } catch (_) {
      return null;
    }
  }

  List<Address> searchAddresses(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _addresses.where((address) {
      return address.name.toLowerCase().contains(lowercaseQuery) ||
          address.addressLine1.toLowerCase().contains(lowercaseQuery) ||
          address.city.toLowerCase().contains(lowercaseQuery) ||
          address.state.toLowerCase().contains(lowercaseQuery) ||
          address.pincode.contains(query);
    }).toList();
  }
}
