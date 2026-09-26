import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import 'verify_code.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': _emailController.text.trim()}),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (data['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(email: _emailController.text.trim()),
          ),
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
                    height: size.height * 0.45,
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
                              colors: [
                                Color(0xCC1F2A52),
                                Color(0xCC2E3A6B),
                                Color(0xBB4A5694),
                              ],
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: CustomPaint(painter: _DotGridPainter()),
                        ),

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
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Entrez votre email pour recevoir\nun code de vérification à 6 chiffres.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Formulaire blanc ────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Adresse email',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                            decoration: InputDecoration(
                              hintText: 'hermannchoffo05@gmail.com',
                              hintStyle: TextStyle(color: AppColors.textGray.withValues(alpha: 0.5), fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Entrez votre email';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _sendCode,
                              icon: _isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.send_rounded, size: 18),
                              label: const Text('Envoyer le code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
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