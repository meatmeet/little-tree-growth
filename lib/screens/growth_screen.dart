import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/growth_record.dart';
import '../providers/baby_provider.dart';
import '../providers/growth_provider.dart';
import '../widgets/measure_card.dart';
import 'growth_record_form_screen.dart';
import 'milestone_form_screen.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = context.read<BabyProvider>().currentBaby;
      if (baby != null) {
        context.read<GrowthProvider>().loadRecords(baby.id);
        context.read<GrowthProvider>().loadMilestones(baby.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().currentBaby;
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长记录'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textTertiary,
          tabs: const [
            Tab(text: '记录'),
            Tab(text: '里程碑'),
            Tab(text: '图表'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecordsTab(baby: baby),
          _MilestonesTab(baby: baby),
          _ChartsTab(baby: baby),
        ],
      ),
    );
  }
}

// --- Records Tab ---
class _RecordsTab extends StatelessWidget {
  final dynamic baby;
  const _RecordsTab({this.baby});

  @override
  Widget build(BuildContext context) {
    final growth = context.watch<GrowthProvider>();
    final latest = growth.latestRecord;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Add
        GestureDetector(
          onTap: () => pushScreen(context, const GrowthRecordFormScreen()),
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
                Icon(Icons.add, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  '记录生长数据',
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

        // Latest Measurements
        const Text(
          '最近测量',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MeasureCard(
                label: '身高',
                value: latest?.heightCm?.toStringAsFixed(1) ?? '--',
                unit: 'cm',
                icon: Icons.straighten,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MeasureCard(
                label: '体重',
                value: latest?.weightKg?.toStringAsFixed(1) ?? '--',
                unit: 'kg',
                icon: Icons.monitor_weight,
                color: AppTheme.warm,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MeasureCard(
                label: '头围',
                value: latest?.headCircCm?.toStringAsFixed(1) ?? '--',
                unit: 'cm',
                icon: Icons.circle_outlined,
                color: AppTheme.info,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // History List
        const Text(
          '历史记录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // History List
        if (growth.records.isNotEmpty)
          ...growth.records.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _recordRow(r),
          ))
        else
          _emptyRecords(),
      ],
    );
  }

  Widget _recordRow(GrowthRecord r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Text('${r.recordDate.month}/${r.recordDate.day}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(width: 16),
          if (r.heightCm != null) ...[
            const Icon(Icons.straighten, size: 14, color: AppTheme.primary),
            const SizedBox(width: 2),
            Text('${r.heightCm!.toStringAsFixed(1)}cm', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(width: 10),
          ],
          if (r.weightKg != null) ...[
            const Icon(Icons.monitor_weight, size: 14, color: AppTheme.warm),
            const SizedBox(width: 2),
            Text('${r.weightKg!.toStringAsFixed(1)}kg', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(width: 10),
          ],
          if (r.headCircCm != null) ...[
            const Icon(Icons.circle_outlined, size: 14, color: AppTheme.info),
            const SizedBox(width: 2),
            Text('${r.headCircCm!.toStringAsFixed(1)}cm', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _emptyRecords() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text('📏', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            '还没有生长记录',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '记录宝宝的身高、体重和头围变化',
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

// --- Milestones Tab ---
class _MilestonesTab extends StatelessWidget {
  final dynamic baby;
  const _MilestonesTab({this.baby});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add milestone button
        GestureDetector(
          onTap: () => pushScreen(context, const MilestoneFormScreen()),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.primaryBg,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppTheme.primary, size: 20),
                SizedBox(width: 6),
                Text(
                  '添加里程碑',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          '成长里程碑',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Timeline
        _emptyMilestones(),
      ],
    );
  }

  Widget _emptyMilestones() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text('⭐', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            '还没有里程碑',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '记录宝宝的每一个第一次',
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

// --- Charts Tab ---
class _ChartsTab extends StatelessWidget {
  final dynamic baby;
  const _ChartsTab({this.baby});

  @override
  Widget build(BuildContext context) {
    final areas = ['gross_motor', 'fine_motor', 'language', 'adaptation', 'social'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '生长曲线',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Chart placeholders
        ...['身高', '体重', '头围'].map((label) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label生长曲线',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'WHO 生长标准',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.bgMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '📈 图表区域',
                      style: TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),

        const SizedBox(height: 20),

        // Developmental Area Radar
        const Text(
          '发育评估概览',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '五大能区',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...areas.map((area) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      AppTheme.getAreaIcon(area),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        AppTheme.getAreaName(area),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: 0,
                          backgroundColor: AppTheme.bgMuted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getAreaColor(area),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '--',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
