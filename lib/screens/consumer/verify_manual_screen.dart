import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import '../../services/auth_service.dart';
import 'signalement_screen.dart';

class VerifyManualScreen extends StatefulWidget {
  final String? initialToken;
  const VerifyManualScreen({super.key, this.initialToken});

  @override
  State<VerifyManualScreen> createState() => _VerifyManualScreenState();
}

class _VerifyManualScreenState extends State<VerifyManualScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un code'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final authToken = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data['success'] == true) {
            _result = {
              'status': data['resultat'],
              'message': data['message'] ??
                  (data['resultat'] == 'authentique'
                      ? 'Ce produit est authentique et certifié.'
                      : 'Ce produit est suspect — soyez vigilant.'),
              'produit': data['produit'],
            };
          } else {
            _result = {
              'status': 'invalide',
              'message': data['message'] ?? 'Code invalide ou inexistant',
            };
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = {
            'status': 'invalide',
            'message': 'Erreur de connexion au serveur',
          };
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                          'Vérifier un produit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Saisissez le code inscrit sous le QR code du produit pour vérifier son authenticité.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Champ de saisie
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Code du produit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _tokenController,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ex: VS-7-D95BYKAUCDNZ',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray.withValues(alpha: 0.6),
                            ),
                            prefixIcon: const Icon(
                              Icons.qr_code_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            suffixIcon: _tokenController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _tokenController.clear();
                                      setState(() => _result = null);
                                    },
                                    child: const Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.textGray,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColors.textGray.withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: AppColors.textGray.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _verify,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search_rounded, size: 20),
                            label: Text(
                              _isLoading ? 'Vérification...' : 'Vérifier le produit',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Résultat
                  if (_result != null) _buildResult(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final status = _result?['status'] ?? 'invalide';
    final produit = _result?['produit'];

    Color color;
    IconData icon;
    String title;

    switch (status) {
      case 'authentique':
        color = AppColors.success;
        icon = Icons.verified_rounded;
        title = 'Produit Authentique';
        break;
      case 'suspect':
        color = AppColors.danger;
        icon = Icons.cancel_rounded;
        title = 'Produit Suspect';
        break;
      default:
        color = AppColors.warning;
        icon = Icons.help_rounded;
        title = 'Code Invalide';
    }

    return Column(
      children: [

        // Carte résultat
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _result?['message'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Infos produit si disponibles
        if (produit != null) _productCard(produit),

        const SizedBox(height: 16),

        // Bouton signaler si suspect ou invalide
        if (status != 'authentique')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignalementScreen(
                      qrToken: _tokenController.text.trim(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.report_problem_rounded),
              label: const Text('Signaler ce produit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _productCard(Map<String, dynamic> produit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Informations du produit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (produit['nom'] != null) _infoRow('Produit', produit['nom']),
          if (produit['fabricant'] != null) _infoRow('Fabricant', produit['fabricant']),
          if (produit['categorie'] != null) _infoRow('Catégorie', produit['categorie']),
          if (produit['lot'] != null) _infoRow('N° Lot', produit['lot']),
          if (produit['expiration'] != null)
            _infoRow('Expiration', produit['expiration'].toString()),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray.withValues(alpha: 0.8),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}