import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String
  String? getString(String key) => _prefs?.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs?.setString(key, value) ?? Future.value(false);

  // Bool
  bool? getBool(String key) => _prefs?.getBool(key);
  Future<bool> setBool(String key, bool value) =>
      _prefs?.setBool(key, value) ?? Future.value(false);

  // Int
  int? getInt(String key) => _prefs?.getInt(key);
  Future<bool> setInt(String key, int value) =>
      _prefs?.setInt(key, value) ?? Future.value(false);

  // Double
  double? getDouble(String key) => _prefs?.getDouble(key);
  Future<bool> setDouble(String key, double value) =>
      _prefs?.setDouble(key, value) ?? Future.value(false);

  // JSON
  Map<String, dynamic>? getJson(String key) {
    final s = _prefs?.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) =>
      _prefs?.setString(key, jsonEncode(value)) ?? Future.value(false);

  // List<dynamic>
  List<dynamic>? getList(String key) {
    final s = _prefs?.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  Future<bool> setList(String key, List<dynamic> value) =>
      _prefs?.setString(key, jsonEncode(value)) ?? Future.value(false);

  // Remove
  Future<bool> remove(String key) =>
      _prefs?.remove(key) ?? Future.value(false);

  // Clear all
  Future<bool> clear() => _prefs?.clear() ?? Future.value(false);
}
