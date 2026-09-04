// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<_SlideData> _buildSlides(LanguageProvider lang) => [
    _SlideData(
      image: 'assets/images/onboarding1.png',
      title: lang.s.onboarding1Title,
      description: lang.s.onboarding1Desc,
      backgroundColor: const Color(0xFF0B5345), // Vert profond pro pour le fond
      buttonColor: const Color(0xFF48C9B0), // Vert opale doux pour le bouton (lisible et agréable)
    ),
    _SlideData(
      image: 'assets/images/onboarding2.png',
      title: lang.s.onboarding2Title,
      description: lang.s.onboarding2Desc,
      backgroundColor: const Color(0xFF9E2A2B), // Rouge brique doux
      buttonColor: const Color(0xFFC04B3E), // Rouge terre cuite doux
    ),
    _SlideData(
      image: 'assets/images/onboarding3.png',
      title: lang.s.onboarding3Title,
      description: lang.s.onboarding3Desc,
      backgroundColor: const Color(0xFFE5B842), // Jaune or doux
      buttonColor: const Color(0xFFD4AC0D), // Jaune doré doux pour COMMENCER
    ),
  ];

  void _nextPage(int slidesLength) {
    if (_currentPage < slidesLength - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() => _finishOnboarding();

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

    return Scaffold(
      backgroundColor: slide.backgroundColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: slide.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [

              // ── Bouton Passer ─────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                  child: GestureDetector(
                    onTap: _skipOnboarding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        lang.s.onboardingSkip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Carousel ──────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: slides.length,
                  itemBuilder: (context, index) =>
                      _buildSlide(slides[index], lang),
                ),
              ),

              // ── Points indicateurs ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => _buildDot(index, slide.buttonColor),
                  ),
                ),
              ),

              // ── Bouton Suivant / Commencer ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _nextPage(slides.length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: slide.buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == slides.length - 1
                              ? lang.s.onboardingStart.toUpperCase()
                              : lang.s.onboardingNext.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData data, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // ── Ovale blanc avec image ───────────────────────────────
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(200),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 28,
            ),
            child: Image.asset(
              data.image,
              fit: BoxFit.contain,
              height: 260,
            ),
          ),

          const SizedBox(height: 40),

          // ── Titre ────────────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 16),

          // ── Description ──────────────────────────────────────────
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.8),
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SlideData {
  final String image;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color buttonColor;

  const _SlideData({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.buttonColor,
  });
}