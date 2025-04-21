import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparehubapps/providers/notifications_provider.dart';
import 'package:sparehubapps/screens/shop/products/product_catalog_screen.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/address_provider.dart';
import 'providers/order_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/shop/cart/cart_screen.dart';
import 'screens/shop/products/product_details_screen.dart';
import 'screens/shop/checkout/checkout_screen.dart';
import 'screens/shop/orders/orders_screen.dart';
import 'screens/shop/orders/order_details_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/manufacturer_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/manufacturer_registration_screen.dart';
import 'screens/auth/shop_registration_screen.dart';
import 'screens/manufacturer/home_screen.dart';
import 'screens/shop/home_screen.dart';
import 'screens/shop/profile/profile_screen.dart';
import 'screens/shop/notifications/notifications_screen.dart';
import 'screens/shop/settings/settings_screen.dart';
import 'screens/manufacturer/products/product_form_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Core Services
        Provider<ApiService>(
          create: (_) => ApiService(prefs: prefs),
        ),

        // Theme Management
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),

        // Authentication & User Management
        ChangeNotifierProvider(
          create: (context) => AuthProvider(prefs: prefs),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ManufacturerProvider>(
          create: (context) => ManufacturerProvider(
            prefs: prefs,
            context: context,
          ),
          update: (context, auth, previous) => ManufacturerProvider(
            prefs: prefs,
            context: context,
          ),
        ),

        // Shop & Product Management
        ChangeNotifierProvider(
          create: (context) => ShopProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),

        // Notifications Management
        ChangeNotifierProvider(
          create: (context) => NotificationsProvider(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),

        // Cart & Checkout Management
        ChangeNotifierProvider(
          create: (context) => CartProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressProvider(
            Provider.of<ApiService>(context, listen: false),
            prefs,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (context) => OrderProvider(
            Provider.of<ApiService>(context, listen: false),
            prefs,
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => OrderProvider(
            Provider.of<ApiService>(context, listen: false),
            prefs,
            auth,
          ),
        ),
        ChangeNotifierProxyProvider4<AuthProvider, CartProvider, AddressProvider,
            OrderProvider, CheckoutProvider>(
          create: (context) => CheckoutProvider(
            Provider.of<CartProvider>(context, listen: false),
            Provider.of<AddressProvider>(context, listen: false),
            Provider.of<OrderProvider>(context, listen: false),
          ),
          update: (context, auth, cart, address, order, previous) =>
              CheckoutProvider(
                cart,
                address,
                order,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SpareHub',
      themeMode: themeProvider.themeMode,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/auth/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/auth/role-selection':
            return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
          case '/auth/manufacturer':
            return MaterialPageRoute(
                builder: (_) => const ManufacturerRegistrationScreen());
          case '/auth/shop':
            return MaterialPageRoute(
                builder: (_) => const ShopRegistrationScreen());
          case '/manufacturer/home':
            return MaterialPageRoute(
                builder: (_) => const ManufacturerHomeScreen());
          case '/manufacturer/add-product':
            return MaterialPageRoute(builder: (_) => const ProductFormScreen());
          case '/shop/home':
            return MaterialPageRoute(builder: (_) => const ShopHomeScreen());
          case '/shop/profile':
            return MaterialPageRoute(builder: (_) => const ShopProfileScreen());
          case '/shop/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());
          case '/shop/notifications':
            return MaterialPageRoute(
                builder: (_) => const ShopNotificationsScreen());
          case '/shop/settings':
            return MaterialPageRoute(builder: (_) => const ShopSettingsScreen());
          case '/shop/products/catalog':
            return MaterialPageRoute(
                builder: (_) => const ProductCatalogScreen());
          case '/shop/products/details':
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            );
          case '/shop/checkout':
            return MaterialPageRoute(builder: (_) => const CheckoutScreen());
          case '/shop/orders':
            final orderId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => OrdersScreen(initialOrderId: orderId),
            );
          case '/shop/orders/details':
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: orderId),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}