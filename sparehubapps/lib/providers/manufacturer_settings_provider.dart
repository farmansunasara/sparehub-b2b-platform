import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManufacturerSettings {
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool lowStockAlertsEnabled;
  final bool orderUpdatesEnabled;
  final String currency;
  final String language;
  final ThemeMode themeMode;
  final int lowStockThreshold;
  final bool autoGenerateReports;
  final List<String> favoriteReports;

  ManufacturerSettings({
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.lowStockAlertsEnabled = true,
    this.orderUpdatesEnabled = true,
    this.currency = '₹ (INR)',
    this.language = 'English',
    this.themeMode = ThemeMode.system,
    this.lowStockThreshold = 10,
    this.autoGenerateReports = false,
    this.favoriteReports = const ['sales', 'inventory'],
  });

  ManufacturerSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? lowStockAlertsEnabled,
    bool? orderUpdatesEnabled,
    String? currency,
    String? language,
    ThemeMode? themeMode,
    int? lowStockThreshold,
    bool? autoGenerateReports,
    List<String>? favoriteReports,
  }) {
    return ManufacturerSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      lowStockAlertsEnabled: lowStockAlertsEnabled ?? this.lowStockAlertsEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      autoGenerateReports: autoGenerateReports ?? this.autoGenerateReports,
      favoriteReports: favoriteReports ?? this.favoriteReports,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'lowStockAlertsEnabled': lowStockAlertsEnabled,
      'orderUpdatesEnabled': orderUpdatesEnabled,
      'currency': currency,
      'language': language,
      'themeMode': themeMode.toString(),
      'lowStockThreshold': lowStockThreshold,
      'autoGenerateReports': autoGenerateReports,
      'favoriteReports': favoriteReports,
    };
  }

  factory ManufacturerSettings.fromJson(Map<String, dynamic> json) {
    return ManufacturerSettings(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? true,
      lowStockAlertsEnabled: json['lowStockAlertsEnabled'] ?? true,
      orderUpdatesEnabled: json['orderUpdatesEnabled'] ?? true,
      currency: json['currency'] ?? '₹ (INR)',
      language: json['language'] ?? 'English',
      themeMode: ThemeMode.values.firstWhere(
            (e) => e.toString() == (json['themeMode'] ?? ThemeMode.system.toString()),
      ),
      lowStockThreshold: json['lowStockThreshold'] ?? 10,
      autoGenerateReports: json['autoGenerateReports'] ?? false,
      favoriteReports: List<String>.from(json['favoriteReports'] ?? ['sales', 'inventory']),
    );
  }
}

class ManufacturerSettingsProvider with ChangeNotifier {
  static const _settingsKey = 'manufacturer_settings';
  late SharedPreferences _prefs;
  late ManufacturerSettings _settings;
  bool _initialized = false;

  ManufacturerSettings get settings => _settings;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _initialized = true;
  }

  void _loadSettings() {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decodedJson = jsonDecode(settingsJson);
        _settings = ManufacturerSettings.fromJson(decodedJson);
      } catch (e) {
        _settings = ManufacturerSettings();
      }
    } else {
      _settings = ManufacturerSettings();
    }
    notifyListeners();
  }

  Future<void> updateSettings(ManufacturerSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _prefs.setString(
      _settingsKey,
      jsonEncode(_settings.toJson()),
    );
  }

  Future<void> togglePushNotifications(bool enabled) async {
    _settings = _settings.copyWith(pushNotificationsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleEmailNotifications(bool enabled) async {
    _settings = _settings.copyWith(emailNotificationsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleLowStockAlerts(bool enabled) async {
    _settings = _settings.copyWith(lowStockAlertsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleOrderUpdates(bool enabled) async {
    _settings = _settings.copyWith(orderUpdatesEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    _settings = _settings.copyWith(lowStockThreshold: threshold);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleAutoGenerateReports(bool enabled) async {
    _settings = _settings.copyWith(autoGenerateReports: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateFavoriteReports(List<String> reports) async {
    _settings = _settings.copyWith(favoriteReports: reports);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _settings = ManufacturerSettings();
    await _saveSettings();
    notifyListeners();
  }
}
