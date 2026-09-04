import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'auth_service.dart';

class VerifyService {

  // ═══════════════════════════════════════════
  // HISTORIQUE DES VÉRIFICATIONS
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> getMesVerifications() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/mes-verifications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'total': data['total'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Erreur inconnue',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }
}