class ApiConfig {
static const String baseUrl = 'https://headset-beliefs-custody-oriented.trycloudflare.com';

  // Auth
  static const String register = '$baseUrl/api/register';
  static const String login    = '$baseUrl/api/login';
  static const String logout   = '$baseUrl/api/logout';

  // Produits
  static const String verify   = '$baseUrl/api/verify';
  static const String search   = '$baseUrl/api/search';

  // Signalements
  static const String report          = '$baseUrl/api/report';
  static const String mesSignalements = '$baseUrl/api/mes-signalements';

  // Historique
  static const String mesVerifications = '$baseUrl/api/mes-verifications';

  // Assistant IA
  static const String assistant = '$baseUrl/api/assistant';

  // Notifications
  static const String notifications = '$baseUrl/api/notifications';
  static const String fcmToken      = '$baseUrl/api/fcm-token'; // ← ICI

  // Profil
  static const String profile  = '$baseUrl/api/profile';
  static const String password = '$baseUrl/api/password';

  // Reset mot de passe
  static const String forgotPassword   = '$baseUrl/api/forgot-password';
  static const String verifyResetCode  = '$baseUrl/api/verify-reset-code';
  static const String resetPassword    = '$baseUrl/api/reset-password';
}



