import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? ageRange;
  final Color? color;

  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.ageRange,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppTheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_stories, size: 32, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (ageRange != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '适合 $ageRange',
                      style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '课程简介',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            '本课程通过科学设计的游戏活动，促进宝宝在对应能区的发展。建议家长每天安排15-30分钟，在轻松愉快的氛围中与宝宝互动。',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),

          const SizedBox(height: 20),

          const Text(
            '课程内容',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          ...List.generate(4, (i) => Padding(
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w700, color: accentColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lessonTitles[i],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, size: 18, color: AppTheme.textTertiary),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

const _lessonTitles = [
  '基础认知训练',
  '感官发展游戏',
  '亲子互动练习',
  '综合能力提升',
];
