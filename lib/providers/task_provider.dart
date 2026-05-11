import 'dart:convert';
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

  Future<void> loadTodayTasks() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/tasks/today');
      final tasks = (res['tasks'] as List<dynamic>?)
              ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _todayTasks = tasks;
      _streakDays = res['streak_days'] as int? ?? 0;
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
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    notifyListeners();

    try {
      await _api.post('/tasks/${task.id}/toggle');
      _cacheTodayTasks();
      return true;
    } catch (e) {
      // Revert on failure
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
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

  Future<bool> checkin() async {
    try {
      await _api.post('/checkin');
      _streakDays++;
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
