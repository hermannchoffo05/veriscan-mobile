import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../services/report_service.dart';

class SignalementScreen extends StatefulWidget {
  final String? qrToken;
  const SignalementScreen({super.key, this.qrToken});

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nomController        = TextEditingController();
  final _contactController    = TextEditingController();
  bool _isLoading = false;

  // GPS
  double? _latitude;
  double? _longitude;
  String? _localisation;
  bool _gpsLoading = false;
  bool _gpsObtenu  = false;

  // Photo
  File? _photo;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _capturerPosition();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nomController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // ── GPS ────────────────────────────────────────────────────────────
  Future<void> _capturerPosition() async {
    setState(() => _gpsLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _gpsLoading = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _gpsLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _gpsLoading = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude    = position.latitude;
          _longitude   = position.longitude;
          _localisation =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _gpsObtenu  = true;
          _gpsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Photo ──────────────────────────────────────────────────────────
  Future<void> _choisirPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _photo = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'accéder à la caméra ou galerie'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _afficherChoixPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajouter une photo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _photoOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Caméra',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        _choisirPhoto(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _photoOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galerie',
                      color: const Color(0xFF7C3AED),
                      onTap: () {
                        Navigator.pop(context);
                        _choisirPhoto(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _photo = null);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger, size: 18),
                    label: const Text('Supprimer la photo',
                        style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // ── Soumission ─────────────────────────────────────────────────────
  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ReportService.soumettre(
      description:      _descriptionController.text.trim(),
      nomSignalant:     _nomController.text.trim().isEmpty ? null : _nomController.text.trim(),
      contactSignalant: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      token:            widget.qrToken,
      latitude:         _latitude,
      longitude:        _longitude,
      localisation:     _localisation,
      photo:            _photo,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur inconnue'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Signalement envoyé !',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(
                'Votre signalement a été soumis avec succès. Notre équipe va l\'examiner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('OK',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Header rouge
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEF4444)],
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
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text('Signaler un produit',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Signalez tout produit suspect ou contrefait pour protéger les consommateurs.',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12),
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

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Badge QR
                    if (widget.qrToken != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code_rounded,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text('QR code lié à ce signalement',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary))),
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // GPS
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _gpsObtenu
                            ? AppColors.success.withValues(alpha: 0.06)
                            : AppColors.textGray.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _gpsObtenu
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.textGray.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: _gpsObtenu
                                  ? AppColors.success
                                  : AppColors.textGray,
                              size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _gpsLoading
                                ? const Text('Localisation en cours...',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textGray))
                                : _gpsObtenu
                                    ? const Text('Position capturée ✓',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success))
                                    : const Text('Position non disponible',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textGray)),
                          ),
                          if (_gpsLoading)
                            const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary)),
                          if (!_gpsLoading && !_gpsObtenu)
                            GestureDetector(
                              onTap: _capturerPosition,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Réessayer',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Photo preuve ────────────────────────────────
                    _sectionTitle('Photo du produit (optionnel)'),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _afficherChoixPhoto,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: double.infinity,
                        height: _photo != null ? 200 : 110,
                        decoration: BoxDecoration(
                          color: _photo != null
                              ? Colors.transparent
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _photo != null
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : AppColors.textGray.withValues(alpha: 0.25),
                            width: _photo != null ? 2 : 1.5,
                            style: _photo != null
                                ? BorderStyle.solid
                                : BorderStyle.solid,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _photo != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_photo!, fit: BoxFit.cover),
                                  // Overlay bouton changer
                                  Positioned(
                                    bottom: 8, right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.55),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit_rounded,
                                              color: Colors.white, size: 13),
                                          SizedBox(width: 4),
                                          Text('Changer',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        color: AppColors.primary,
                                        size: 22),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Ajouter une photo',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary)),
                                  const SizedBox(height: 2),
                                  Text('Caméra ou galerie',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray
                                              .withValues(alpha: 0.7))),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    _sectionTitle('Description *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'La description est obligatoire'
                              : null,
                      decoration: _inputDecoration(
                        hint: 'Décrivez le problème : aspect suspect, lieu d\'achat...',
                        icon: Icons.description_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle('Votre nom (optionnel)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomController,
                      decoration: _inputDecoration(
                          hint: 'Votre nom complet',
                          icon: Icons.person_outline_rounded),
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle('Votre contact (optionnel)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                          hint: 'Numéro de téléphone ou email',
                          icon: Icons.phone_outlined),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _soumettre,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.report_problem_rounded,
                                size: 20),
                        label: Text(
                          _isLoading
                              ? 'Envoi en cours...'
                              : 'Soumettre le signalement',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.danger.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor:
                              AppColors.danger.withValues(alpha: 0.4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Vos informations restent confidentielles',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray.withValues(alpha: 0.7)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark));
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: 13,
          color: AppColors.textGray.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.textGray.withValues(alpha: 0.2))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: AppColors.textGray.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}