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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
            onPressed: () => showSnackBar(context, '设置功能开发中'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // User Profile Header
          GestureDetector(
            onTap: () {
              if (!authProvider.isLoggedIn) {
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
            onActivate: () => showSnackBar(context, '会员功能开发中'),
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

          _settingItem(Icons.notifications_outlined, '消息通知', () => showSnackBar(context, '开发中')),
          _settingItem(Icons.cloud_sync_outlined, '数据同步', () => showSnackBar(context, '开发中')),
          _settingItem(Icons.shield_outlined, '隐私设置', () => showSnackBar(context, '开发中')),
          _settingItem(Icons.info_outline, '关于我们', () => showSnackBar(context, '小树成长 v1.0.0')),

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
      child: const Column(
        children: [
          Text('👶', style: TextStyle(fontSize: 28)),
          SizedBox(height: 6),
          Text(
            '还没有添加宝宝',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '添加宝宝信息开始记录成长',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
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
