import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/assessment.dart';
import '../providers/baby_provider.dart';
import '../providers/assessment_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AssessmentDetailScreen extends StatefulWidget {
  final AssessmentModel assessment;

  const AssessmentDetailScreen({super.key, required this.assessment});

  @override
  State<AssessmentDetailScreen> createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<BabyProvider>().currentBaby;
      if (baby != null) {
        context.read<AssessmentProvider>().loadTrend(baby.id);
      }
      context.read<AssessmentProvider>().loadReport(widget.assessment.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final areas = widget.assessment.areas ?? [];
    final trend = context.watch<AssessmentProvider>().trend;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.assessment.assessmentDate.month}/${widget.assessment.assessmentDate.day} 评测结果'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score header
          if (widget.assessment.overallDq != null) ...[
            _buildScoreHeader(),
            const SizedBox(height: 24),
          ] else ...[
            _buildPendingState(),
            const SizedBox(height: 24),
          ],

          // Info row
          _buildInfoRow(),
          const SizedBox(height: 24),

          // Areas
          if (areas.isNotEmpty) ...[
            const Text('五大能区',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            ...areas.map((area) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _areaRow(area),
                )),
            const SizedBox(height: 24),
          ],

          // Report sections (only for completed assessments)
          if (widget.assessment.status == 'completed') ...[
            _reportSections(),
            const SizedBox(height: 24),
          ],

          // Trend chart
          if (trend.length >= 2) ...[
            const Text('发育趋势',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            _trendChart(trend),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.dqColor(widget.assessment.overallDq!),
            AppTheme.dqColor(widget.assessment.overallDq!).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          const Text('整体发育商 (DQ)',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            widget.assessment.overallDq!.toStringAsFixed(0),
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
              widget.assessment.dqLevel,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (widget.assessment.overallMentalAge != null) ...[
            const SizedBox(height: 12),
            Text(
              '智龄: ${widget.assessment.overallMentalAge!.toStringAsFixed(1)}个月',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingState() {
    return Container(
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
          Text('评测进行中',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warning)),
          SizedBox(height: 4),
          Text('完成所有项目后将自动生成报告',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          _infoItem('评测日期',
              '${widget.assessment.assessmentDate.month}/${widget.assessment.assessmentDate.day}'),
          Container(width: 1, height: 30, color: const Color(0xFFF0F0F0)),
          _infoItem('实际月龄',
              '${widget.assessment.actualAgeMonths.toStringAsFixed(0)}个月'),
          Container(width: 1, height: 30, color: const Color(0xFFF0F0F0)),
          _infoItem('状态',
              widget.assessment.status == 'completed' ? '已完成' : '进行中'),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
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
          Text(AppTheme.getAreaIcon(area.area),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppTheme.getAreaName(area.area),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
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
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _reportSections() {
    final ap = context.watch<AssessmentProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reportSection(
          title: '评估亮点',
          icon: Icons.emoji_events,
          color: AppTheme.warm,
          loading: ap.reportLoading,
          error: ap.reportError,
          isEmpty: ap.highlights.isEmpty,
          emptyText: '暂无亮点数据',
          child: Column(
            children: ap.highlights.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: AppTheme.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(h, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _reportSection(
          title: '训练建议',
          icon: Icons.lightbulb_outline,
          color: AppTheme.info,
          loading: ap.reportLoading,
          error: ap.reportError,
          isEmpty: ap.suggestions.isEmpty,
          emptyText: '暂无训练建议',
          child: Column(
            children: ap.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(AppTheme.getAreaIcon(s['area'] as String? ?? ''),
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(s['title'] as String? ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ),
                      ],
                    ),
                    if (s['description'] != null && (s['description'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(s['description'] as String,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
                    ],
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _reportSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool loading,
    required String? error,
    required bool isEmpty,
    required String emptyText,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),
        if (loading)
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ))
        else if (error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppTheme.danger),
                SizedBox(width: 8),
                Expanded(child: Text('加载失败', style: TextStyle(fontSize: 13, color: AppTheme.danger))),
              ],
            ),
          )
        else if (isEmpty)
          Text(emptyText, style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary))
        else
          child,
      ],
    );
  }

  Widget _trendChart(List<Map<String, dynamic>> trendData) {
    final sorted = List<Map<String, dynamic>>.from(trendData)
      ..sort((a, b) => (a['assessment_date'] as String?)
              ?.compareTo(b['assessment_date'] as String? ?? '') ??
          0);

    final spots = <FlSpot>[];
    final labels = <int, String>{};
    for (int i = 0; i < sorted.length; i++) {
      final dq = (sorted[i]['overall_dq'] as num?)?.toDouble();
      if (dq != null) {
        spots.add(FlSpot(i.toDouble(), dq));
        final date = sorted[i]['assessment_date'] as String? ?? '';
        labels[i] = date.length >= 5 ? date.substring(5) : date;
      }
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    final values = spots.map((s) => s.y).toList();
    final yMin = (values.reduce((a, b) => a < b ? a : b) - 10).clamp(0, 999).toDouble();
    final yMax = (values.reduce((a, b) => a > b ? a : b) + 10).clamp(1, 999).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            minY: yMin,
            maxY: yMax,
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: AppTheme.bgMuted, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    final label = labels[idx];
                    if (label == null) return const SizedBox.shrink();
                    if (spots.length > 3 &&
                        idx != 0 &&
                        idx != spots.length - 1) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textTertiary)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.min || value == meta.max) {
                      return const SizedBox.shrink();
                    }
                    return Text(value.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textTertiary));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppTheme.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 3,
                    color: AppTheme.primary,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final idx = spot.spotIndex;
                    final label = labels[idx] ?? '';
                    return LineTooltipItem(
                      '$label\nDQ: ${spot.y.toStringAsFixed(0)}',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    );
                  }).toList();
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
