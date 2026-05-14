import 'package:flutter/foundation.dart';
import '../models/baby.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class BabyProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  List<BabyModel> _babies = [];
  BabyModel? _currentBaby;
  bool _loading = false;
  bool _hasLoaded = false;
  String? _error;

  List<BabyModel> get babies => _babies;
  BabyModel? get currentBaby => _currentBaby;
  bool get loading => _loading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  Future<void> loadBabies() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/babies');
      final list = (res['data'] as List<dynamic>?)
              ?.map((e) => BabyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _babies = list;
      _currentBaby ??= _babies.isNotEmpty ? _babies.first : null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[BabyProvider] loadBabies error: $_error');
      // Try loading from cache
      final cached = _storage.getJson(AppConstants.babyKey);
      if (cached != null) {
        _currentBaby = BabyModel.fromJson(cached);
      }
    } finally {
      _hasLoaded = true;
      _loading = false;
      notifyListeners();
    }
  }

  void selectBaby(BabyModel baby) {
    _currentBaby = baby;
    _storage.setJson(AppConstants.babyKey, baby.toJson());
    notifyListeners();
  }

  Future<bool> addBaby(BabyModel baby) async {
    try {
      final res = await _api.post('/babies', body: baby.toJson());
      final created = BabyModel.fromJson(res['data'] as Map<String, dynamic>);
      _babies.add(created);
      if (_currentBaby == null) {
        _currentBaby = created;
        _storage.setJson(AppConstants.babyKey, created.toJson());
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBaby(BabyModel baby) async {
    try {
      await _api.put('/babies/${baby.id}', body: baby.toJson());
      final idx = _babies.indexWhere((b) => b.id == baby.id);
      if (idx >= 0) {
        _babies[idx] = baby;
      }
      if (_currentBaby?.id == baby.id) {
        _currentBaby = baby;
        _storage.setJson(AppConstants.babyKey, baby.toJson());
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBaby(int babyId) async {
    try {
      await _api.delete('/babies/$babyId');
      _babies.removeWhere((b) => b.id == babyId);
      if (_currentBaby?.id == babyId) {
        _currentBaby = _babies.isNotEmpty ? _babies.first : null;
      }
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
