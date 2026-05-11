import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _loading = false;
  bool _initialized = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  bool get initialized => _initialized;
  bool get isVip => _user?.isVip ?? false;
  String? get error => _error;

  Future<void> checkAuth() async {
    await _authService.init();
    _user = _authService.currentUser;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String phone, String code) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(phone, code);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _user = await _authService.updateProfile(data);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
