import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Create QR
  static Future<Map<String, dynamic>> createQr({
    required String type,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/qr/create/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create QR: ${response.statusCode}\n${response.body}',
    );
  }

  // Get QR history
  static Future<List<dynamic>> getQrHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/qr/history/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load QR history: ${response.statusCode}',
    );
  }

  // Delete QR
  static Future<void> deleteQr(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/qr/$id/delete/'),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete QR: ${response.statusCode}',
      );
    }
  }
}