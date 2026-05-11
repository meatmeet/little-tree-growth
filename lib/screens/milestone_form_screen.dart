import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/growth_record.dart';
import '../providers/growth_provider.dart';
import '../providers/baby_provider.dart';

class MilestoneFormScreen extends StatefulWidget {
  const MilestoneFormScreen({super.key});

  @override
  State<MilestoneFormScreen> createState() => _MilestoneFormScreenState();
}

class _MilestoneFormScreenState extends State<MilestoneFormScreen> {
  String _selectedType = 'first_word';
  DateTime _occurredAt = DateTime.now();
  final _notesController = TextEditingController();
  bool _saving = false;

  static const _types = [
    {'key': 'first_teeth', 'label': '第一颗牙', 'icon': '🦷'},
    {'key': 'first_roll', 'label': '第一次翻身', 'icon': '🔄'},
    {'key': 'first_sit', 'label': '第一次坐', 'icon': '🪑'},
    {'key': 'first_crawl', 'label': '第一次爬', 'icon': '🐛'},
    {'key': 'first_stand', 'label': '第一次站立', 'icon': '🧍'},
    {'key': 'first_walk', 'label': '第一次走路', 'icon': '🚶'},
    {'key': 'first_word', 'label': '第一个词', 'icon': '🗣'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: '选择发生日期',
      cancelText: '取消',
      confirmText: '确认',
    );
    if (picked != null) {
      setState(() => _occurredAt = picked);
    }
  }

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().currentBaby;
    if (baby == null) {
      showSnackBar(context, '请先选择宝宝');
      return;
    }

    setState(() => _saving = true);

    final milestone = Milestone(
      id: 0,
      babyId: baby.id,
      milestoneType: _selectedType,
      occurredAt: _occurredAt,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final ok = await context.read<GrowthProvider>().addMilestone(milestone);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop();
        showSnackBar(context, '里程碑已记录');
      } else {
        showSnackBar(context, '保存失败，请重试');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加里程碑')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('选择类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) {
              final key = t['key']! as String;
              final label = t['label']! as String;
              final icon = t['icon']! as String;
              final selected = _selectedType == key;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryBg : AppTheme.bgMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.primary : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Date
          const Text('发生日期', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    '${_occurredAt.year}-${_occurredAt.month.toString().padLeft(2, '0')}-${_occurredAt.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Notes
          const Text('备注', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '记录这一刻的心情...',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
              ),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('保存里程碑'),
            ),
          ),
        ],
      ),
    );
  }
}
