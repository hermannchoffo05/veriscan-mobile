// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAnimating = false;
  double _nextBtnScale = 1.0;

  List<_SlideData> _buildSlides(LanguageProvider lang) => [
    _SlideData(
      image: 'assets/images/onboarding1.png',
      title: lang.s.onboarding1Title,
      description: lang.s.onboarding1Desc,
      accentColor: AppColors.accent,
    ),
    _SlideData(
      image: 'assets/images/onboarding2.png',
      title: lang.s.onboarding2Title,
      description: lang.s.onboarding2Desc,
      accentColor: AppColors.accent,
    ),
    _SlideData(
      image: 'assets/images/onboarding3.png',
      title: lang.s.onboarding3Title,
      description: lang.s.onboarding3Desc,
      accentColor: AppColors.accent,
    ),
  ];

  void _nextPage(int slidesLength) {
    if (_isAnimating) return;
    HapticFeedback.lightImpact();
    if (_currentPage < slidesLength - 1) {
      _isAnimating = true;
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          )
          .then((_) => _isAnimating = false);
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.selectionClick();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final slides = _buildSlides(lang);
    final slide = slides[_currentPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B0F24),
                AppColors.primaryDark,
                Color(0xFF12183A),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // ── Barre de marque : bouton Passer ─────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _PressableScale(
                          onTap: _skipOnboarding,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E5EC),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                lang.s.onboardingSkip,
                                style: const TextStyle(
                                  color: Color(0xFF2B2E45),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Carousel avec transition fade + scale ───────────
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: slides.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double page = _currentPage.toDouble();
                              if (_pageController.hasClients) {
                                try {
                                  page = _pageController.page ??
                                      _currentPage.toDouble();
                                } catch (_) {
                                  page = _currentPage.toDouble();
                                }
                              }
                              final delta = (page - index).clamp(-1.0, 1.0);
                              final proximity = 1 - delta.abs();
                              final opacity = proximity.clamp(0.0, 1.0);
                              final scale = 0.9 + (proximity * 0.1);
                              return Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildSlide(slides[index]),
                          );
                        },
                      ),
                    ),

                    // ── Points indicateurs ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (index) => _buildDot(index, slide.accentColor),
                        ),
                      ),
                    ),

                    // ── Bouton Suivant / Commencer — toujours jaune ─────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                      child: AnimatedScale(
                        scale: _nextBtnScale,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: AppColors.accent,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _nextPage(slides.length),
                                onHighlightChanged: (pressed) => setState(
                                  () => _nextBtnScale = pressed ? 0.97 : 1.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == slides.length - 1
                                          ? lang.s.onboardingStart
                                              .toUpperCase()
                                          : lang.s.onboardingNext
                                              .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // ── Illustration sur fond ovale (ellipse), sans ombre ──────
          SizedBox(
            width: double.infinity,
            height: 320,
            child: ClipPath(
              clipper: _OvalClipper(),
              child: Container(
                color: Colors.white.withValues(alpha: 0.97),
                padding: const EdgeInsets.all(22),
                child: Image.asset(
                  data.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 34),

          // ── Titre ──────────────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color activeColor) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Bouton générique avec léger effet d'enfoncement (scale) au tap,
/// sans interférer avec un InkWell interne (utilisé ici pour "Passer").
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SlideData {
  final String image;
  final String title;
  final String description;
  final Color accentColor;

  const _SlideData({
    required this.image,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}