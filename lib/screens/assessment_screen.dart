import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/assessment.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<BabyProvider>().currentBaby;
      if (baby != null) {
        context.read<AssessmentProvider>().loadAssessments(baby.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().currentBaby;
    final provider = context.watch<AssessmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('发育评测'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (baby != null) {
            await provider.loadAssessments(baby.id);
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Baby Age Header
            if (baby != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryPale),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('👶', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            baby.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${baby.ageDisplay} · 建议使用 ${_getStandardAgeGroup(baby.ageInMonths)} 月龄标准',
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

            const SizedBox(height: 16),

            // Start Assessment Button
            GestureDetector(
              onTap: () => _startAssessment(context, baby),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      '开始新评测',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Assessment History
            if (provider.assessments.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '历史评测',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

            if (provider.loading && provider.assessments.isEmpty)
              ...List.generate(3, (_) => _assessmentSkeleton())
            else if (provider.assessments.isEmpty)
              _emptyState()
            else
              ...provider.assessments.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _assessmentCard(a),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _assessmentCard(AssessmentModel assessment) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(assessment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(assessment.status),
                    color: _getStatusColor(assessment.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${assessment.assessmentDate.month}/${assessment.assessmentDate.day} 评测',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '实际月龄 ${assessment.actualAgeMonths.toStringAsFixed(1)}个月',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (assessment.overallDq != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _dqColor(assessment.overallDq!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          assessment.overallDq!.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _dqColor(assessment.overallDq!),
                          ),
                        ),
                        Text(
                          assessment.dqLevel,
                          style: TextStyle(
                            fontSize: 10,
                            color: _dqColor(assessment.overallDq!),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '待完成',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
              ],
            ),
            if (assessment.areas != null && assessment.areas!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: assessment.areas!.map((area) {
                    final color = AppTheme.getAreaColor(area.area);
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppTheme.getAreaIcon(area.area),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            area.dqScore?.toStringAsFixed(0) ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startAssessment(BuildContext context, dynamic baby) {
    if (baby == null) return;
    // TODO: Navigate to assessment flow
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.success;
      case 'in_progress':
        return AppTheme.warning;
      default:
        return AppTheme.textTertiary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.timer;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color _dqColor(double dq) {
    if (dq >= 130) return AppTheme.success;
    if (dq >= 110) return AppTheme.primaryLight;
    if (dq >= 80) return AppTheme.warning;
    if (dq >= 70) return Colors.deepOrange;
    return AppTheme.danger;
  }

  int _getStandardAgeGroup(int months) {
    if (months <= 12) return months;
    if (months <= 36) return ((months + 2) ~/ 3) * 3;
    return ((months + 5) ~/ 6) * 6;
  }

  Widget _assessmentSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.bgMuted,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
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
          Text('📋', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            '还没有评测记录',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '开始第一次发育评测吧',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
