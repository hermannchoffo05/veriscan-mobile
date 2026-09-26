import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import 'verify_manual_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().length >= 2) {
        _search(query.trim());
      } else {
        setState(() {
          _results = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/search?q=$query'),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = data['success'] == true ? data['data'] : [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          // ── Header marine ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primarySoft,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          'Rechercher un produit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Champ de recherche — icône en accent ambre
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nom du produit ou token...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGray.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.accentDark,
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _results = [];
                                      _hasSearched = false;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear_rounded,
                                    color: AppColors.textGray,
                                    size: 20,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Résultats ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : !_hasSearched
                    ? _buildInitial()
                    : _results.isEmpty
                        ? _buildEmpty()
                        : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 72,
              color: AppColors.accent.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recherchez un produit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tapez le nom d\'un produit ou son token pour le trouver.',
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppColors.textGray.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun résultat trouvé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez un autre mot-clé ou vérifiez l\'orthographe.',
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

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final bool isAuthentique = item['statut'] == 'actif';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifyManualScreen(
                  initialToken: item['token'],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textGray.withValues(alpha: 0.1),
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
              children: [

                // Icône statut
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isAuthentique
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAuthentique
                        ? Icons.verified_rounded
                        : Icons.warning_rounded,
                    color: isAuthentique
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE11D48),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['produit'] ?? 'Produit inconnu',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (item['fabricant'] != null &&
                          item['fabricant'].toString().isNotEmpty)
                        Text(
                          item['fabricant'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 3),
                      // Token en accent ambre plutôt que marine
                      Text(
                        item['token'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.accentDark.withValues(alpha: 0.85),
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isAuthentique
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAuthentique
                          ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                          : const Color(0xFFE11D48).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isAuthentique ? 'Actif' : 'Suspect',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAuthentique
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE11D48),
                    ),
                  ),
                ),

                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textGray,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}