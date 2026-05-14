import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int _rating = 0;

  bool get _showRating => widget.task.isCompleted;

  @override
  Widget build(BuildContext context) {
    final areaColor = AppTheme.getAreaColor(widget.task.area);

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
                      AppTheme.getAreaName(widget.task.area),
                      style: TextStyle(
                        fontSize: 13,
                        color: areaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.warmBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.task.difficultyLabel,
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
                  widget.task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (widget.task.durationMin > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.task.durationMin}分钟',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
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
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.task.description,
            style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6),
          ),

          if (widget.task.purpose.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '活动目的',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.purpose,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6),
            ),
          ],

          if (widget.task.materialsNeeded != null &&
              widget.task.materialsNeeded!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '所需材料',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.materialsNeeded!,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6),
            ),
          ],

          if (widget.task.tips != null &&
              widget.task.tips!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.info.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 18, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '小贴士',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.info),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.task.tips!,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Rating section (shown after completion)
          if (_showRating) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warmBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    '给这个任务打个分吧',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        icon: Icon(
                          star <= _rating
                              ? Icons.star
                              : Icons.star_border,
                          color: star <= _rating
                              ? AppTheme.warm
                              : AppTheme.textTertiary,
                          size: 32,
                        ),
                        onPressed: () async {
                          setState(() => _rating = star);
                          final ok = await context
                              .read<TaskProvider>()
                              .rateTask(widget.task.id, star);
                          if (mounted) {
                            showSnackBar(
                                context, ok ? '评分已提交' : '评分提交失败');
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Complete toggle
          Consumer<TaskProvider>(
            builder: (context, tp, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    tp.toggleTask(widget.task);
                  },
                  icon: Icon(widget.task.isCompleted
                      ? Icons.undo
                      : Icons.check_circle_outline),
                  label: Text(widget.task.isCompleted
                      ? '标记为未完成'
                      : '标记为已完成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.task.isCompleted
                        ? AppTheme.bgMuted
                        : AppTheme.primary,
                    foregroundColor: widget.task.isCompleted
                        ? AppTheme.textSecondary
                        : Colors.white,
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
