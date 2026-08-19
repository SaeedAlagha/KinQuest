import 'dart:convert';
import 'dart:math';

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
          headers: await ApiConfig.authenticatedJsonHeaders(),
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

  static List<SecretMission> offlineMissions({
    required List<String> playerNames,
    required String languageCode,
    Random? random,
  }) {
    final prompts = languageCode == 'ar'
        ? <String>[
            'اجعل أحد أفراد العائلة يقول اسمك من دون أن تطلب ذلك مباشرة.',
            'اجعل أحدهم يتفقد الوقت.',
            'اجعل فردًا من العائلة يضحك.',
            'أقنع شخصين أن يتصافحا بيديهما عاليًا.',
            'اجعل أحدهم يحضر كوب ماء.',
            'ابدأ نقاشًا عن الوجبة العائلية المفضلة.',
            'اجعل أحدهم يقول كلمة «حقًا».',
            'اجعل فردًا من العائلة يعرض صورة على هاتفه.',
            'أقنع أحدهم بتغيير مكان جلوسه.',
            'اجعل شخصين يتفقان على فيلم يشاهدانه معًا.',
          ]
        : <String>[
            'Get a family member to say your name without asking directly.',
            'Get someone to check the time.',
            'Make one family member laugh.',
            'Convince two people to high-five.',
            'Get someone to bring a glass of water.',
            'Start a discussion about the family’s favorite meal.',
            'Get someone to say the word “really”.',
            'Get a family member to show a photo on their phone.',
            'Convince someone to change where they are sitting.',
            'Get two people to agree on a movie to watch together.',
          ];

    prompts.shuffle(random ?? Random.secure());

    return List<SecretMission>.generate(playerNames.length, (index) {
      return SecretMission(
        playerName: playerNames[index],
        mission: prompts[index % prompts.length],
      );
    });
  }
}

class SecretMission {
  const SecretMission({required this.playerName, required this.mission});

  final String playerName;
  final String mission;
}
