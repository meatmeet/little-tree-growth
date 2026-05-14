import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../providers/baby_provider.dart';
import '../providers/auth_provider.dart';
import '../models/baby.dart';
import '../widgets/vip_card.dart';
import 'login_screen.dart';
import 'baby_form_screen.dart';
import 'vip_purchase_screen.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'data_sync_screen.dart';
import 'privacy_settings_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BabyProvider>().loadBabies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final babyProvider = context.watch<BabyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final baby = babyProvider.currentBaby;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () => pushScreen(context, const SettingsScreen()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<BabyProvider>().loadBabies(),
        child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // User Profile Header
          GestureDetector(
            onTap: () {
              if (authProvider.isLoggedIn) {
                pushScreen(context, const ProfileEditScreen());
              } else {
                pushScreen(context, const LoginScreen());
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPale,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: user != null && user.nickname != null
                          ? Text(user.nickname![0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primary))
                          : const Icon(Icons.person, color: AppTheme.primary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nickname ?? (user != null ? user.phone : '点击登录'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user != null ? '已登录' : '登录后可同步全部数据',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!authProvider.isLoggedIn)
                    const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // VIP Card
          VipCard(
            isVip: authProvider.isVip,
            expireAt: user?.vipExpireAt,
            onActivate: () => pushScreen(context, const VipPurchaseScreen()),
          ),

          const SizedBox(height: 20),

          // Baby Management Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的宝宝',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => pushScreen(context, const BabyFormScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.primary),
                      SizedBox(width: 2),
                      Text(
                        '添加宝宝',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Baby List
          if (babyProvider.babies.isEmpty)
            _emptyBaby()
          else
            ...babyProvider.babies.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _babyCard(b, b.id == baby?.id),
            )),

          const SizedBox(height: 24),

          // Stats Entry
          GestureDetector(
            onTap: () => pushScreen(context, const StatsScreen()),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryPale),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 22, color: AppTheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '成长统计',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Settings Menu
          const Text(
            '设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          _settingItem(Icons.notifications_outlined, '消息通知', () => pushScreen(context, const NotificationSettingsScreen())),
          _settingItem(Icons.cloud_sync_outlined, '数据同步', () => pushScreen(context, const DataSyncScreen())),
          _settingItem(Icons.shield_outlined, '隐私设置', () => pushScreen(context, const PrivacySettingsScreen())),
          _settingItem(Icons.info_outline, '关于我们', () => pushScreen(context, const AboutScreen())),

          // Logout
          if (authProvider.isLoggedIn) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('退出登录'),
                      content: const Text('确定要退出登录吗？退出后需要重新登录。'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('取消')),
                        TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('确定',
                                style: TextStyle(color: AppTheme.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('退出登录',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Version
          const Center(
            child: Text(
              '小树成长 v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textTertiary,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }

  Widget _babyCard(BabyModel baby, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<BabyProvider>().selectBaby(baby),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFF0F0F0),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected ? AppTheme.shadowSm : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: baby.avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        baby.avatarUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Text('👶', style: TextStyle(fontSize: 22)),
                      ),
                    )
                  : const Text('👶', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '当前',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${baby.gender == 0 ? "女宝" : "男宝"} · ${baby.ageDisplay}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppTheme.textTertiary),
              onPressed: () => pushScreen(context, BabyFormScreen(baby: baby)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBaby() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Consumer<BabyProvider>(
        builder: (context, bp, _) => Column(
          children: [
            if (bp.loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            const Text('👶', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            const Text(
              '还没有添加宝宝',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '添加宝宝信息开始记录成长',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
            if (bp.error != null) ...[
              const SizedBox(height: 8),
              Text(
                bp.error!,
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => bp.loadBabies(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '重新加载',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            // Debug info when list is empty but load has completed
            if (!bp.loading && bp.hasLoaded && bp.babies.isEmpty && bp.error == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '没有查到宝宝数据（已加载完成）',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

}
