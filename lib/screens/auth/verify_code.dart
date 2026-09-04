import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/api_config.dart';
import 'reset_password.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  bool _codeExpired = false;

  // Timer d'expiration du code (60s)
  int _expirySeconds = 60;
  Timer? _expiryTimer;

  // Cooldown renvoi (60s après renvoi)
  int _resendCooldown = 0;
  Timer? _resendTimer;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNodes[0].requestFocus());
    _startExpiryTimer();
  }

  // Lance le timer d'expiration du code
  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    setState(() {
      _expirySeconds = 60;
      _codeExpired = false;
    });
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_expirySeconds <= 1) {
        t.cancel();
        setState(() {
          _expirySeconds = 0;
          _codeExpired = true;
        });
      } else {
        setState(() => _expirySeconds--);
      }
    });
  }

  // Lance le cooldown du bouton renvoyer
  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendCooldown <= 0) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': widget.email}),
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      if (data['success'] == true) {
        // Vider les cases et relancer le timer d'expiration
        for (var c in _controllers) c.clear();
        setState(() {});
        _focusNodes[0].requestFocus();
        _startExpiryTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau code envoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors du renvoi'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de connexion'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
        _startResendCooldown();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _expiryTimer?.cancel();
    _resendTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_code.length != 6) return;

    // Code expiré côté frontend
    if (_codeExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Votre code a expiré. Veuillez cliquer sur "Renvoyer le code" pour en recevoir un nouveau.',
          ),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Renvoyer',
            textColor: Colors.white,
            onPressed: _resendCode,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/verify-reset-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'email': widget.email, 'code': _code}),
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (data['success'] == true) {
        _expiryTimer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
                email: widget.email, resetToken: data['reset_token']),
          ),
        );
      } else {
        // Message d'expiration venant du serveur
        final msg = data['message'] ?? 'Code incorrect';
        for (var c in _controllers) c.clear();
        setState(() {});
        _focusNodes[0].requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur de connexion'),
            backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final codeComplete = _code.length == 6;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // ── Section image ───────────────────────────────────────
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
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF0F766E)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xCC064E3B),
                                Color(0xCC0F766E),
                                Color(0xBB0D9488)
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                            child: CustomPaint(painter: _DotGridPainter())),
                        Positioned(
                          top: 16,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset('assets/images/logo.png',
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Vérification de l\'email',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Code envoyé à ${widget.email}',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Formulaire OTP ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        Text(
                          'Entrez le code à 6 chiffres reçu par email',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGray,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Indicateur expiration
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _codeExpired
                              ? Container(
                                  key: const ValueKey('expired'),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_off_rounded,
                                          color: Color(0xFFB91C1C), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Votre code a expiré. Cliquez sur "Renvoyer le code" pour en recevoir un nouveau.',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFB91C1C),
                                              height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  key: const ValueKey('timer'),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _expirySeconds <= 15
                                        ? const Color(0xFFFFF7ED)
                                        : const Color(0xFFF0FDF9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _expirySeconds <= 15
                                          ? const Color(0xFFFED7AA)
                                          : const Color(0xFFBBF7D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_rounded,
                                        size: 14,
                                        color: _expirySeconds <= 15
                                            ? const Color(0xFFEA580C)
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Code valide encore $_expirySeconds s',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _expirySeconds <= 15
                                              ? const Color(0xFFEA580C)
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        // Cases OTP — design propre sans double bordure
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            final isFilled =
                                _controllers[index].text.isNotEmpty;
                            final isExpired = _codeExpired;
                            return SizedBox(
                              width: 48,
                              height: 58,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? const Color(0xFFFEF2F2)
                                      : isFilled
                                          ? AppColors.primary
                                              .withValues(alpha: 0.08)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isExpired
                                        ? const Color(0xFFFCA5A5)
                                        : isFilled
                                            ? AppColors.primary
                                            : const Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isFilled && !isExpired
                                          ? AppColors.primary
                                              .withValues(alpha: 0.15)
                                          : Colors.black.withValues(alpha: 0.04),
                                      blurRadius: isFilled ? 8 : 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: isExpired
                                          ? const Color(0xFFEF4444)
                                          : isFilled
                                              ? AppColors.primary
                                              : const Color(0xFF1E293B),
                                      height: 1,
                                    ),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (value) {
                                      if (value.isNotEmpty && index < 5) {
                                        _focusNodes[index + 1].requestFocus();
                                      }
                                      if (value.isEmpty && index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Bouton renvoyer + cooldown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isResending)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            else if (_resendCooldown > 0)
                              Text(
                                'Renvoyer dans ${_resendCooldown}s',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.textGray),
                              )
                            else
                              GestureDetector(
                                onTap: _resendCode,
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh_rounded,
                                        size: 15, color: AppColors.primary),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Renvoyer le code',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (codeComplete && !_isLoading)
                                ? _verifyCode
                                : null,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.check_circle_rounded,
                                    size: 18),
                            label: const Text('Vérifier le code',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.35),
                              disabledForegroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 3,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Changer d\'email',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
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
        ),
      ),
    );
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