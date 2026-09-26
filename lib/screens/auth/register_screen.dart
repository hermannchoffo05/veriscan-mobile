import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../consumer/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword     = true;
  bool _obscureConfirm      = true;
  bool _isLoading           = false;

  AnimationController? _anim;
  Animation<double>? _fade;
  Animation<Offset>? _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim!, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.easeOut));
    _anim!.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _anim?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fade = _fade ?? const AlwaysStoppedAnimation(1.0);
    final slide = _slide ?? const AlwaysStoppedAnimation(Offset.zero);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: Column(
              children: [

                // ── Section image + overlay arrondie en bas ────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: size.height * 0.29,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [

                        Image.asset(
                          'assets/images/register_bg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary,
                          ),
                        ),

                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x991F2A52),
                                Color(0x992E3A6B),
                                Color(0x884A5694),
                              ],
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: CustomPaint(painter: _DotGridPainter()),
                        ),

                        // Bouton retour
                        Positioned(
                          top: 12, left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),

                        // Logo + titre
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Créer un compte',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x99000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Rejoignez VeriScan gratuitement',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x88000000),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Formulaire blanc ───────────────────────────────────
                Expanded(
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _label('Nom complet'),
                            const SizedBox(height: 4),
                            _field(
                              controller: _nameController,
                              hint: 'Hermann Choffo',
                              icon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            _label('Adresse email'),
                            const SizedBox(height: 4),
                            _field(
                              controller: _emailController,
                              hint: 'hermannchoffo05@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            _label('Téléphone (optionnel)'),
                            const SizedBox(height: 4),
                            _field(
                              controller: _phoneController,
                              hint: '+237 6XX XXX XXX',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 10),

                            _label('Mot de passe'),
                            const SizedBox(height: 4),
                            _field(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF9CA3AF),
                                  size: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                if (v.length < 6) return 'Minimum 6 caractères';
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            _label('Confirmer le mot de passe'),
                            const SizedBox(height: 4),
                            _field(
                              controller: _confirmController,
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscureConfirm,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                child: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF9CA3AF),
                                  size: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Veuillez confirmer le mot de passe';
                                }
                                if (v != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _register,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_add_rounded,
                                        size: 16,
                                      ),
                                label: const Text(
                                  "S'inscrire",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  shadowColor: AppColors.primary
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Déjà un compte ? ',
                                    style: TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF9CA3AF).withValues(alpha: 0.7),
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 17),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
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
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService.register(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      password: _passwordController.text,
      phone:    _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur inconnue'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
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