import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/assessment.dart';

class AssessmentDetailScreen extends StatelessWidget {
  final AssessmentModel assessment;

  const AssessmentDetailScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final areas = assessment.areas ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${assessment.assessmentDate.month}/${assessment.assessmentDate.day} 评测结果'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score header
          if (assessment.overallDq != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.dqColor(assessment.overallDq!),
                    AppTheme.dqColor(assessment.overallDq!).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Column(
                children: [
                  const Text(
                    '整体发育商 (DQ)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assessment.overallDq!.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assessment.dqLevel,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (assessment.overallMentalAge != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '智龄: ${assessment.overallMentalAge!.toStringAsFixed(1)}个月',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.timer, size: 40, color: AppTheme.warning),
                  SizedBox(height: 8),
                  Text('评测进行中', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                  SizedBox(height: 4),
                  Text('完成所有项目后将自动生成报告', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Info row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                _infoItem('评测日期', '${assessment.assessmentDate.month}/${assessment.assessmentDate.day}'),
                Container(width: 1, height: 30, color: const Color(0xFFF0F0F0)),
                _infoItem('实际月龄', '${assessment.actualAgeMonths.toStringAsFixed(0)}个月'),
                Container(width: 1, height: 30, color: const Color(0xFFF0F0F0)),
                _infoItem('状态', assessment.status == 'completed' ? '已完成' : '进行中'),
              ],
            ),
          ),

          if (areas.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('五大能区', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            ...areas.map((area) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _areaRow(area),
            )),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _areaRow(AreaResult area) {
    final color = AppTheme.getAreaColor(area.area);
    final score = area.dqScore;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Text(AppTheme.getAreaIcon(area.area), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTheme.getAreaName(area.area),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: score != null ? (score / 150).clamp(0, 1) : 0,
                    backgroundColor: AppTheme.bgMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            score?.toStringAsFixed(0) ?? '--',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

}
