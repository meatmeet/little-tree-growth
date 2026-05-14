import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _api = ApiService();

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
    _api.onAuthRequired = _onAuthRequired;
    notifyListeners();
  }

  void _onAuthRequired() {
    logout();
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

  Future<void> refreshVipStatus() async {
    try {
      final data = await _authService.getVipStatus();
      if (_user != null && data['has_subscription'] == true) {
        final updated = UserModel(
          id: _user!.id,
          phone: _user!.phone,
          nickname: _user!.nickname,
          avatarUrl: _user!.avatarUrl,
          isVip: true,
          vipExpireAt: data['end_date'] != null
              ? DateTime.tryParse(data['end_date'] as String)
              : null,
        );
        _user = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('refreshVipStatus error: $e');
    }
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
