import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class SecretMissionAiService {
  const SecretMissionAiService();

  Future<List<SecretMission>> generateMissions({
    required List<String> playerNames,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/secret-mission'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'players': playerNames, 'language': languageCode}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Secret Mission missions');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawMissions = data['missions'] as List<dynamic>?;

    if (rawMissions == null) {
      throw Exception('Missing missions');
    }

    return rawMissions.map((item) {
      final mission = item as Map<String, dynamic>;

      return SecretMission(
        playerName: mission['playerName'] as String? ?? '',
        mission: mission['mission'] as String? ?? '',
      );
    }).toList();
  }
}

class SecretMission {
  const SecretMission({required this.playerName, required this.mission});

  final String playerName;
  final String mission;
}
