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

  Future<bool> purchaseCourse(int courseId) async {
    try {
      await _api.post('/courses/$courseId/purchase');
      final idx = _courses.indexWhere((c) => c.id == courseId);
      if (idx >= 0) {
        _courses[idx] = CourseModel(
          id: _courses[idx].id,
          title: _courses[idx].title,
          description: _courses[idx].description,
          coverUrl: _courses[idx].coverUrl,
          price: _courses[idx].price,
          courseType: 'purchased',
          ageGroupMin: _courses[idx].ageGroupMin,
          ageGroupMax: _courses[idx].ageGroupMax,
          totalLessons: _courses[idx].totalLessons,
          progress: _courses[idx].progress,
          isPublished: _courses[idx].isPublished,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress(int courseId, double progress) async {
    try {
      await _api.put('/courses/$courseId/progress', body: {'progress': progress});
      final idx = _courses.indexWhere((c) => c.id == courseId);
      if (idx >= 0) {
        _courses[idx] = CourseModel(
          id: _courses[idx].id,
          title: _courses[idx].title,
          description: _courses[idx].description,
          coverUrl: _courses[idx].coverUrl,
          price: _courses[idx].price,
          courseType: _courses[idx].courseType,
          ageGroupMin: _courses[idx].ageGroupMin,
          ageGroupMax: _courses[idx].ageGroupMax,
          totalLessons: _courses[idx].totalLessons,
          progress: progress,
          isPublished: _courses[idx].isPublished,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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
