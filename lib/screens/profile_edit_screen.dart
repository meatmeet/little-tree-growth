import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../utils/navigation.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nicknameController;
  bool _saving = false;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file != null && mounted) {
      setState(() => _pickedFile = file);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      showSnackBar(context, '请输入昵称');
      return;
    }

    setState(() => _saving = true);
    final data = <String, dynamic>{'nickname': nickname};
    if (_pickedFile != null) {
      final bytes = await File(_pickedFile!.path).readAsBytes();
      data['avatar'] = base64Encode(bytes);
    }
    final ok = await context.read<AuthProvider>().updateProfile(data);
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        showSnackBar(context, '保存成功');
        Navigator.of(context).pop();
      } else {
        showSnackBar(context, '保存失败，请重试');
      }
    }
  }

  Widget _buildAvatarPreview(UserModel? user) {
    if (_pickedFile != null) {
      return Image.file(
        File(_pickedFile!.path),
        width: 80, height: 80, fit: BoxFit.cover,
      );
    }
    if (user?.avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: user!.avatarUrl!,
        width: 80, height: 80, fit: BoxFit.cover,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => _buildInitialFallback(user),
      );
    }
    return _buildInitialFallback(user);
  }

  Widget _buildInitialFallback(UserModel? user) {
    return Center(
      child: user?.nickname != null
          ? Text(
              user!.nickname![0],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primary),
            )
          : const Icon(Icons.person, size: 40, color: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPale,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildAvatarPreview(user),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '点击更换头像',
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ),

          const SizedBox(height: 32),

          // Nickname
          const Text(
            '昵称',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入昵称',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Text(
            '昵称将显示在个人主页',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),

          // Phone (read-only)
          const SizedBox(height: 24),
          const Text(
            '手机号',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Text(
                  user?.phone ?? '',
                  style: const TextStyle(
                      fontSize: 15, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Save
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
