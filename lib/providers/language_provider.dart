// lib/providers/language_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  String _locale = 'fr';

  String get locale => _locale;
  bool get isFr => _locale == 'fr';
  AppStrings get s => AppStrings(_locale);

  LanguageProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('locale') ?? 'fr';
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    notifyListeners();
  }

  void toggle() => setLocale(_locale == 'fr' ? 'en' : 'fr');
}