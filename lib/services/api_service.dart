import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'secure_storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthRequiredException extends ApiException {
  AuthRequiredException([String message = '登录已过期，请重新登录'])
      : super(401, message);
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  String? _token;
  VoidCallback? onAuthRequired;

  String get baseUrl => AppConstants.apiBaseUrl;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _secureStorage.setString(AppConstants.tokenKey, token);
    } else {
      await _secureStorage.remove(AppConstants.tokenKey);
    }
  }

  Future<void> loadToken() async {
    _token = await _secureStorage.getString(AppConstants.tokenKey);
  }

  bool get hasToken => _token != null;

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? queryParams}) async {
    return _safeRequest(() async {
      final uri = Uri.parse('$baseUrl$path')
          .replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    return _safeRequest(() async {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    return _safeRequest(() async {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _safeRequest(() async {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    });
  }

  /// Catches network/timeout errors and throws ApiException with friendly message.
  Future<Map<String, dynamic>> _safeRequest(
      Future<Map<String, dynamic>> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw ApiException(0, '网络连接失败，请检查网络设置');
    } on HttpException {
      throw ApiException(0, '服务器连接异常');
    } on TimeoutException {
      throw ApiException(0, '请求超时，请稍后重试');
    } on FormatException {
      throw ApiException(0, '数据格式异常');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ??
        body['error'] as String? ??
        '请求失败 (${response.statusCode})';

    if (response.statusCode == 401) {
      setToken(null);
      onAuthRequired?.call();
    }

    throw ApiException(response.statusCode, message);
  }
}
