import 'package:flutter/material.dart';
import 'package:sparehubapps/screens/shop/products/product_details_screen.dart';

import '../../models/product.dart';

export 'home_screen.dart';
export 'products/product_catalog_screen.dart';
export 'products/product_details_screen.dart';

// Navigation routes for the shop module
class ShopRoutes {
  static const String home = '/shop/home';
  static const String products = '/shop/products';
  static const String productDetails = '/shop/products/details';
  
  // Future routes
  static const String cart = '/shop/cart';
  static const String orders = '/shop/orders';
  static const String profile = '/shop/profile';
}

// Navigation methods
void navigateToProductDetails(BuildContext context, Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailsScreen(product: product),
    ),
  );
}

void navigateToShopHome(BuildContext context) {
  Navigator.pushReplacementNamed(context, ShopRoutes.home);
}
