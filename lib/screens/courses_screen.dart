import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/course.dart';
import '../providers/baby_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/course_item.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _selectedFilter = 0;
  final _ageFilters = ['0-6个月', '6-12个月', '1-2岁', '2-3岁', '3-6岁'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  int _filterToAgeMonths(int index) {
    switch (index) {
      case 0: return 3;
      case 1: return 9;
      case 2: return 18;
      case 3: return 30;
      case 4: return 54;
      default: return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().currentBaby;
    final courseProvider = context.watch<CourseProvider>();
    final allCourses = courseProvider.courses;

    // Filter courses by selected age filter
    final targetAge = _filterToAgeMonths(_selectedFilter);
    final filteredCourses = allCourses.where((c) {
      if (c.ageGroupMin == null || c.ageGroupMax == null) return true;
      return targetAge >= c.ageGroupMin! && targetAge <= c.ageGroupMax!;
    }).toList();

    // Pick featured: free courses first
    final featured = allCourses.where((c) => c.isFree).take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('成长课程')),
      body: RefreshIndicator(
        onRefresh: () => courseProvider.loadCourses(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Age category header
            if (baby != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryPale),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('📚', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${baby.name} 的课程',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          Text('${baby.ageDisplay} · 共 ${allCourses.length} 个课程',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Age Group Filters
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(_ageFilters.length, (i) {
                  final selected = i == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : AppTheme.bgMuted,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          _ageFilters[i],
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Featured Section
            if (featured.isNotEmpty) ...[
              const Text('推荐课程',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              ...featured.map((course) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _featuredCourse(
                  icon: _courseIcon(course.title),
                  title: course.title,
                  subtitle: course.description,
                  color: _courseColor(course.id),
                  onTap: () => pushScreen(context, CourseDetailScreen(
                    courseId: course.id,
                    title: course.title,
                    subtitle: course.description,
                    ageRange: course.ageGroupMin != null && course.ageGroupMax != null
                        ? '${course.ageGroupMin! ~/ 12}-${course.ageGroupMax! ~/ 12}岁'
                        : null,
                    color: _courseColor(course.id),
                  )),
                ),
              )),
              const SizedBox(height: 20),
            ],

            // Course list
            const Text('全部课程',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),

            if (courseProvider.loading && filteredCourses.isEmpty)
              ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.bgMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ))
            else if (filteredCourses.isEmpty)
              _emptyState()
            else
              ...filteredCourses.map((course) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CourseItem(
                  title: course.title,
                  subtitle: course.description.isNotEmpty
                      ? (course.description.length > 30 ? '${course.description.substring(0, 30)}...' : course.description)
                      : null,
                  progressText: '${course.progress.toStringAsFixed(0)}%',
                  progress: course.progress / 100,
                  onTap: () => pushScreen(context, CourseDetailScreen(
                    courseId: course.id,
                    title: course.title,
                    subtitle: course.description,
                    ageRange: course.ageGroupMin != null && course.ageGroupMax != null
                        ? '${course.ageGroupMin! ~/ 12}-${course.ageGroupMax! ~/ 12}岁'
                        : null,
                    color: _courseColor(course.id),
                  )),
                ),
              )),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _courseIcon(String title) {
    if (title.contains('感官') || title.contains('认知')) return '🧩';
    if (title.contains('运动')) return '🏃';
    if (title.contains('语言')) return '🗣';
    if (title.contains('音乐')) return '🎵';
    if (title.contains('手工') || title.contains('创意')) return '🎨';
    return '📚';
  }

  Color _courseColor(int id) {
    final colors = [AppTheme.areaAdaptation, AppTheme.areaGrossMotor, AppTheme.areaLanguage, AppTheme.areaFineMotor, AppTheme.areaSocial];
    return colors[id % colors.length];
  }

  Widget _featuredCourse({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted, borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text('📚', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text('暂无课程', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          SizedBox(height: 4),
          Text('该月龄段暂无可用的课程', style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }
}
