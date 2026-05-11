import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../models/baby.dart';
import '../providers/baby_provider.dart';

class BabyFormScreen extends StatefulWidget {
  final BabyModel? baby; // null = add mode, non-null = edit mode

  const BabyFormScreen({super.key, this.baby});

  @override
  State<BabyFormScreen> createState() => _BabyFormScreenState();
}

class _BabyFormScreenState extends State<BabyFormScreen> {
  late final TextEditingController _nameController;
  late bool _isEdit;

  int _gender = 1; // 1=男, 0=女
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  bool _isPremature = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.baby != null;
    _nameController = TextEditingController(text: widget.baby?.name ?? '');
    if (widget.baby != null) {
      _gender = widget.baby!.gender;
      _birthDate = widget.baby!.birthDate;
      _isPremature = widget.baby!.isPremature;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      lastDate: DateTime.now(),
      helpText: '选择出生日期',
      cancelText: '取消',
      confirmText: '确认',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showSnackBar(context, '请输入宝宝姓名');
      return;
    }

    setState(() => _saving = true);

    final babyProvider = context.read<BabyProvider>();
    bool ok;

    if (_isEdit) {
      final updated = BabyModel(
        id: widget.baby!.id,
        userId: widget.baby!.userId,
        name: name,
        gender: _gender,
        birthDate: _birthDate,
        isPremature: _isPremature,
        avatarUrl: widget.baby!.avatarUrl,
      );
      ok = await babyProvider.updateBaby(updated);
    } else {
      final newBaby = BabyModel(
        id: 0,
        userId: 0,
        name: name,
        gender: _gender,
        birthDate: _birthDate,
        isPremature: _isPremature,
      );
      ok = await babyProvider.addBaby(newBaby);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop();
      } else {
        showSnackBar(context, babyProvider.error ?? '保存失败');
      }
    }
  }

  void _togglePremature(bool? v) {
    setState(() => _isPremature = v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑宝宝' : '添加宝宝'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name
          const Text('姓名', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入宝宝姓名',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Gender
          const Text('性别', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _gender == 1 ? AppTheme.primaryBg : AppTheme.bgMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _gender == 1 ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    child: const Center(
                      child: Text('👦 男宝', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _gender == 0 ? AppTheme.primaryBg : AppTheme.bgMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _gender == 0 ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                    child: const Center(
                      child: Text('👧 女宝', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Birth Date
          const Text('出生日期', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
                    '${_birthDate.year}-${_birthDate.month.toString().padLeft(2, '0')}-${_birthDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Premature
          Row(
            children: [
              const Text('是否早产', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Switch(
                value: _isPremature,
                onChanged: _togglePremature,
                activeColor: AppTheme.primary,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Save
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEdit ? '保存' : '添加宝宝'),
            ),
          ),
        ],
      ),
    );
  }
}
