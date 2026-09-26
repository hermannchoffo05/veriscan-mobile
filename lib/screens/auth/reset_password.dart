import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.email, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading = false;
  int _strength = 0;
  bool? _matches;
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
    _passwordController.addListener(_checkStrength);
    _confirmController.addListener(_checkMatch);
  }

  void _checkStrength() {
    final v = _passwordController.text;
    int score = 0;
    if (v.length >= 8) score++;
    if (v.contains(RegExp(r'[A-Z]'))) score++;
    if (v.contains(RegExp(r'[0-9]'))) score++;
    if (v.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    setState(() => _strength = score);
    _checkMatch();
  }

  void _checkMatch() {
    final pw = _passwordController.text;
    final cf = _confirmController.text;
    setState(() => _matches = cf.isEmpty ? null : pw == cf);
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1: return const Color(0xFFEF4444);
      case 2: return const Color(0xFFF97316);
      case 3: return const Color(0xFFEAB308);
      case 4: return const Color(0xFF10B981);
      default: return const Color(0xFFE5E7EB);
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case 1: return 'Très faible';
      case 2: return 'Faible';
      case 3: return 'Moyen';
      case 4: return 'Fort ✓';
      default: return '';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'email': widget.email,
          'reset_token': widget.resetToken,
          'password': _passwordController.text,
          'password_confirmation': _confirmController.text,
        }),
      ).timeout(const Duration(seconds: 15));
      if (response.headers['content-type']?.contains('application/json') != true) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe réinitialisé ! 🎉'), backgroundColor: AppColors.success),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur'), backgroundColor: AppColors.danger),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [

                // ── Section image arrondie en bas ──────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: size.height * 0.38,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [

                        Image.asset(
                          'assets/images/forgot_bg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
                        ),

                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xCC1F2A52), Color(0xCC2E3A6B), Color(0xBB4A5694)],
                            ),
                          ),
                        ),

                        Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

                        // Bouton retour
                        Positioned(
                          top: 16, left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),

                        // Logo + titre
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                width: 75, height: 75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Nouveau mot de passe',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Choisissez un mot de passe sécurisé',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Formulaire ──────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _label('Nouveau mot de passe'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDeco(
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              suffix: _eyeBtn(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Entrez un mot de passe';
                              if (v.length < 6) return 'Minimum 6 caractères';
                              return null;
                            },
                          ),

                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _strength / 4,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_strengthLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _strengthColor)),
                                Text('${_strength * 25}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _strengthColor)),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16),

                          _label('Confirmer le mot de passe'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            decoration: _inputDeco(
                              hint: 'Répétez le mot de passe',
                              icon: Icons.shield_outlined,
                              suffix: _eyeBtn(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
                              if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                              return null;
                            },
                          ),

                          if (_matches != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _matches! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 14,
                                  color: _matches! ? const Color(0xFF10B981) : AppColors.danger,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _matches! ? 'Les mots de passe correspondent' : 'Ne correspondent pas',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _matches! ? const Color(0xFF10B981) : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _resetPassword,
                              icon: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 3,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text('Retour à la connexion',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)));
  }

  Widget _eyeBtn(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: AppColors.textGray),
      onPressed: onTap,
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textGray.withValues(alpha: 0.5), fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05)..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}