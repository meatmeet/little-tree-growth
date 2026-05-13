import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../models/course.dart';

class CourseDetailScreen extends StatefulWidget {
  final int? courseId;
  final String title;
  final String subtitle;
  final String? ageRange;
  final Color? color;

  const CourseDetailScreen({
    super.key,
    this.courseId,
    required this.title,
    required this.subtitle,
    this.ageRange,
    this.color,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _api = ApiService();
  List<CourseLesson> _lessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      _loadLessons();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadLessons() async {
    try {
      final res = await _api.get('/courses/${widget.courseId}/lessons');
      if (mounted) {
        final list = (res['data'] as List<dynamic>?)
                ?.map((e) => CourseLesson.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        setState(() => _lessons = list);
      }
    } catch (_) {
      // Fallback to static
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.color ?? AppTheme.primary;
    final displayLessons = _loading ? _buildSkeletonLessons() : (_lessons.isNotEmpty ? _lessons : _buildStaticLessons());

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(Icons.auto_stories, size: 32, color: AppTheme.primary)),
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text(widget.subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                  textAlign: TextAlign.center),
                if (widget.ageRange != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('适合 ${widget.ageRange}', style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('课程简介', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            '本课程通过科学设计的游戏活动，促进宝宝在对应能区的发展。建议家长每天安排15-30分钟，在轻松愉快的氛围中与宝宝互动。',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),

          const SizedBox(height: 20),

          Text(
            '课程内容 (${displayLessons.length}节)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          ...displayLessons.asMap().entries.map((entry) {
            final i = entry.key;
            final lesson = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w700, color: accentColor))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          if (lesson.description != null && lesson.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(lesson.description!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    if (lesson.durationMin != null)
                      Text('${lesson.durationMin}min', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.lock_outline, size: 18, color: AppTheme.textTertiary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<CourseLesson> _buildStaticLessons() {
    return [
      CourseLesson(id: 1, courseId: widget.courseId ?? 0, title: '基础认知训练', description: '认知能力的基础训练', durationMin: 10),
      CourseLesson(id: 2, courseId: widget.courseId ?? 0, title: '感官发展游戏', description: '多感官综合刺激', durationMin: 10),
      CourseLesson(id: 3, courseId: widget.courseId ?? 0, title: '亲子互动练习', description: '增进亲子关系的活动', durationMin: 15),
      CourseLesson(id: 4, courseId: widget.courseId ?? 0, title: '综合能力提升', description: '综合能力训练', durationMin: 15),
    ];
  }

  List<CourseLesson> _buildSkeletonLessons() {
    return List.generate(4, (i) => CourseLesson(
      id: i, courseId: widget.courseId ?? 0, title: '加载中...', durationMin: 0,
    ));
  }
}
