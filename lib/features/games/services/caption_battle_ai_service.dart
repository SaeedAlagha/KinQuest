import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class CaptionBattleAiService {
  const CaptionBattleAiService();

  Future<List<String>> generateModes({
    required int count,
    String languageCode = 'en',
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/caption-battle/modes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'count': count, 'language': languageCode}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Caption Battle server returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawModes = data['modes'] as List<dynamic>?;

    if (rawModes == null || rawModes.isEmpty) {
      throw Exception('Missing Caption Battle modes');
    }

    return rawModes
        .whereType<String>()
        .map((mode) => mode.trim())
        .where((mode) => mode.isNotEmpty)
        .toList();
  }
}
