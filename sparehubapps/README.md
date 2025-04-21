# Spare Hub

A Flutter application connecting manufacturers and shops for vehicle body parts trading.

## Features

- **Authentication System**
    - Common login for manufacturers and shops
    - Role-based registration (Manufacturer/Shop)
    - Secure authentication with token management

- **Manufacturer Features**
    - Product management (Add, Edit, Delete)
    - Order management
    - Sales analytics
    - Stock management

- **Shop Features**
    - Browse products
    - Shopping cart
    - Order placement and tracking
    - Purchase history

## Project Structure

```
lib/
├── models/
│   ├── user_model.dart
│   ├── product_model.dart
│   └── order_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── order_provider.dart
│   └── cart_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── order_service.dart
│   └── cart_service.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── choose_registration_screen.dart
│   │   ├── manufacturer_registration_screen.dart
│   │   └── shop_registration_screen.dart
│   ├── manufacturer/
│   │   └── manufacturer_dashboard.dart
│   └── shop/
│       └── shop_dashboard.dart
└── main.dart
```

## Setup Instructions

1. **Prerequisites**
    - Flutter SDK (latest version)
    - Dart SDK (latest version)
    - Android Studio / VS Code with Flutter plugins

2. **Installation**
   ```bash
   # Clone the repository
   git clone https://github.com/yourusername/sparehubapps.git

   # Navigate to project directory
   cd sparehubapps

   # Install dependencies
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

- `provider`: State management
- `shared_preferences`: Local storage
- `http`: API communication
- `flutter_secure_storage`: Secure storage for tokens
- `image_picker`: Image selection
- `cached_network_image`: Image caching
- `intl`: Internationalization and formatting

## State Management

The app uses Provider pattern for state management with the following providers:
- `AuthProvider`: Manages authentication state
- `ProductProvider`: Manages product data
- `OrderProvider`: Manages order operations
- `CartProvider`: Manages shopping cart state

## Services

- `AuthService`: Handles authentication operations
- `ProductService`: Manages product-related operations
- `OrderService`: Handles order processing
- `CartService`: Manages shopping cart operations

## Models

- `User`: Represents both manufacturer and shop user types
- `Product`: Represents product information
- `Order`: Represents order information
- `CartItem`: Represents items in shopping cart

## Assets

```
assets/
├── fonts/
│   ├── Roboto-Regular.ttf
│   ├── Roboto-Bold.ttf
│   └── Roboto-Light.ttf
└── logos/
    └── sparehub_ic_logo.png
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.