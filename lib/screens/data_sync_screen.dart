import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';

class DataSyncScreen extends StatefulWidget {
  const DataSyncScreen({super.key});

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> {
  bool _syncing = false;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    // In a real implementation, load last sync time from SharedPreferences
    _lastSyncTime = DateTime.now().subtract(const Duration(hours: 2));
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    // Simulate sync
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _lastSyncTime = DateTime.now();
    });
    showSnackBar(context, '数据同步完成');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据同步')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _syncing
                        ? AppTheme.warning.withValues(alpha: 0.1)
                        : AppTheme.primaryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _syncing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.cloud_sync,
                          size: 32, color: AppTheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  _syncing ? '同步中...' : '数据已同步',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lastSyncTime != null
                      ? '上次同步: ${_lastSyncTime!.hour}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}'
                      : '尚未同步',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sync button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _syncing ? null : _sync,
              icon: Icon(_syncing ? Icons.hourglass_top : Icons.sync),
              label: Text(_syncing ? '同步中...' : '手动同步'),
            ),
          ),

          const SizedBox(height: 16),

          // Info text
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '关于数据同步',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '您的数据会自动保存在本地，联网后会自动同步到云端。\n'
                  '切换设备时，请确保数据已同步。',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
