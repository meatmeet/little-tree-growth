import 'package:flutter/foundation.dart';
import '../models/assessment.dart';
import '../services/api_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<AssessmentModel> _assessments = [];
  AssessmentModel? _currentAssessment;
  bool _loading = false;
  String? _error;

  List<AssessmentModel> get assessments => _assessments;
  AssessmentModel? get currentAssessment => _currentAssessment;
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
    } catch (e) {
      _error = e.toString();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
