import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final areaColor = AppTheme.getAreaColor(task.area);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isCompleted
                ? AppTheme.primaryPale
                : const Color(0xFFF0F0F0),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppTheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppTheme.primary
                        : AppTheme.textTertiary,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                      const SizedBox(width: 6),
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${task.durationMin}分钟',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.warmBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.difficultyLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.warm,
                          ),
                        ),
                      ),
                    ],
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
}
