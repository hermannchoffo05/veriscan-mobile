import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../constants/api_config.dart';

class AuthService {

  // ═══════════════════════════════════════════
  // GOOGLE SIGN-IN
  // ═══════════════════════════════════════════
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '500539036794-j6u4km96f0h18ili6p94p74d6f2m08q3.apps.googleusercontent.com',
  );

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Connexion Google annulée'};
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        return {'success': false, 'message': 'Impossible de récupérer le token Google'};
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'id_token': idToken}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_role', data['user']['role'] ?? 'consumer');
        if (data['user']['avatar'] != null) {
          await prefs.setString('user_avatar', data['user']['avatar']);
        }
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Erreur Google Sign-In : ${e.toString()}'};
    }
  }

  // ═══════════════════════════════════════════
  // FACEBOOK SIGN-IN
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status != LoginStatus.success) {
        return {'success': false, 'message': 'Connexion Facebook annulée'};
      }
      final String? accessToken = result.accessToken?.tokenString;
      if (accessToken == null) {
        return {'success': false, 'message': 'Impossible de récupérer le token Facebook'};
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/facebook'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'access_token': accessToken}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_role', data['user']['role'] ?? 'consumer');
        if (data['user']['avatar'] != null) {
          await prefs.setString('user_avatar', data['user']['avatar']);
        }
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Erreur Facebook Sign-In : ${e.toString()}'};
    }
  }

  // ═══════════════════════════════════════════
  // INSCRIPTION
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'name':                  name,
          'email':                 email,
          'password':              password,
          'password_confirmation': password,
          'phone':                 phone ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_role', data['user']['role']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  // ═══════════════════════════════════════════
  // CONNEXION
  // ═══════════════════════════════════════════
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'email':    email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_role', data['user']['role']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  // ═══════════════════════════════════════════
  // DÉCONNEXION
  // ═══════════════════════════════════════════
  static Future<void> logout() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_avatar');
    await prefs.remove('user_avatar_local');
  }

  // ═══════════════════════════════════════════
  // VÉRIFIER SI CONNECTÉ
  // ═══════════════════════════════════════════
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════
  // RÉCUPÉRER LE TOKEN
  // ═══════════════════════════════════════════
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ═══════════════════════════════════════════
  // RÉCUPÉRER LE NOM UTILISATEUR
  // ═══════════════════════════════════════════
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'Utilisateur';
  }

  // ═══════════════════════════════════════════
  // RÉCUPÉRER L'EMAIL
  // ═══════════════════════════════════════════
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // ═══════════════════════════════════════════
  // SAUVEGARDER LE NOM
  // ═══════════════════════════════════════════
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // ═══════════════════════════════════════════
  // SAUVEGARDER L'EMAIL
  // ═══════════════════════════════════════════
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // ═══════════════════════════════════════════
  // RÉCUPÉRER LA PHOTO DE PROFIL (chemin local)
  // ═══════════════════════════════════════════
  static Future<String?> getLocalAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar_local');
  }

  // ═══════════════════════════════════════════
  // SAUVEGARDER LA PHOTO DE PROFIL (chemin local)
  // ═══════════════════════════════════════════
  static Future<void> saveLocalAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar_local', path);
  }

  // ═══════════════════════════════════════════
  // SUPPRIMER LA PHOTO DE PROFIL
  // ═══════════════════════════════════════════
  static Future<void> removeLocalAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_avatar_local');
  }
}