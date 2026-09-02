import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/qr_history.dart';

class StorageService {
  static const String _historyKey = 'qr_history';

  static Future<List<QRHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final storedData = prefs.getString(_historyKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(storedData);

      return decoded
          .map(
            (item) => QRHistory.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveQR(QRHistory qr) async {
    final history = await getHistory();

    history.insert(0, qr);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _historyKey,
      jsonEncode(
        history.map((item) => item.toJson()).toList(),
      ),
    );
  }

  static Future<void> deleteQR(String id) async {
    final history = await getHistory();

    history.removeWhere((item) => item.id == id);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _historyKey,
      jsonEncode(
        history.map((item) => item.toJson()).toList(),
      ),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_historyKey);
  }
}