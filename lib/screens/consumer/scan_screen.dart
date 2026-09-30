import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import '../../services/auth_service.dart';
import 'signalement_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null) return;
    setState(() => _scanned = true);

    String token = rawValue;
    if (rawValue.contains('/verify/')) {
      token = rawValue.split('/verify/').last;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ResultScreen(token: token)),
    ).then((_) => setState(() => _scanned = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          Column(
            children: [
              Expanded(flex: 2, child: Container(color: Colors.black54)),
              Row(
                children: [
                  Expanded(child: Container(color: Colors.black54)),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Expanded(child: Container(color: Colors.black54)),
                ],
              ),
              Expanded(flex: 3, child: Container(color: Colors.black54)),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scanner QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cameraController.toggleTorch();
                      setState(() => _torchOn = !_torchOn);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _torchOn
                            ? AppColors.warning
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _corner(true, true)),
                  Positioned(top: 0, right: 0, child: _corner(true, false)),
                  Positioned(bottom: 0, left: 0, child: _corner(false, true)),
                  Positioned(bottom: 0, right: 0, child: _corner(false, false)),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Placez le QR Code dans le cadre',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showManualInput(),
                      child: Text(
                        'Saisir le code manuellement',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(bool isTop, bool isLeft) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }

  void _showManualInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saisir le code manuellement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Entrez le token du QR code',
                  prefixIcon: const Icon(Icons.qr_code, color: AppColors.primary),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _ResultScreen(token: controller.text.trim()),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Vérifier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ÉCRAN RÉSULTAT
// ══════════════════════════════════════════════════════════════════════
class _ResultScreen extends StatefulWidget {
  final String token;
  const _ResultScreen({required this.token});

  @override
  State<_ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<_ResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'token': widget.token}),
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
              'message': data['message'] ?? 'QR Code invalide ou inexistant',
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
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Résultat de vérification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Vérification en cours...',
                    style: TextStyle(color: AppColors.textGray, fontSize: 14),
                  ),
                ],
              ),
            )
          : _buildResult(),
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
        title = 'QR Code Invalide';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          const SizedBox(height: 20),

          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 56),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _result?['message'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),

          const SizedBox(height: 32),

          if (produit != null) _productCard(produit),

          const SizedBox(height: 24),

          // Bouton signaler si suspect ou invalide
          if (status != 'authentique')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignalementScreen(qrToken: widget.token),
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

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scanner à nouveau'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> produit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du produit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (produit['nom'] != null) _infoRow('Produit', produit['nom']),
          if (produit['fabricant'] != null) _infoRow('Fabricant', produit['fabricant']),
          if (produit['lot'] != null) _infoRow('N° Lot', produit['lot']),
          if (produit['expiration'] != null) _infoRow('Expiration', produit['expiration'].toString()),
          if (produit['categorie'] != null) _infoRow('Catégorie', produit['categorie']),
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
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}