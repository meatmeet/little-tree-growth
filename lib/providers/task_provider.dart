import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  List<TaskModel> _todayTasks = [];
  DailyTaskPlan? _todayPlan;
  int _streakDays = 0;
  bool _loading = false;
  String? _error;

  List<TaskModel> get todayTasks => _todayTasks;
  DailyTaskPlan? get todayPlan => _todayPlan;
  int get streakDays => _streakDays;
  bool get loading => _loading;
  String? get error => _error;

  int get completedCount => _todayTasks.where((t) => t.isCompleted).length;
  int get totalCount => _todayTasks.length;
  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0;

  Future<void> loadTodayTasks({int? babyId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (babyId != null) params['baby_id'] = '$babyId';
      final res = await _api.get('/tasks/daily', queryParams: params.isNotEmpty ? params : null);
      final data = res['data'] as Map<String, dynamic>? ?? res;
      final tasks = (data['tasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _todayTasks = tasks;
      _streakDays = data['streak_days'] as int? ?? 0;
      _cacheTodayTasks();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      // Try loading from cache
      final cached = _storage.getList(AppConstants.taskKey);
      if (cached != null) {
        _todayTasks = cached
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleTask(TaskModel task) async {
    final newCompleted = !task.isCompleted;
    final updated = task.copyWith(
      isCompleted: newCompleted,
      completedAt: newCompleted ? DateTime.now() : null,
    );
    final idx = _todayTasks.indexOf(task);
    if (idx >= 0) {
      _todayTasks[idx] = updated;
    }
    notifyListeners();

    try {
      if (updated.isCompleted) {
        await _api.put('/tasks/daily/${task.id}/complete');
      } else {
        await _api.put('/tasks/daily/${task.id}/skip');
      }
      _cacheTodayTasks();
      return true;
    } catch (e) {
      // Revert on failure
      if (idx >= 0) {
        _todayTasks[idx] = task;
      }
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _cacheTodayTasks() async {
    await _storage.setList(
      AppConstants.taskKey,
      _todayTasks.map((t) => t.toJson()).toList(),
    );
  }

  Future<bool> checkin({int? babyId}) async {
    try {
      final body = <String, dynamic>{};
      if (babyId != null) body['baby_id'] = babyId;
      await _api.post('/checkin', body: body.isNotEmpty ? body : null);
      _streakDays++;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> _calendarData = [];

  List<Map<String, dynamic>> get calendarData => _calendarData;

  Future<void> loadCalendar(int babyId, {String? month}) async {
    try {
      final m = month ??
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
      final res = await _api.get('/checkin/calendar',
          queryParams: {'baby_id': '$babyId', 'month': m});
      _calendarData = (res['data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      notifyListeners();
    } catch (e) {
      debugPrint('loadCalendar error: $e');
      _calendarData = [];
      notifyListeners();
    }
  }

  Future<bool> rateTask(int taskId, int rating) async {
    try {
      await _api.put('/tasks/$taskId/rating', body: {'rating': rating});
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
