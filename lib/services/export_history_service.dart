import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ExportHistoryItem {
  ExportHistoryItem({
    required this.fileName,
    required this.type,
    required this.savedAt,
    required this.location,
  });

  final String fileName;
  final String type;
  final DateTime savedAt;
  final String location;

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'type': type,
      'savedAt': savedAt.toIso8601String(),
      'location': location,
    };
  }

  factory ExportHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExportHistoryItem(
      fileName: json['fileName'] as String? ?? '',
      type: json['type'] as String? ?? '',
      savedAt: DateTime.tryParse(
            json['savedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      location: json['location'] as String? ?? '',
    );
  }
}

class ExportHistoryService {
  static const String _storageKey =
      'aiiz_check_export_history_v1';

  static Future<List<ExportHistoryItem>>
      getHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw) as List<dynamic>;

      return decoded
          .map(
            (item) =>
                ExportHistoryItem.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addHistory(
    ExportHistoryItem item,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final history =
        await getHistory();

    history.insert(
      0,
      item,
    );

    // Maksimal simpan 100 riwayat.
    if (history.length > 100) {
      history.removeRange(
        100,
        history.length,
      );
    }

    final encoded =
        jsonEncode(
      history
          .map(
            (item) => item.toJson(),
          )
          .toList(),
    );

    await prefs.setString(
      _storageKey,
      encoded,
    );
  }

  static Future<void> clearHistory() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _storageKey,
    );
  }
}