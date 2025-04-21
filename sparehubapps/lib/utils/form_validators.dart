class FormValidators {
  static String? validateRequiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  static String? validateGST(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'GST number is required';
    }
    // Format: 22AAAAA0000A1Z5
    final gstRegex = RegExp(
      r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[Z]{1}[A-Z\d]{1}$',
    );
    if (!gstRegex.hasMatch(value)) {
      return 'Please enter a valid GST number';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN code is required';
    }
    if (value.length != 6) {
      return 'PIN code must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN code must contain only digits';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    final urlRegex = RegExp(
      r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 3) {
      return 'Product name must be at least 3 characters long';
    }
    if (value.length > 100) {
      return 'Product name cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateSKU(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU is required';
    }
    if (value.length < 3) {
      return 'SKU must be at least 3 characters long';
    }
    if (value.length > 50) {
      return 'SKU cannot exceed 50 characters';
    }
    if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value)) {
      return 'SKU can only contain letters, numbers, and hyphens';
    }
    return null;
  }

  static String? validateDiscount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Discount is optional
    }
    final discount = double.tryParse(value);
    if (discount == null) {
      return 'Please enter a valid discount percentage';
    }
    if (discount < 0) {
      return 'Discount cannot be negative';
    }
    if (discount > 100) {
      return 'Discount cannot exceed 100%';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    if (weight > 1000) {
      return 'Weight cannot exceed 1000 kg';
    }
    return null;
  }

  static String? validateDimensions(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Dimensions are optional
    }
    // Format: LxWxH or L x W x H
    final dimensionsRegex = RegExp(r'^\d+(\.\d+)?[\sx]*\d+(\.\d+)?[\sx]*\d+(\.\d+)?$');
    if (!dimensionsRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter dimensions in format: L x W x H';
    }
    return null;
  }

  static String? validateShippingCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Shipping cost is optional
    }
    final cost = double.tryParse(value);
    if (cost == null) {
      return 'Please enter a valid shipping cost';
    }
    if (cost < 0) {
      return 'Shipping cost cannot be negative';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters long';
    }
    if (value.length > 1000) {
      return 'Description cannot exceed 1000 characters';
    }
    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }
    if (value.length < 3) {
      return 'Company name must be at least 3 characters long';
    }
    if (value.length > 100) {
      return 'Company name cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    if (value.length > 500) {
      return 'Address cannot exceed 500 characters';
    }
    return null;
  }

  static String? validateBankAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    if (!RegExp(r'^[0-9]{9,18}$').hasMatch(value)) {
      return 'Please enter a valid account number';
    }
    return null;
  }

  static String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
      return 'Please enter a valid IFSC code';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    return null;
  }

  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount < 0) {
      return 'Amount cannot be negative';
    }
    if (min != null && amount < min) {
      return 'Amount must be at least ${min.toStringAsFixed(2)}';
    }
    if (max != null && amount > max) {
      return 'Amount cannot exceed ${max.toStringAsFixed(2)}';
    }
    return null;
  }
}
