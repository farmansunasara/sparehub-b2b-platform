import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/address.dart';
import '../models/cart.dart';
import 'cart_provider.dart';
import 'address_provider.dart';
import 'order_provider.dart';

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

  void nextStep() {
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
          placeOrder();
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
    final result = await _addressProvider.addAddress(address);
    if (result) {
      selectShippingAddress(address.id!);
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
  Future<Order?> placeOrder() async {
    if (!canPlaceOrder) return null;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final order = await _orderProvider.createOrder(
        cart: _cartProvider.cart,
        shippingAddress: selectedShippingAddress!,
        billingAddress: _useShippingAsBilling ? null : selectedShippingAddress,
        paymentMethod: _selectedPaymentMethod,
        metadata: {
          'checkout_timestamp': DateTime.now().toIso8601String(),
        },
      );

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
      _error = 'Failed to place order';
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
      _error =
          'Some items are out of stock: ${outOfStockItems.join(', ')}';
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
