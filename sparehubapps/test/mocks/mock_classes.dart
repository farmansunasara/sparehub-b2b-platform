import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

class MockClient extends Mock implements http.Client {
  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return super.noSuchMethod(
      Invocation.method(#post, [url], {#headers: headers, #body: body, #encoding: encoding}),
      returnValue: Future.value(http.Response('', 200)),
    );
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return super.noSuchMethod(
      Invocation.method(#get, [url], {#headers: headers}),
      returnValue: Future.value(http.Response('', 200)),
    );
  }

  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return super.noSuchMethod(
      Invocation.method(#delete, [url], {#headers: headers}),
      returnValue: Future.value(http.Response('', 200)),
    );
  }

  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return super.noSuchMethod(
      Invocation.method(#patch, [url], {#headers: headers, #body: body}),
      returnValue: Future.value(http.Response('', 200)),
    );
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, dynamic> _values = {};

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

class MockConnectivity extends Mock implements Connectivity {
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return super.noSuchMethod(
      Invocation.method(#checkConnectivity, []),
      returnValue: Future.value(ConnectivityResult.wifi),
    );
  }
}
