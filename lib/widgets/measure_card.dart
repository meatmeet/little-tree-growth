import 'package:flutter/material.dart';
import '../utils/theme.dart';

class MeasureCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? change;
  final IconData icon;
  final Color? color;

  const MeasureCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.change,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cardColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cardColor,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: change!.startsWith('+')
                        ? AppTheme.primaryPale
                        : change!.startsWith('-')
                            ? AppTheme.warmLight
                            : AppTheme.bgMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    change!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: change!.startsWith('+')
                          ? AppTheme.success
                          : change!.startsWith('-')
                              ? AppTheme.danger
                              : AppTheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
