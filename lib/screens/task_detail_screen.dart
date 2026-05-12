import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final areaColor = AppTheme.getAreaColor(task.area);

    return Scaffold(
      appBar: AppBar(
        title: const Text('任务详情'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: areaColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: areaColor.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: areaColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppTheme.getAreaName(task.area),
                      style: TextStyle(
                        fontSize: 13,
                        color: areaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.warmBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.difficultyLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.warm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (task.durationMin > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${task.durationMin}分钟',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description
          const Text(
            '活动内容',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
          ),

          if (task.purpose.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '活动目的',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              task.purpose,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
            ),
          ],

          if (task.materialsNeeded != null && task.materialsNeeded!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '所需材料',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              task.materialsNeeded!,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
            ),
          ],

          if (task.tips != null && task.tips!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '小贴士',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.info),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.tips!,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Complete toggle
          Consumer<TaskProvider>(
            builder: (context, tp, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => tp.toggleTask(task),
                  icon: Icon(task.isCompleted ? Icons.undo : Icons.check_circle_outline),
                  label: Text(task.isCompleted ? '标记为未完成' : '标记为已完成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.isCompleted ? AppTheme.bgMuted : AppTheme.primary,
                    foregroundColor: task.isCompleted ? AppTheme.textSecondary : Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
