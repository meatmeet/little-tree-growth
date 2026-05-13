import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CourseModel> _courses = [];
  bool _loading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadCourses({int? ageGroup}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (ageGroup != null) params['age_group'] = '$ageGroup';
      final res = await _api.get('/courses', queryParams: params.isNotEmpty ? params : null);
      final list = (res['data'] as List<dynamic>?)
              ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _courses = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
