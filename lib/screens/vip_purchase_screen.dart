import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class VipPurchaseScreen extends StatefulWidget {
  const VipPurchaseScreen({super.key});

  @override
  State<VipPurchaseScreen> createState() => _VipPurchaseScreenState();
}

class _VipPurchaseScreenState extends State<VipPurchaseScreen> {
  final ApiService _api = ApiService();
  bool _isYearly = false;
  bool _purchasing = false;

  Future<void> _purchase() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      showSnackBar(context, '请先登录');
      return;
    }

    setState(() => _purchasing = true);

    try {
      // Simulate payment delay
      await Future.delayed(const Duration(seconds: 1));

      await _api.post('/subscriptions', body: {
        'plan_type': _isYearly ? 'yearly' : 'monthly',
        'payment_method': 'apple_pay',
      });

      if (!mounted) return;
      await auth.refreshVipStatus();
      if (!mounted) return;
      showSnackBar(context, '开通成功！');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnackBar(context, '开通失败，请重试');
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthlyPrice = AppConstants.monthlyPrice;
    final yearlyPrice = AppConstants.yearlyPrice;
    final yearlyUnit = yearlyPrice / 12;
    final yearlyDiscount =
        ((1 - yearlyPrice / (monthlyPrice * 12)) * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('开通 VIP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.shadowMd,
            ),
            child: const Column(
              children: [
                Icon(Icons.workspace_premium, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  '小树成长 VIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '解锁全部课程与评测功能',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Plan selector
          Row(
            children: [
              Expanded(
                child: _planCard(
                  title: '月卡',
                  price: '¥$monthlyPrice',
                  unit: '/月',
                  selected: !_isYearly,
                  onTap: () => setState(() => _isYearly = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _planCard(
                  title: '年卡',
                  price: '¥$yearlyPrice',
                  unit: '/年',
                  selected: _isYearly,
                  badge: '省$yearlyDiscount%',
                  onTap: () => setState(() => _isYearly = true),
                ),
              ),
            ],
          ),

          if (_isYearly)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '平均仅 ¥${yearlyUnit.toStringAsFixed(0)}/月',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.warm,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          // Benefits
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '会员权益',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                _BenefitRow(icon: '📚', text: '解锁全部专业课程'),
                _BenefitRow(icon: '📋', text: '无限次发育评测'),
                _BenefitRow(icon: '📈', text: '完整成长趋势分析'),
                _BenefitRow(icon: '🎯', text: '个性化任务推荐'),
                _BenefitRow(icon: '💾', text: '云端数据同步'),
                _BenefitRow(icon: '🚫', text: '无广告体验'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Purchase button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _purchasing ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warm,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _purchasing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isYearly
                          ? '¥$yearlyPrice 开通年卡'
                          : '¥$monthlyPrice 开通月卡',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              '购买即表示同意《用户协议》和《隐私政策》',
              style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String unit,
    required bool selected,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBg : AppTheme.bgMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFF0F0F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warm,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
