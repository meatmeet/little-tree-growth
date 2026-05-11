import 'api_service.dart';
import 'storage_service.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isVip => _currentUser?.isVip ?? false;

  Future<void> init() async {
    await _api.loadToken();
    if (_api.hasToken) {
      final data = _storage.getJson(AppConstants.userKey);
      if (data != null) {
        _currentUser = UserModel.fromJson(data);
      }
    }
  }

  Future<UserModel> login(String phone, String code) async {
    final res = await _api.post('/auth/login', body: {
      'phone': phone,
      'code': code,
    });
    await _api.setToken(res['token'] as String?);
    _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    await _storage.setJson(AppConstants.userKey,
        (_currentUser!.toJson()));
    return _currentUser!;
  }

  Future<UserModel> sendCode(String phone) async {
    final res = await _api.post('/auth/send-code', body: {
      'phone': phone,
    });
    return UserModel.fromJson(res['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _api.setToken(null);
    await _storage.remove(AppConstants.userKey);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _api.put('/user/profile', body: data);
    _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    await _storage.setJson(AppConstants.userKey,
        (_currentUser!.toJson()));
    return _currentUser!;
  }
}
