import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 32),
          // Logo
          const Center(
            child: Text('🌱', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '小树成长',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '0-6岁家庭智力发展平台',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 24),

          // Feature list
          _infoItem(Icons.check_circle_outline, '基于发育科学标准的智能评测'),
          _infoItem(Icons.check_circle_outline, '个性化每日成长任务推荐'),
          _infoItem(Icons.check_circle_outline, '专业课程体系，覆盖五大能区'),
          _infoItem(Icons.check_circle_outline, '生长曲线追踪，WHO 标准参考'),
          _infoItem(Icons.check_circle_outline, '里程碑记录，珍藏成长瞬间'),

          const SizedBox(height: 32),

          // Version
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                _rowItem('版本号', 'v1.0.0'),
                const Divider(height: 20),
                GestureDetector(
                  onTap: () => showSnackBar(context, '用户协议'),
                  child: _rowItem('用户协议', '查看 →'),
                ),
                const Divider(height: 20),
                GestureDetector(
                  onTap: () => showSnackBar(context, '隐私政策'),
                  child: _rowItem('隐私政策', '查看 →'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Center(
            child: Text(
              'Copyright © 2024 小树成长\nAll Rights Reserved.',
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textPrimary)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                color: label == '版本号'
                    ? AppTheme.textSecondary
                    : AppTheme.primary,
                fontWeight:
                    label == '版本号' ? FontWeight.w400 : FontWeight.w600)),
      ],
    );
  }
}
