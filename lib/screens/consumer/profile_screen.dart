// lib/screens/consumer/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'historique_screen.dart';
import 'notifications_screen.dart';
import 'signalement_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onAvatarChanged;
  const ProfileScreen({super.key, this.onAvatarChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName  = '';
  String _userEmail = '';
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name   = await AuthService.getUserName();
    final email  = await AuthService.getUserEmail();
    final avatar = await AuthService.getLocalAvatar();
    if (mounted) setState(() {
      _userName  = name;
      _userEmail = email ?? '';
      _avatarPath = avatar;
    });
  }

  Future<void> _pickImage() async {
    final s = context.read<LanguageProvider>().s;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(s.profileChoosePhoto,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(width: 42, height: 42,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary)),
              title: Text(s.profileGallery),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) {
                  await AuthService.saveLocalAvatar(image.path);
                  if (mounted) setState(() => _avatarPath = image.path);
                  widget.onAvatarChanged?.call();
                }
              },
            ),
            ListTile(
              leading: Container(width: 42, height: 42,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB))),
              title: Text(s.profileCamera),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) {
                  await AuthService.saveLocalAvatar(image.path);
                  if (mounted) setState(() => _avatarPath = image.path);
                  widget.onAvatarChanged?.call();
                }
              },
            ),
            if (_avatarPath != null)
              ListTile(
                leading: Container(width: 42, height: 42,
                  decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger)),
                title: Text(s.profileDeletePhoto, style: const TextStyle(color: AppColors.danger)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await AuthService.removeLocalAvatar();
                  if (mounted) setState(() => _avatarPath = null);
                  widget.onAvatarChanged?.call();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final s = context.read<LanguageProvider>().s;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.profileLogoutConfirm),
        content: Text(s.profileLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(s.disconnect),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  void _showAPropos() {
    final s = context.read<LanguageProvider>().s;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
            ),
            const SizedBox(height: 14),
            const Text('VeriScan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: AppColors.textDark, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(s.profileVersion,
              style: TextStyle(fontSize: 13, color: AppColors.textGray.withValues(alpha: 0.8))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
              child: Text(s.profileAboutText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textGray, height: 1.6)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(s.profileClose, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final lang = context.read<LanguageProvider>();
    final s = lang.s;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(s.profileLanguage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            ListTile(
              leading: Text('🇫🇷', style: const TextStyle(fontSize: 24)),
              title: const Text('Français'),
              trailing: lang.isFr
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () { lang.setLocale('fr'); Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Text('🇬🇧', style: const TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: !lang.isFr
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () { lang.setLocale('en'); Navigator.pop(ctx); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          // ── Header teal ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6), width: 2.5),
                            ),
                            child: ClipOval(
                              child: _avatarPath != null
                                  ? Image.file(File(_avatarPath!),
                                      fit: BoxFit.cover, width: 90, height: 90)
                                  : const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 50),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 1.5),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 15, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_userName,
                      style: const TextStyle(
                        color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (_userEmail.isNotEmpty)
                      Text(_userEmail,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s.profileConsumer,
                        style: const TextStyle(
                          color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Options profil ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _card([
                    _option(Icons.person_outline, s.profileEditProfile, s.profileEditSubtitle, () =>
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: _userName, currentEmail: _userEmail),
                      )).then((updated) { if (updated == true) _loadUserInfo(); }),
                    ),
                    _divider(),
                    _option(Icons.history_rounded, s.profileVerifications, s.profileVerifSubtitle, () =>
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoriqueScreen())),
                    ),
                    _divider(),
                    _option(Icons.report_outlined, s.profileReports, s.profileReportsSubtitle, () =>
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignalementScreen())),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _card([
                    _option(Icons.notifications_outlined, s.profileNotifications, s.profileNotifSubtitle, () =>
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                    _divider(),
                    _option(Icons.security_outlined, s.profileSecurity, s.profileSecuritySubtitle, () =>
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SecurityScreen())),
                    ),
                    _divider(),
                    _option(Icons.language_outlined, s.profileLanguage, s.profileLanguageSubtitle,
                      _showLanguagePicker,
                    ),
                    _divider(),
                    _option(Icons.info_outline, s.profileAbout, s.profileAboutSubtitle, _showAPropos),
                  ]),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(s.profileLogout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _option(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      subtitle: Text(subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textGray)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGray),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppColors.textGray.withValues(alpha: 0.15),
      indent: 16, endIndent: 16,
    );
  }
}