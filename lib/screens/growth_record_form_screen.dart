import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/growth_record.dart';
import '../providers/growth_provider.dart';
import '../providers/baby_provider.dart';

class GrowthRecordFormScreen extends StatefulWidget {
  const GrowthRecordFormScreen({super.key});

  @override
  State<GrowthRecordFormScreen> createState() => _GrowthRecordFormScreenState();
}

class _GrowthRecordFormScreenState extends State<GrowthRecordFormScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _headCircController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _recordDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _headCircController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: '选择记录日期',
      cancelText: '取消',
      confirmText: '确认',
    );
    if (picked != null) {
      setState(() => _recordDate = picked);
    }
  }

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().currentBaby;
    if (baby == null) {
      showSnackBar(context, '请先选择宝宝');
      return;
    }

    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final headCirc = double.tryParse(_headCircController.text.trim());
    final notes = _notesController.text.trim();

    if (height == null && weight == null && headCirc == null) {
      showSnackBar(context, '至少填写一项测量数据');
      return;
    }

    setState(() => _saving = true);

    final record = GrowthRecord(
      id: 0,
      babyId: baby.id,
      recordDate: _recordDate,
      heightCm: height,
      weightKg: weight,
      headCircCm: headCirc,
      notes: notes.isNotEmpty ? notes : null,
    );

    final ok = await context.read<GrowthProvider>().addRecord(record);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop();
        showSnackBar(context, '记录已保存');
      } else {
        showSnackBar(context, '保存失败，请重试');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记录生长数据')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date
          const Text('记录日期', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
                    '${_recordDate.year}-${_recordDate.month.toString().padLeft(2, '0')}-${_recordDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Height
          _inputField('身高 (cm)', '例如 75.5', _heightController, TextInputType.number),
          const SizedBox(height: 12),

          // Weight
          _inputField('体重 (kg)', '例如 9.5', _weightController, TextInputType.number),
          const SizedBox(height: 12),

          // Head Circumference
          _inputField('头围 (cm)', '例如 45.0', _headCircController, TextInputType.number),
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
                hintText: '可选备注',
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
                  : const Text('保存记录'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl, TextInputType kt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: ctrl,
            keyboardType: kt,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.textTertiary),
            ),
          ),
        ),
      ],
    );
  }
}
