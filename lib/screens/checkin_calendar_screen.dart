import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/baby_provider.dart';
import '../providers/task_provider.dart';

class CheckinCalendarScreen extends StatefulWidget {
  const CheckinCalendarScreen({super.key});

  @override
  State<CheckinCalendarScreen> createState() => _CheckinCalendarScreenState();
}

class _CheckinCalendarScreenState extends State<CheckinCalendarScreen> {
  late DateTime _currentMonth;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final baby = context.read<BabyProvider>().currentBaby;
    if (baby != null) {
      final month =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
      await context.read<TaskProvider>().loadCalendar(baby.id, month: month);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final checkinDates = taskProvider.calendarData
        .map((d) => d['checkin_date'] as String? ?? '')
        .toSet();

    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == _currentMonth.year && today.month == _currentMonth.month;

    return Scaffold(
      appBar: AppBar(title: const Text('打卡日历')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Streak summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '连续打卡',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${taskProvider.streakDays} 天',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calendar header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Text(
                '${_currentMonth.year}年${_currentMonth.month}月',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Weekday headers
          Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
            else
            ..._buildWeeks(daysInMonth, firstWeekday, checkinDates, isCurrentMonth, today.day),

          const SizedBox(height: 24),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green, '已打卡'),
              const SizedBox(width: 20),
              _legendItem(AppTheme.bgMuted, '未打卡'),
              const SizedBox(width: 20),
              _legendItem(AppTheme.primary, '今天'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(
    int daysInMonth,
    int firstWeekday,
    Set<String> checkinDates,
    bool isCurrentMonth,
    int todayDay,
  ) {
    final weeks = <Widget>[];
    var day = 1;
    var cells = <Widget>[];

    // Empty cells before first day
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const Expanded(child: SizedBox(height: 42)));
    }

    while (day <= daysInMonth) {
      if (cells.length == 7) {
        weeks.add(Row(children: cells));
        weeks.add(const SizedBox(height: 4));
        cells = [];
      }

      final dateStr = '${_currentMonth.year}-'
          '${_currentMonth.month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
      final isChecked = checkinDates.contains(dateStr);
      final isToday = isCurrentMonth && day == todayDay;

      cells.add(Expanded(
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isChecked
                ? Colors.green.withValues(alpha: 0.15)
                : (isToday
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : null),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppTheme.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isChecked || isToday ? FontWeight.w700 : FontWeight.w400,
                color: isChecked
                    ? Colors.green
                    : (isToday
                        ? AppTheme.primary
                        : AppTheme.textPrimary),
              ),
            ),
          ),
        ),
      ));

      day++;
    }

    // Fill remaining cells
    while (cells.length < 7) {
      cells.add(const Expanded(child: SizedBox(height: 42)));
    }
    weeks.add(Row(children: cells));

    return weeks;
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: color == AppTheme.bgMuted ? 1 : 0.2),
            borderRadius: BorderRadius.circular(3),
            border: color == AppTheme.primary
                ? Border.all(color: AppTheme.primary, width: 2)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
