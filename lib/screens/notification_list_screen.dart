import 'package:flutter/material.dart';
import '../utils/theme.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data — server doesn't have notifications endpoint yet
    final notifications = [
      _NotificationItem(
        icon: '🌱',
        title: '欢迎使用小树成长',
        subtitle: '开始记录宝宝的成长之旅吧！',
        time: '刚刚',
        isNew: true,
      ),
      _NotificationItem(
        icon: '📋',
        title: '今日任务已更新',
        subtitle: '查看今天的成长任务',
        time: '2小时前',
        isNew: true,
      ),
      _NotificationItem(
        icon: '📈',
        title: '生长记录提醒',
        subtitle: '该记录宝宝的最新身高体重了',
        time: '昨天',
        isNew: false,
      ),
      _NotificationItem(
        icon: '📚',
        title: '新课程上线',
        subtitle: '认知发展系列课程已更新',
        time: '2天前',
        isNew: false,
      ),
      _NotificationItem(
        icon: '🎯',
        title: '里程碑达成',
        subtitle: '宝宝学会了新的技能！',
        time: '3天前',
        isNew: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('消息通知')),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔔', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('暂无通知',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _notificationTile(n);
              },
            ),
    );
  }

  Widget _notificationTile(_NotificationItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isNew
                  ? AppTheme.primaryBg
                  : AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              item.isNew ? FontWeight.w700 : FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (item.isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isNew;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isNew = false,
  });
}
