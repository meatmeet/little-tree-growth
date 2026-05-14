import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _taskReminder = true;
  bool _growthReminder = true;
  bool _courseUpdate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _taskReminder = prefs.getBool('notify_task_reminder') ?? true;
      _growthReminder = prefs.getBool('notify_growth_reminder') ?? true;
      _courseUpdate = prefs.getBool('notify_course_update') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息通知')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _switchItem(
            '每日任务提醒',
            '每天推送今日成长任务',
            Icons.task_alt,
            _taskReminder,
            (v) {
              setState(() => _taskReminder = v);
              _save('notify_task_reminder', v);
            },
          ),
          _switchItem(
            '成长记录提醒',
            '提醒记录宝宝生长数据',
            Icons.monitor_weight_outlined,
            _growthReminder,
            (v) {
              setState(() => _growthReminder = v);
              _save('notify_growth_reminder', v);
            },
          ),
          _switchItem(
            '课程更新提醒',
            '新课程上线时通知',
            Icons.auto_stories,
            _courseUpdate,
            (v) {
              setState(() => _courseUpdate = v);
              _save('notify_course_update', v);
            },
          ),
        ],
      ),
    );
  }

  Widget _switchItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
