// lib/screens/consumer/home_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../../services/verify_service.dart';
import 'scan_screen.dart';
import 'profile_screen.dart';
import 'historique_screen.dart';
import 'signalement_screen.dart';
import 'verify_manual_screen.dart';
import 'assistant_screen.dart';
import 'notifications_screen.dart';
import 'aide_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _dashboardKey = 0;
  String _userName = '';
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name   = await AuthService.getUserName();
    final avatar = await AuthService.getLocalAvatar();
    if (mounted) setState(() { _userName = name; _avatarPath = avatar; });
  }

  void _refreshAvatar() async {
    final avatar = await AuthService.getLocalAvatar();
    if (mounted) setState(() => _avatarPath = avatar);
  }

  List<Widget> get _screens => [
    _DashboardTab(
      key: ValueKey(_dashboardKey),
      userName: _userName,
      avatarPath: _avatarPath,
      onGoToScanner: () => setState(() => _currentIndex = 1),
    ),
    const ScanScreen(),
    ProfileScreen(onAvatarChanged: _refreshAvatar),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(
            color: AppColors.textGray.withValues(alpha: 0.15), width: 1)),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded,            s.navHome),
                _navItem(1, Icons.qr_code_scanner_rounded, s.navScan),
                _navItem(2, Icons.person_rounded,          s.navProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _navItem(int index, IconData icon, String label) {
  final bool isActive = _currentIndex == index;
  return GestureDetector(
    onTap: () {
      final prev = _currentIndex;
      setState(() {
        _currentIndex = index;
        if (index == 0 && prev != 0) _dashboardKey++;
      });
      if (index == 0) _refreshAvatar();
    },
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isActive ? 1.0 : 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) => child!,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20.0 : 24.0,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              transform: Matrix4.identity()
                ..translate(0.0, isActive ? -3.0 : 0.0),
              child: Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.textGray,
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 11.5 : 11,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color:
                    isActive ? AppColors.primary : AppColors.textGray,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ),
  );
}
}

// ══════════════════════════════════════════════════════════════════════
// ONGLET ACCUEIL
// ══════════════════════════════════════════════════════════════════════
class _DashboardTab extends StatefulWidget {
  final String userName;
  final String? avatarPath;
  final VoidCallback onGoToScanner;
  const _DashboardTab({
    super.key,
    required this.userName,
    this.avatarPath,
    required this.onGoToScanner,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _totalScans        = 0;
  int _totalAuthentiques = 0;
  int _totalSignalements = 0;
  int _nonLuesNotifs     = 0;
  List<dynamic> _derniersScans = [];
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadNotifCount();
  }

  Future<void> _loadStats() async {
    final result = await VerifyService.getMesVerifications();
    if (mounted) {
      setState(() {
        _loadingStats = false;
        if (result['success'] == true) {
          final data = result['data'] as List;
          _totalScans        = data.length;
          _totalAuthentiques = data.where((v) => v['resultat'] == 'authentique').length;
          _totalSignalements = data.where((v) => v['resultat'] == 'suspect').length;
          _derniersScans     = data.take(3).toList();
        }
      });
    }
  }

  Future<void> _loadNotifCount() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (mounted && data['success'] == true) {
        setState(() => _nonLuesNotifs = data['non_lues'] ?? 0);
      }
    } catch (_) {}
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadStats(), _loadNotifCount()]);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [

              // ── Header teal ──────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -40, right: -40,
                      child: Container(width: 180, height: 180,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06)))),
                    Positioned(top: 60, right: 40,
                      child: Container(width: 80, height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04)))),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Top bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset('assets/images/logo.png',
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const SearchScreen())),
                                      child: _topIcon(Icons.search_rounded),
                                    ),
                                    const SizedBox(width: 8),

                                    // Notifications avec badge
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(context,
                                            MaterialPageRoute(
                                              builder: (_) => const NotificationsScreen()),
                                          ).then((_) => _loadNotifCount()),
                                          child: _topIcon(Icons.notifications_outlined),
                                        ),
                                        if (_nonLuesNotifs > 0)
                                          Positioned(
                                            top: 2, right: 2,
                                            child: Container(
                                              width: 16, height: 16,
                                              decoration: BoxDecoration(
                                                color: AppColors.danger,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF0F766E), width: 1.5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _nonLuesNotifs > 9 ? '9+' : '$_nonLuesNotifs',
                                                  style: const TextStyle(
                                                    color: Colors.white, fontSize: 8,
                                                    fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),

                                    GestureDetector(
                                      onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const AideScreen())),
                                      child: _topIcon(Icons.help_outline_rounded),
                                    ),
                                    const SizedBox(width: 8),

                                    // Photo profil
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.6), width: 2),
                                      ),
                                      child: ClipOval(
                                        child: widget.avatarPath != null
                                            ? Image.file(File(widget.avatarPath!),
                                                fit: BoxFit.cover, width: 38, height: 38)
                                            : const Icon(Icons.person_rounded,
                                                color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(s.homeGreeting,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.8), fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(widget.userName,
                              style: const TextStyle(
                                color: AppColors.white, fontSize: 22,
                                fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(s.homeSubtitle,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7), fontSize: 13)),

                            const SizedBox(height: 20),

                            // Stats dynamiques
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: _loadingStats
                                  ? const Center(child: SizedBox(height: 32, width: 32,
                                      child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2)))
                                  : Row(
                                      children: [
                                        Expanded(child: _statItem(
                                          '$_totalScans', s.navScan, AppColors.white)),
                                        Container(width: 1, height: 32,
                                          color: Colors.white.withValues(alpha: 0.2)),
                                        Expanded(child: _statItem(
                                          '$_totalAuthentiques', s.homeAuthentic,
                                          const Color(0xFF4ADE80))),
                                        Container(width: 1, height: 32,
                                          color: Colors.white.withValues(alpha: 0.2)),
                                        Expanded(child: _statItem(
                                          '$_totalSignalements', s.homeSuspect,
                                          AppColors.warning)),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Corps arrondi ────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                transform: Matrix4.translationValues(0, -20, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Hero Scanner ─────────────────────────────────
                      GestureDetector(
                        onTap: widget.onGoToScanner,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ACTION PRINCIPALE',
                                      style: TextStyle(
                                        color: AppColors.white.withValues(alpha: 0.75),
                                        fontSize: 11, fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8)),
                                    const SizedBox(height: 6),
                                    Text(s.homeScanBtn,
                                      style: const TextStyle(
                                        color: AppColors.white, fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(10)),
                                      child: Text(s.scanTitle,
                                        style: const TextStyle(
                                          color: AppColors.primary, fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.qr_code_scanner_rounded,
                                color: AppColors.white, size: 64),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(s.homeQuickActions,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          _actionCard(
                            icon: Icons.search_rounded,
                            label: s.verifyManualTitle,
                            subtitle: s.scanManual,
                            bgColor: const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF2563EB),
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const VerifyManualScreen()))),
                          _actionCard(
                            icon: Icons.report_problem_rounded,
                            label: s.homeReport,
                            subtitle: s.homeSuspect,
                            bgColor: const Color(0xFFFFF1F2),
                            iconColor: AppColors.danger,
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SignalementScreen()))),
                          _actionCard(
                            icon: Icons.history_rounded,
                            label: s.homeHistory,
                            subtitle: s.profileVerifSubtitle,
                            bgColor: const Color(0xFFFFFBEB),
                            iconColor: const Color(0xFFD97706),
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoriqueScreen()))
                              .then((_) => _loadStats())),
                          _actionCard(
                            icon: Icons.smart_toy_rounded,
                            label: s.homeAssistant,
                            subtitle: s.helpTitle,
                            bgColor: const Color(0xFFF0FDF4),
                            iconColor: AppColors.success,
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AssistantScreen()))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.historyTitle,
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const HistoriqueScreen()))
                              .then((_) => _loadStats()),
                            child: Text(s.homeViewAll,
                              style: TextStyle(
                                fontSize: 13, color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _derniersScans.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textGray.withValues(alpha: 0.1)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.qr_code_2_rounded, size: 44,
                                    color: AppColors.textGray.withValues(alpha: 0.3)),
                                  const SizedBox(height: 12),
                                  Text(s.homeNoScans,
                                    style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500,
                                      color: AppColors.textGray)),
                                  const SizedBox(height: 4),
                                  Text(s.historyEmptySubtitle,
                                    style: TextStyle(fontSize: 12,
                                      color: AppColors.textGray.withValues(alpha: 0.7))),
                                ],
                              ),
                            )
                          : Column(
                              children: _derniersScans
                                  .map((v) => _buildDernierScan(v))
                                  .toList(),
                            ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDernierScan(Map<String, dynamic> v) {
    final bool isAuthentique = v['resultat'] == 'authentique';
    final Color statusColor = isAuthentique
        ? const Color(0xFF16A34A) : const Color(0xFFE11D48);
    final Color statusBg = isAuthentique
        ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final IconData statusIcon = isAuthentique
        ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(v['produit'] ?? 'Produit inconnu',
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textDark),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(v['created_at'] ?? '',
            style: TextStyle(fontSize: 11,
              color: AppColors.textGray.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  static Widget _topIcon(IconData icon) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _statItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(
            color: valueColor, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11,
                color: AppColors.textGray.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}