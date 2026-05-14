import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../providers/assessment_provider.dart';
import 'assessment_detail_screen.dart';

class AssessmentQuizScreen extends StatefulWidget {
  final int assessmentId;
  final int ageGroup;

  const AssessmentQuizScreen({
    super.key,
    required this.assessmentId,
    required this.ageGroup,
  });

  @override
  State<AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<AssessmentQuizScreen> {
  List<Map<String, dynamic>> _items = [];
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _results = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final provider = context.read<AssessmentProvider>();
    await provider.loadItems(widget.ageGroup);
    if (!mounted) return;
    setState(() {
      _items = provider.items;
      _loading = false;
    });
  }

  void _answer(bool passed) {
    final item = _items[_currentIndex];
    _results.add({
      'area': item['area'] as String? ?? '',
      'item_code': item['item_code'] as String? ?? '',
      'age_group': widget.ageGroup,
      'passed': passed,
    });

    if (_currentIndex < _items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final provider = context.read<AssessmentProvider>();
    final result = await provider.submitResults(widget.assessmentId, _results);
    if (!mounted) return;
    if (result != null) {
      pushReplacementScreen(
        context,
        AssessmentDetailScreen(assessment: result),
      );
    } else {
      showSnackBar(context, provider.error ?? '提交失败，请重试');
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发育评测'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _emptyState()
              : _buildQuiz(),
    );
  }

  Widget _buildQuiz() {
    final item = _items[_currentIndex];
    final progress = (_currentIndex + 1) / _items.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.bgMuted,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentIndex + 1}/${_items.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Area indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.getAreaColor(item['area'] as String? ?? '')
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${AppTheme.getAreaIcon(item['area'] as String? ?? '')} ${AppTheme.getAreaName(item['area'] as String? ?? '')}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getAreaColor(item['area'] as String? ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                Text(
                  item['item_label'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (item['description'] != null &&
                    (item['description'] as String).isNotEmpty)
                  Text(
                    item['description'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Standard reference
          if (item['standard'] != null &&
              (item['standard'] as String).isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['standard'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Answer buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : () => _answer(true),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text('能完成',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _submitting ? null : () => _answer(false),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('还不能完成',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.textTertiary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_submitting)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            '暂无可用的评测项目',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '该月龄段没有配置评测标准',
            style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

}
