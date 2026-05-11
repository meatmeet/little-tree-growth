import 'package:flutter/foundation.dart';
import '../models/growth_record.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class GrowthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  List<GrowthRecord> _records = [];
  List<Milestone> _milestones = [];
  bool _loading = false;
  String? _error;

  List<GrowthRecord> get records => _records;
  List<Milestone> get milestones => _milestones;
  bool get loading => _loading;
  String? get error => _error;

  GrowthRecord? get latestRecord =>
      _records.isNotEmpty ? _records.first : null;

  Future<void> loadRecords(int babyId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/growth-records',
          queryParams: {'baby_id': '$babyId'});
      final list = (res['data'] as List<dynamic>?)
              ?.map(
                  (e) => GrowthRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _records = list;
      _cacheRecords();
    } catch (e) {
      _error = e.toString();
      final cached = _storage.getList('${AppConstants.taskKey}_growth');
      if (cached != null) {
        _records = cached
            .map((e) => GrowthRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addRecord(GrowthRecord record) async {
    try {
      final res = await _api.post('/growth-records', body: {
        'baby_id': record.babyId,
        'record_date': record.recordDate.toIso8601String().substring(0, 10),
        if (record.heightCm != null) 'height_cm': record.heightCm,
        if (record.weightKg != null) 'weight_kg': record.weightKg,
        if (record.headCircCm != null) 'head_circ_cm': record.headCircCm,
        if (record.notes != null) 'notes': record.notes,
      });
      final created =
          GrowthRecord.fromJson(res['data'] as Map<String, dynamic>);
      _records.insert(0, created);
      _cacheRecords();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMilestones(int babyId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/milestones',
          queryParams: {'baby_id': '$babyId'});
      final list = (res['data'] as List<dynamic>?)
              ?.map(
                  (e) => Milestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _milestones = list;
      _cacheMilestones();
    } catch (e) {
      _error = e.toString();
      final cached = _storage.getList('${AppConstants.taskKey}_milestones');
      if (cached != null) {
        _milestones = cached
            .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addMilestone(Milestone milestone) async {
    try {
      final res = await _api.post('/milestones', body: {
        'baby_id': milestone.babyId,
        'milestone_type': milestone.milestoneType,
        if (milestone.occurredAt != null)
          'occurred_at': milestone.occurredAt!.toIso8601String(),
        if (milestone.notes != null) 'notes': milestone.notes,
        if (milestone.photoUrl != null) 'photo_url': milestone.photoUrl,
      });
      final created =
          Milestone.fromJson(res['data'] as Map<String, dynamic>);
      _milestones.insert(0, created);
      _cacheMilestones();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _cacheRecords() {
    _storage.setList(
      '${AppConstants.taskKey}_growth',
      _records.map((r) => r.toJson()).toList(),
    );
  }

  void _cacheMilestones() {
    _storage.setList(
      '${AppConstants.taskKey}_milestones',
      _milestones.map((m) => m.toJson()).toList(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
