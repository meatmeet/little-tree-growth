import 'package:flutter/foundation.dart';
import '../models/assessment.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AssessmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  List<AssessmentModel> _assessments = [];
  AssessmentModel? _currentAssessment;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _trend = [];
  bool _loading = false;
  String? _error;

  List<AssessmentModel> get assessments => _assessments;
  AssessmentModel? get currentAssessment => _currentAssessment;
  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> get trend => _trend;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadAssessments(int babyId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res =
          await _api.get('/assessments', queryParams: {'baby_id': '$babyId'});
      final list = (res['data'] as List<dynamic>?)
              ?.map(
                  (e) => AssessmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _assessments = list;
      _cacheAssessments();
    } catch (e) {
      _error = e.toString();
      final cached = _storage.getList(AppConstants.assessmentKey);
      if (cached != null) {
        _assessments = cached
            .map((e) => AssessmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<AssessmentModel?> createAssessment(int babyId, double ageMonths) async {
    try {
      final res = await _api.post('/assessments', body: {
        'baby_id': babyId,
        'actual_age_months': ageMonths,
      });
      final assessment = AssessmentModel.fromJson(res['data'] as Map<String, dynamic>);
      _assessments.insert(0, assessment);
      _currentAssessment = assessment;
      notifyListeners();
      return assessment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> submitAssessment(
      AssessmentModel assessment, List<Map<String, dynamic>> results) async {
    try {
      final res = await _api.post('/assessments/${assessment.id}/submit',
          body: {'results': results});
      final updated =
          AssessmentModel.fromJson(res['data'] as Map<String, dynamic>);
      final idx = _assessments.indexWhere((a) => a.id == assessment.id);
      if (idx >= 0) {
        _assessments[idx] = updated;
      }
      _currentAssessment = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectAssessment(AssessmentModel assessment) {
    _currentAssessment = assessment;
    notifyListeners();
  }

  Future<void> loadItems(int ageGroup) async {
    _items = [];
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/assessments/items',
          queryParams: {'age_group': '$ageGroup'});
      _items = (res['data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<AssessmentModel?> submitResults(
      int assessmentId, List<Map<String, dynamic>> results) async {
    try {
      final res = await _api.post('/assessments/$assessmentId/items',
          body: {'results': results});
      final updated =
          AssessmentModel.fromJson(res['data'] as Map<String, dynamic>);
      final idx = _assessments.indexWhere((a) => a.id == assessmentId);
      if (idx >= 0) _assessments[idx] = updated;
      _currentAssessment = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadTrend(int babyId) async {
    try {
      final res = await _api.get('/assessments/trend',
          queryParams: {'baby_id': '$babyId'});
      _trend = (res['data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (_) {
      _trend = [];
    } finally {
      notifyListeners();
    }
  }

  // ---- Report ----

  List<String> _highlights = [];
  List<Map<String, dynamic>> _suggestions = [];
  bool _reportLoading = false;
  String? _reportError;

  List<String> get highlights => _highlights;
  List<Map<String, dynamic>> get suggestions => _suggestions;
  bool get reportLoading => _reportLoading;
  String? get reportError => _reportError;

  Future<void> loadReport(int assessmentId) async {
    _reportLoading = true;
    _reportError = null;
    notifyListeners();

    try {
      final res = await _api.get('/assessments/$assessmentId/report');
      final data = res['data'] as Map<String, dynamic>?;
      _highlights = (data?['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      _suggestions = (data?['suggestions'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (e) {
      _reportError = e.toString();
    } finally {
      _reportLoading = false;
      notifyListeners();
    }
  }

  // ---- Radar ----

  List<String> _radarLabels = [];
  List<double> _radarValues = [];
  bool _radarLoading = false;
  String? _radarError;

  List<String> get radarLabels => _radarLabels;
  List<double> get radarValues => _radarValues;
  bool get radarLoading => _radarLoading;
  String? get radarError => _radarError;

  Future<void> loadRadarData(Map<String, String> params) async {
    _radarLoading = true;
    _radarError = null;
    notifyListeners();

    try {
      final res = await _api.get('/assessments/radar', queryParams: params);
      final data = res['data'] as Map<String, dynamic>?;
      _radarLabels = (data?['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      _radarValues = (data?['values'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [];
    } catch (e) {
      _radarError = e.toString();
      _radarLabels = [];
      _radarValues = [];
    } finally {
      _radarLoading = false;
      notifyListeners();
    }
  }

  void _cacheAssessments() {
    _storage.setList(
      AppConstants.assessmentKey,
      _assessments.map((a) => a.toJson()).toList(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
