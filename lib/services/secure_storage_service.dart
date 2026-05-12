import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getString(String key) => _storage.read(key: key);
  Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<void> remove(String key) => _storage.delete(key: key);

  Future<Map<String, dynamic>?> getJson(String key) async {
    final s = await _storage.read(key: key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _storage.write(key: key, value: jsonEncode(value));

  Future<void> clear() => _storage.deleteAll();
}
