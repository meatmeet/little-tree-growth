import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import 'notification_settings_screen.dart';
import 'data_sync_screen.dart';
import 'privacy_settings_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('通知与数据',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                _tile(Icons.notifications_outlined, '消息通知',
                    () => pushScreen(context, const NotificationSettingsScreen())),
                _divider(),
                _tile(Icons.cloud_sync_outlined, '数据同步',
                    () => pushScreen(context, const DataSyncScreen())),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('隐私与关于',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                _tile(Icons.shield_outlined, '隐私设置',
                    () => pushScreen(context, const PrivacySettingsScreen())),
                _divider(),
                _tile(Icons.info_outline, '关于我们',
                    () => pushScreen(context, const AboutScreen())),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text('小树成长 v1.0.0',
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15, color: AppTheme.textPrimary)),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 48),
      child: Divider(height: 1, color: Color(0xFFF5F5F5)),
    );
  }
}
