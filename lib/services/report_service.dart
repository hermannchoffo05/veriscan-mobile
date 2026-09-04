import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'auth_service.dart';

class ReportService {

  static Future<Map<String, dynamic>> soumettre({
    required String description,
    String? nomSignalant,
    String? contactSignalant,
    String? token,
    double? latitude,
    double? longitude,
    String? localisation,
    File? photo,
  }) async {
    try {
      final authToken = await AuthService.getToken();

      final uri = Uri.parse(ApiConfig.report);
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll({
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      });

      // Champs texte
      request.fields['description'] = description;
      if (nomSignalant != null && nomSignalant.isNotEmpty) {
        request.fields['nom_signalant'] = nomSignalant;
      }
      if (contactSignalant != null && contactSignalant.isNotEmpty) {
        request.fields['contact_signalant'] = contactSignalant;
      }
      if (token != null) request.fields['token'] = token;
      if (latitude != null)  request.fields['latitude']     = latitude.toString();
      if (longitude != null) request.fields['longitude']    = longitude.toString();
      if (localisation != null) request.fields['localisation'] = localisation;

      // Photo optionnelle
      if (photo != null) {
        final ext      = photo.path.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photo.path,
            contentType: http.MediaType('image', mimeType.split('/').last),
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data     = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Erreur inconnue',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }
}