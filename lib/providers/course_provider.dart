import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

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
      _cacheCourses();
    } catch (e) {
      _error = e.toString();
      final cached = _storage.getList(AppConstants.courseCacheKey);
      if (cached != null) {
        _courses = cached
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _cacheCourses() {
    _storage.setList(
      AppConstants.courseCacheKey,
      _courses.map((c) => c.toJson()).toList(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
