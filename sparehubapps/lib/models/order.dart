import 'package:flutter/foundation.dart';
import 'cart.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded
}

enum PaymentMethod {
  cod,
  card,
  upi,
  netBanking,
  wallet
}

class OrderAddress {
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  const OrderAddress({
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'is_default': isDefault,
    };
  }

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      isDefault: json['is_default'] ?? false,
    );
  }

  OrderAddress copyWith({
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
    bool? isDefault,
  }) {
    return OrderAddress(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderAddress &&
        other.name == name &&
        other.phone == phone &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.state == state &&
        other.pincode == pincode &&
        other.country == country &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return name.hashCode ^
    phone.hashCode ^
    addressLine1.hashCode ^
    addressLine2.hashCode ^
    city.hashCode ^
    state.hashCode ^
    pincode.hashCode ^
    country.hashCode ^
    isDefault.hashCode;
  }

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty ?? false) addressLine2,
      city,
      state,
      pincode,
      country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return '$name\n$parts\nPhone: $phone';
  }
}

class OrderPayment {
  final String id;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String? transactionId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const OrderPayment({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    this.transactionId,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.toString(),
      'status': status.toString(),
      'amount': amount,
      'transaction_id': transactionId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'],
      method: PaymentMethod.values.firstWhere(
            (e) => e.toString() == json['method'],
      ),
      status: PaymentStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
      ),
      amount: json['amount'].toDouble(),
      transactionId: json['transaction_id'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  OrderPayment copyWith({
    String? id,
    PaymentMethod? method,
    PaymentStatus? status,
    double? amount,
    String? transactionId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return OrderPayment(
      id: id ?? this.id,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderPayment &&
        other.id == id &&
        other.method == method &&
        other.status == status &&
        other.amount == amount &&
        other.transactionId == transactionId &&
        other.timestamp == timestamp &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    method.hashCode ^
    status.hashCode ^
    amount.hashCode ^
    transactionId.hashCode ^
    timestamp.hashCode ^
    metadata.hashCode;
  }
}

class Order {
  final String id;
  final String userId;
  final String shopName;  // Add shopName field
  final List<CartItem> items;
  final OrderAddress shippingAddress;
  final OrderAddress? billingAddress;
  final OrderPayment payment;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderStatusUpdate> statusUpdates;
  final Map<String, dynamic>? metadata;

  const Order({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.items,
    required this.shippingAddress,
    this.billingAddress,
    required this.payment,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.createdAt,
    this.updatedAt,
    this.statusUpdates = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_name': shopName,  // Add shopName to JSON
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress?.toJson(),
      'payment': payment.toJson(),
      'status': status.toString(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping_cost': shippingCost,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status_updates':
      statusUpdates.map((update) => update.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      shopName: json['shop_name'] ?? 'Unknown Shop',  // Add shopName with default
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      shippingAddress: OrderAddress.fromJson(json['shipping_address']),
      billingAddress: json['billing_address'] != null
          ? OrderAddress.fromJson(json['billing_address'])
          : null,
      payment: OrderPayment.fromJson(json['payment']),
      status: OrderStatus.values
          .firstWhere((e) => e.toString() == json['status']),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      shippingCost: json['shipping_cost'].toDouble(),
      total: json['total'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      statusUpdates: (json['status_updates'] as List)
          .map((update) => OrderStatusUpdate.fromJson(update))
          .toList(),
      metadata: json['metadata'],
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? shopName,
    List<CartItem>? items,
    OrderAddress? shippingAddress,
    OrderAddress? billingAddress,
    OrderPayment? payment,
    OrderStatus? status,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderStatusUpdate>? statusUpdates,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.userId == userId &&
        listEquals(other.items, items) &&
        other.shippingAddress == shippingAddress &&
        other.billingAddress == billingAddress &&
        other.payment == payment &&
        other.status == status &&
        other.subtotal == subtotal &&
        other.tax == tax &&
        other.shippingCost == shippingCost &&
        other.total == total &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.statusUpdates, statusUpdates) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    items.hashCode ^
    shippingAddress.hashCode ^
    billingAddress.hashCode ^
    payment.hashCode ^
    status.hashCode ^
    subtotal.hashCode ^
    tax.hashCode ^
    shippingCost.hashCode ^
    total.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    statusUpdates.hashCode ^
    metadata.hashCode;
  }

  String get formattedTotal => '₹${total.toStringAsFixed(2)}';
  String get formattedSubtotal => '₹${subtotal.toStringAsFixed(2)}';
  String get formattedTax => '₹${tax.toStringAsFixed(2)}';
  String get formattedShipping => '₹${shippingCost.toStringAsFixed(2)}';

  String get statusText => status.toString().split('.').last;
  PaymentMethod get paymentMethod => payment.method;
  PaymentStatus get paymentStatus => payment.status;
  String get paymentMethodText => payment.method.toString().split('.').last;
  String get paymentStatusText => payment.status.toString().split('.').last;

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canReturn => status == OrderStatus.delivered;
  bool get isCompleted => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isReturned => status == OrderStatus.returned;
}

class OrderStatusUpdate {
  final OrderStatus status;
  final String? comment;
  final DateTime timestamp;

  const OrderStatusUpdate({
    required this.status,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString(),
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status:
      OrderStatus.values.firstWhere((e) => e.toString() == json['status']),
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderStatusUpdate &&
        other.status == status &&
        other.comment == comment &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => status.hashCode ^ comment.hashCode ^ timestamp.hashCode;

  String get statusText => status.toString().split('.').last;
}
