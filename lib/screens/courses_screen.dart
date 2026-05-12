import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../providers/baby_provider.dart';
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
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().currentBaby;
    final filterLabel = _ageFilters[_selectedFilter];

    return Scaffold(
      appBar: AppBar(
        title: const Text('成长课程'),
      ),
      body: ListView(
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('📚', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${baby.name} 的课程',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${baby.ageDisplay} · 共 ${_getCourseCount(baby.ageInMonths)} 个课程',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.bgMuted,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _ageFilters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppTheme.textSecondary,
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
          const Text(
            '推荐课程',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _featuredCourse(
            icon: '🧩',
            title: '认知启蒙',
            subtitle: '通过游戏激发宝宝的好奇心与探索欲',
            color: AppTheme.areaAdaptation,
            onTap: () => pushScreen(context, const CourseDetailScreen(
              title: '认知启蒙',
              subtitle: '通过游戏激发宝宝的好奇心与探索欲',
              ageRange: '0-3岁',
              color: AppTheme.areaAdaptation,
            )),
          ),
          const SizedBox(height: 8),
          _featuredCourse(
            icon: '🏃',
            title: '大运动发展',
            subtitle: '从翻身到走路，逐步提升运动能力',
            color: AppTheme.areaGrossMotor,
            onTap: () => pushScreen(context, const CourseDetailScreen(
              title: '大运动发展',
              subtitle: '从翻身到走路，逐步提升运动能力',
              ageRange: '0-6岁',
              color: AppTheme.areaGrossMotor,
            )),
          ),
          const SizedBox(height: 8),
          _featuredCourse(
            icon: '🗣',
            title: '语言启蒙',
            subtitle: '听说读写全方位语言能力培养',
            color: AppTheme.areaLanguage,
            onTap: () => pushScreen(context, const CourseDetailScreen(
              title: '语言启蒙',
              subtitle: '听说读写全方位语言能力培养',
              ageRange: '0-6岁',
              color: AppTheme.areaLanguage,
            )),
          ),

          const SizedBox(height: 20),

          // Course list
          const Text(
            '全部课程',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CourseItem(
              title: _demoCourses[i]['title'] as String,
              subtitle: _demoCourses[i]['subtitle'] as String,
              progressText: '${(_demoCourses[i]['progress'] as num).toInt()}%',
              progress: (_demoCourses[i]['progress'] as num) / 100,
              onTap: () => pushScreen(context, CourseDetailScreen(
                title: _demoCourses[i]['title'] as String,
                subtitle: _demoCourses[i]['subtitle'] as String,
                ageRange: filterLabel,
              )),
            ),
          )),

          const SizedBox(height: 24),
        ],
      ),
    );
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  int _getCourseCount(int ageMonths) {
    if (ageMonths <= 6) return 8;
    if (ageMonths <= 12) return 12;
    if (ageMonths <= 24) return 16;
    if (ageMonths <= 36) return 20;
    return 24;
  }
}

const List<Map<String, Object?>> _demoCourses = [
  {'title': '感官探索', 'subtitle': '视觉、听觉、触觉综合开发', 'progress': 60},
  {'title': '亲子互动', 'subtitle': '增进亲子关系的趣味游戏', 'progress': 30},
  {'title': '音乐律动', 'subtitle': '节奏感与音乐欣赏能力培养', 'progress': 0},
  {'title': '创意手工', 'subtitle': '动手能力与创造力开发', 'progress': 0},
];
