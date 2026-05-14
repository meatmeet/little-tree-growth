import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _allowAnalysis = true;
  bool _showOnLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _allowAnalysis = prefs.getBool('privacy_allow_analysis') ?? true;
      _showOnLeaderboard = prefs.getBool('privacy_show_leaderboard') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                _switchRow(
                  '允许数据分析',
                  '帮助我们改进产品和服务',
                  Icons.analytics_outlined,
                  _allowAnalysis,
                  (v) {
                    setState(() => _allowAnalysis = v);
                    _save('privacy_allow_analysis', v);
                  },
                ),
                const Divider(height: 24),
                _switchRow(
                  '显示在排行榜',
                  '与其他宝宝一起参与排名',
                  Icons.leaderboard_outlined,
                  _showOnLeaderboard,
                  (v) {
                    setState(() => _showOnLeaderboard = v);
                    _save('privacy_show_leaderboard', v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '您的数据仅用于为您提供个性化服务，不会分享给第三方。\n'
              '我们使用加密传输保护您的信息安全。',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
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
    );
  }
}
