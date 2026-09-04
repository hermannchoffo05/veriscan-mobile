import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import '../../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  int _nonLues = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data['success'] == true) {
            _notifications = data['data'] ?? [];
            _nonLues = data['non_lues'] ?? 0;
          } else {
            _errorMessage = 'Impossible de charger les notifications';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur de connexion';
        });
      }
    }
  }

  Future<void> _marquerLue(int id) async {
    final token = await AuthService.getToken();
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/notifications/$id/lue'),
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1 && _notifications[index]['lu'] == false) {
        _notifications[index]['lu'] = true;
        if (_nonLues > 0) _nonLues--;
      }
    });
  }

  Future<void> _marquerToutesLues() async {
    final token = await AuthService.getToken();
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/notifications/toutes-lues'),
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    setState(() {
      for (var n in _notifications) {
        n['lu'] = true;
      }
      _nonLues = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          // ── Header teal ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF0D9488),
                  Color(0xFF14B8A6),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (_nonLues > 0)
                          GestureDetector(
                            onTap: _marquerToutesLues,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Tout lire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Badge non lues
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _nonLues > 0
                                ? '$_nonLues non lue${_nonLues > 1 ? 's' : ''}'
                                : 'Tout lu',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Corps ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _errorMessage != null
                    ? _buildError()
                    : _notifications.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                return _buildCard(_notifications[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> n) {
    final bool isLue = n['lu'] == true;
    final String type = n['type'] ?? 'info';

    Color iconColor;
    Color iconBg;
    IconData icon;

    if (type == 'scan_authentique') {
      iconColor = const Color(0xFF16A34A);
      iconBg = const Color(0xFFF0FDF4);
      icon = Icons.verified_rounded;
    } else if (type == 'scan_suspect') {
      iconColor = const Color(0xFFE11D48);
      iconBg = const Color(0xFFFFF1F2);
      icon = Icons.warning_rounded;
    } else if (type == 'signalement') {
      iconColor = const Color(0xFFD97706);
      iconBg = const Color(0xFFFFFBEB);
      icon = Icons.report_problem_rounded;
    } else {
      iconColor = AppColors.primary;
      iconBg = AppColors.primary.withValues(alpha: 0.1);
      icon = Icons.info_rounded;
    }

    return GestureDetector(
      onTap: () => _marquerLue(n['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLue ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLue
                ? AppColors.textGray.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n['titre'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isLue ? FontWeight.w600 : FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isLue)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['message'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGray.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['created_at'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 72,
              color: AppColors.textGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos notifications apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: AppColors.danger.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}