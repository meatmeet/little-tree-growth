import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/baby_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/measure_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTodayTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final babyProvider = context.watch<BabyProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final baby = babyProvider.currentBaby;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baby != null ? '${baby.name} 的成长' : '小树成长',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            taskProvider.loadTodayTasks(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Streak Card
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StreakCard(
                streakDays: taskProvider.streakDays,
                totalDays: taskProvider.streakDays,
                onCheckin: () => taskProvider.checkin(),
              ),
            ),

            // Task Progress Header
            if (taskProvider.totalCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '今日任务',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${taskProvider.completedCount}/${taskProvider.totalCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Today's Tasks
            if (taskProvider.loading && taskProvider.todayTasks.isEmpty)
              ...List.generate(3, (_) => _taskSkeleton())
            else if (taskProvider.todayTasks.isEmpty)
              _emptyTasks()
            else
              ...taskProvider.todayTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: task,
                    onToggle: () => taskProvider.toggleTask(task),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Quick Growth Stats
            Row(
              children: [
                const Text(
                  '最近生长',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('查看全部',
                      style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MeasureCard(
                    label: '身高',
                    value: '--',
                    unit: 'cm',
                    icon: Icons.straighten,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MeasureCard(
                    label: '体重',
                    value: '--',
                    unit: 'kg',
                    icon: Icons.monitor_weight,
                    color: AppTheme.warm,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MeasureCard(
                    label: '头围',
                    value: '--',
                    unit: 'cm',
                    icon: Icons.circle_outlined,
                    color: AppTheme.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                _actionButton('记录成长', Icons.edit_note, AppTheme.primary),
                const SizedBox(width: 12),
                _actionButton('开始评测', Icons.assessment, AppTheme.warm),
                const SizedBox(width: 12),
                _actionButton('里程碑', Icons.emoji_events_outlined, AppTheme.info),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.bgMuted,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _emptyTasks() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text('🌿', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            '今天没有任务计划',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '陪宝宝一起玩耍就是最好的成长',
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
