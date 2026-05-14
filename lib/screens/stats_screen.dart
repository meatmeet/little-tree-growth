import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../providers/baby_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _weekly;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final baby = context.read<BabyProvider>().currentBaby;
    if (baby == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);

    try {
      final results = await Future.wait([
        _loadSummary(baby.id),
        _loadWeekly(baby.id),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0];
        _weekly = results[1];
        _loading = false;
      });
    } catch (e) {
      debugPrint('StatsScreen._load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>?> _loadSummary(int babyId) async {
    try {
      final res = await _api.get('/stats/summary',
          queryParams: {'baby_id': '$babyId'});
      return res['data'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('StatsScreen._loadSummary error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadWeekly(int babyId) async {
    try {
      final res = await _api.get('/stats/weekly',
          queryParams: {'baby_id': '$babyId'});
      return res['data'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('StatsScreen._loadWeekly error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成长统计')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  _summarySection(),
                  const SizedBox(height: 24),
                  // Weekly report
                  _weeklySection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _summarySection() {
    if (_summary == null) return _emptyState();

    final latestGrowth = _summary!['latest_growth'] as Map<String, dynamic>?;
    final latestDq = _summary!['latest_dq'] as num?;
    final streakDays = (_summary!['streak_days'] as num?)?.toInt() ?? 0;
    final milestoneCount = (_summary!['milestone_count'] as num?)?.toInt() ?? 0;
    final todayTasks = _summary!['today_tasks'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('数据概览',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                '📈', '最新 DQ',
                latestDq?.toStringAsFixed(0) ?? '--',
                AppTheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                '🔥', '连续打卡',
                '$streakDays 天',
                AppTheme.warm),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                '⭐', '里程碑',
                '$milestoneCount 个',
                AppTheme.info),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                '✅', '今日任务',
                '${todayTasks?['completed'] ?? 0}/${todayTasks?['total'] ?? 0}',
                AppTheme.success),
            ),
          ],
        ),
        if (latestGrowth != null) ...[
          const SizedBox(height: 10),
          _growthSummaryCard(latestGrowth),
        ],
      ],
    );
  }

  Widget _weeklySection() {
    if (_weekly == null) return const SizedBox.shrink();

    final checkinDays = (_weekly!['checkin_days'] as num?)?.toInt() ?? 0;
    final tasksDone = (_weekly!['tasks_completed'] as num?)?.toInt() ?? 0;
    final newMilestones = (_weekly!['new_milestones'] as num?)?.toInt() ?? 0;
    final growth = _weekly!['growth'] as Map<String, dynamic>?;
    final spotlight = _weekly!['spotlight_area'] as String?;
    final weakness = _weekly!['weakness_area'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('本周报告',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            children: [
              _weeklyRow(Icons.calendar_today, '打卡天数', '$checkinDays 天'),
              const Divider(height: 20),
              _weeklyRow(Icons.task_alt, '完成任务', '$tasksDone 个'),
              const Divider(height: 20),
              _weeklyRow(Icons.emoji_events_outlined, '新里程碑', '$newMilestones 个'),
              if (growth != null) ...[
                const Divider(height: 20),
                _weeklyRow(Icons.straighten, '身高增长',
                    growth['height_gain'] != null
                        ? '${growth['height_gain']} cm'
                        : '--'),
                const Divider(height: 20),
                _weeklyRow(Icons.monitor_weight, '体重增长',
                    growth['weight_gain'] != null
                        ? '${growth['weight_gain']} kg'
                        : '--'),
              ],
              if (spotlight != null) ...[
                const Divider(height: 20),
                _weeklyRow(Icons.trending_up, '优势能区', spotlight),
              ],
              if (weakness != null) ...[
                const Divider(height: 20),
                _weeklyRow(Icons.trending_down, '待加强', weakness),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _growthSummaryCard(Map<String, dynamic> growth) {
    final height = growth['height_cm'] as num?;
    final weight = growth['weight_kg'] as num?;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _statItem('身高', height?.toStringAsFixed(1) ?? '--', 'cm', AppTheme.primary),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFF0F0F0)),
          Expanded(
            child: _statItem('体重', weight?.toStringAsFixed(1) ?? '--', 'kg', AppTheme.warm),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color)),
        Text('$label ($unit)',
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _weeklyRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text('📊', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text('暂无统计数据',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
