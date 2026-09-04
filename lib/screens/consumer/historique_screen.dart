import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/verify_service.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  bool _isLoading = true;
  List<dynamic> _verifications = [];
  List<dynamic> _filtered = [];
  String _activeFilter = 'tous';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await VerifyService.getMesVerifications();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _verifications = result['data'] ?? [];
          _applyFilter('tous');
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      if (filter == 'tous') {
        _filtered = List.from(_verifications);
      } else {
        _filtered = _verifications
            .where((v) => v['resultat'] == filter)
            .toList();
      }
    });
  }

  int get _totalAuthentiques =>
      _verifications.where((v) => v['resultat'] == 'authentique').length;

  int get _totalSuspects =>
      _verifications.where((v) => v['resultat'] == 'suspect').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          // ── Header teal avec stats ────────────────────────────────
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
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Bouton retour + titre
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
                          'Mes vérifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats 3 colonnes
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            value: '${_verifications.length}',
                            label: 'Total',
                            valueColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            value: '$_totalAuthentiques',
                            label: 'Authentiques',
                            valueColor: const Color(0xFF4ADE80),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            value: '$_totalSuspects',
                            label: 'Suspects',
                            valueColor: const Color(0xFFFBBF24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Corps blanc arrondi ───────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                children: [

                  // Filtres
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        _filterChip('tous', 'Tous'),
                        const SizedBox(width: 8),
                        _filterChip('authentique', 'Authentiques'),
                        const SizedBox(width: 8),
                        _filterChip('suspect', 'Suspects'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Liste
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _errorMessage != null
                            ? _buildError()
                            : _filtered.isEmpty
                                ? _buildEmpty()
                                : RefreshIndicator(
                                    onRefresh: _loadHistorique,
                                    color: AppColors.primary,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      itemCount: _filtered.length,
                                      itemBuilder: (context, index) {
                                        return _buildCard(_filtered[index]);
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final bool isActive = _activeFilter == value;
    return GestureDetector(
      onTap: () => _applyFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.textGray.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> v) {
    final bool isAuthentique = v['resultat'] == 'authentique';
    final bool isSuspect = v['resultat'] == 'suspect';

    final Color statusColor = isAuthentique
        ? const Color(0xFF16A34A)
        : isSuspect
            ? const Color(0xFFE11D48)
            : AppColors.warning;

    final Color statusBg = isAuthentique
        ? const Color(0xFFF0FDF4)
        : isSuspect
            ? const Color(0xFFFFF1F2)
            : const Color(0xFFFFFBEB);

    final IconData statusIcon = isAuthentique
        ? Icons.check_circle_rounded
        : isSuspect
            ? Icons.cancel_rounded
            : Icons.help_rounded;

    final String statusLabel = isAuthentique
        ? 'Authentique'
        : isSuspect
            ? 'Suspect'
            : 'Invalide';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Ligne 1 : icône + nom produit + date
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    v['produit'] ?? 'Produit inconnu',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Ligne 2 : catégorie + lot
            if ((v['categorie'] ?? '').isNotEmpty ||
                (v['lot'] ?? '').isNotEmpty)
              Row(
                children: [
                  if ((v['categorie'] ?? '').isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 13,
                          color: AppColors.textGray.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          v['categorie'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  if ((v['categorie'] ?? '').isNotEmpty &&
                      (v['lot'] ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textGray.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if ((v['lot'] ?? '').isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 13,
                          color: AppColors.textGray.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lot: ${v['lot']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            const SizedBox(height: 10),

            // Ligne 3 : badge statut + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.textGray.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      v['created_at'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
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
              Icons.qr_code_2_rounded,
              size: 72,
              color: AppColors.textGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune vérification encore',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scannez votre premier QR code\npour voir l\'historique ici.',
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
            const Text(
              'Impossible de charger',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistorique,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}