import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/cart.dart';
import 'cart_provider.dart';
import 'address_provider.dart';
import 'order_provider.dart';
import 'auth_provider.dart';

enum CheckoutStep {
  address,
  payment,
  confirmation,
  complete,
}

class CheckoutProvider with ChangeNotifier {
  final CartProvider _cartProvider;
  final AddressProvider _addressProvider;
  final OrderProvider _orderProvider;
  final AuthProvider _authProvider;

  CheckoutStep _currentStep = CheckoutStep.address;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cod;
  bool _useShippingAsBilling = true;
  bool _isLoading = false;
  String? _error;

  // Order summary calculations
  double _subtotal = 0;
  double _tax = 0;
  double _shippingCost = 0;
  double _total = 0;

  CheckoutProvider(
    this._cartProvider,
    this._addressProvider,
    this._orderProvider,
    this._authProvider,
  ) {
    // Initialize order summary
    _calculateOrderSummary();
  }

  // Getters
  CheckoutStep get currentStep => _currentStep;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get useShippingAsBilling => _useShippingAsBilling;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get subtotal => _subtotal;
  double get tax => _tax;
  double get shippingCost => _shippingCost;
  double get total => _total;

  Cart get cart => _cartProvider.cart;
  Address? get selectedShippingAddress => _addressProvider.selectedAddress;
  List<Address> get savedAddresses => _addressProvider.addresses;

  bool get canProceedToPayment =>
      currentStep == CheckoutStep.address && selectedShippingAddress != null;

  bool get canProceedToConfirmation =>
      currentStep == CheckoutStep.payment && selectedPaymentMethod != null;

  bool get canPlaceOrder =>
      currentStep == CheckoutStep.confirmation &&
      selectedShippingAddress != null &&
      selectedPaymentMethod != null &&
      !_isLoading;

  // Calculate order summary
  void _calculateOrderSummary() {
    _subtotal = _cartProvider.total;
    _tax = _subtotal * 0.18; // 18% GST
    _shippingCost = _cartProvider.cart.items.fold<double>(
      0,
      (sum, item) => sum + (item.product.shippingCost * item.quantity),
    );
    _total = _subtotal + _tax + _shippingCost;
    notifyListeners();
  }

  // Navigation methods
  void goToStep(CheckoutStep step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep(BuildContext context) {
    switch (_currentStep) {
      case CheckoutStep.address:
        if (canProceedToPayment) {
          _currentStep = CheckoutStep.payment;
        }
        break;
      case CheckoutStep.payment:
        if (canProceedToConfirmation) {
          _currentStep = CheckoutStep.confirmation;
        }
        break;
      case CheckoutStep.confirmation:
        if (canPlaceOrder) {
          placeOrder(context: context);
        }
        break;
      case CheckoutStep.complete:
        break;
    }
    notifyListeners();
  }

  void previousStep() {
    switch (_currentStep) {
      case CheckoutStep.address:
        break;
      case CheckoutStep.payment:
        _currentStep = CheckoutStep.address;
        break;
      case CheckoutStep.confirmation:
        _currentStep = CheckoutStep.payment;
        break;
      case CheckoutStep.complete:
        break;
    }
    notifyListeners();
  }

  // Address management
  void selectShippingAddress(String addressId) {
    _addressProvider.selectAddress(addressId);
    notifyListeners();
  }

  Future<bool> addNewAddress(Address address) async {
    debugPrint('Adding new address: ${address.name}, ${address.phone}');
    final result = await _addressProvider.addAddress(address);
    debugPrint('addNewAddress result: $result');
    if (result) {
      // Refresh addresses and ensure the new address is fetched
      await _addressProvider.refreshAddresses();
      // Log the current addresses to debug
      debugPrint('Addresses after refresh: ${_addressProvider.addresses.map((a) => "${a.id}: ${a.name}, ${a.phone}").toList()}');
      // Find the newly added address by matching properties
      final newAddress = _addressProvider.addresses.lastWhere(
        (a) =>
            a.name == address.name &&
            a.phone == address.phone &&
            a.addressLine1 == address.addressLine1,
        orElse: () => address,
      );
      if (newAddress.id != null) {
        debugPrint('Selecting new address with ID: ${newAddress.id}');
        selectShippingAddress(newAddress.id!);
      } else {
        debugPrint('New address ID is null');
      }
    } else {
      debugPrint('Failed to add address');
    }
    return result;
  }

  void toggleUseShippingAsBilling() {
    _useShippingAsBilling = !_useShippingAsBilling;
    notifyListeners();
  }

  // Payment management
  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Place order
  Future<Order?> placeOrder({required BuildContext context}) async {
    if (!canPlaceOrder) {
      debugPrint('Cannot place order: conditions not met');
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get userId from AuthProvider
      final authProvider = context.read<AuthProvider>();
      if (authProvider.status != AuthStatus.authenticated || authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }
      final userId = authProvider.currentUser!.id.toString();

      // Construct a complete order payload
      final orderPayload = {
        'user': userId, // FIXED: Changed back to 'user' to match backend
        'shop_name': 'SpareHub Shop',
        'items': _cartProvider.cart.items
            .map((item) => {
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                })
            .toList(),
        'shipping_address': selectedShippingAddress!.toOrderAddress().toJson(),
        'billing_address': _useShippingAsBilling
            ? null
            : selectedShippingAddress!.toOrderAddress().toJson(),
        'payment': {
          'method': _selectedPaymentMethod.toString().split('.').last,
          'status': 'pending',
          'amount': _total,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'status': 'pending',
        'subtotal': _subtotal,
        'tax': _tax,
        'shipping_cost': _shippingCost,
        'total': _total,
        'metadata': {
          'checkout_timestamp': DateTime.now().toIso8601String(),
        },
      };

      debugPrint('Order payload: $orderPayload');

      final order = await _orderProvider.createOrderFromPayload(orderPayload);

      if (order != null) {
        // Clear cart and move to complete step
        await _cartProvider.clear();
        _currentStep = CheckoutStep.complete;
        notifyListeners();
        return order;
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      debugPrint('Error placing order: $e');
      _error = 'Failed to place order: ${e.toString()}';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset checkout
  void resetCheckout() {
    _currentStep = CheckoutStep.address;
    _selectedPaymentMethod = PaymentMethod.cod;
    _useShippingAsBilling = true;
    _error = null;
    _addressProvider.clearSelectedAddress();
    _calculateOrderSummary();
    notifyListeners();
  }

  // Validate cart items
  bool validateCart() {
    if (_cartProvider.isEmpty) {
      _error = 'Your cart is empty';
      notifyListeners();
      return false;
    }

    final outOfStockItems = _cartProvider.cart.items
        .where((item) => item.quantity > item.product.stockQuantity)
        .map((item) => item.product.name)
        .toList();

    if (outOfStockItems.isNotEmpty) {
      _error = 'Some items are out of stock: ${outOfStockItems.join(', ')}';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Get formatted values
  String get formattedSubtotal => '₹${_subtotal.toStringAsFixed(2)}';
  String get formattedTax => '₹${_tax.toStringAsFixed(2)}';
  String get formattedShipping => '₹${_shippingCost.toStringAsFixed(2)}';
  String get formattedTotal => '₹${_total.toStringAsFixed(2)}';

  String get currentStepText => _currentStep.toString().split('.').last;
  String get selectedPaymentMethodText =>
      _selectedPaymentMethod.toString().split('.').last;
}