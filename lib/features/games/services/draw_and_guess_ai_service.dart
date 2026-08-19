import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class DrawAndGuessPrompt {
  const DrawAndGuessPrompt({required this.text});

  final String text;

  factory DrawAndGuessPrompt.fromJson(Map<String, dynamic> json) {
    return DrawAndGuessPrompt(text: json['text'] as String);
  }
}

class DrawAndGuessAiService {
  const DrawAndGuessAiService();

  Future<List<DrawAndGuessPrompt>> generatePrompts({
    int count = 6,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/draw-and-guess'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'count': count, 'language': languageCode}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Draw & Guess prompts');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final prompts = data['prompts'] as List<dynamic>;

    return prompts
        .map(
          (item) => DrawAndGuessPrompt.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  static List<DrawAndGuessPrompt> offlinePrompts({
    required int count,
    required String languageCode,
    Random? random,
  }) {
    final values = languageCode == 'ar'
        ? <String>[
            'قلعة في الصحراء',
            'عائلة في نزهة',
            'صقر يطير',
            'روبوت يطبخ',
            'قطة ترتدي نظارة',
            'سيارة على القمر',
            'كعكة عيد ميلاد',
            'نخلة بجانب البحر',
            'مظلة في المطر',
            'جمل يركب دراجة',
            'منزل فوق شجرة',
            'سمكة تقرأ كتابًا',
          ]
        : <String>[
            'A castle in the desert',
            'A family picnic',
            'A flying falcon',
            'A robot cooking',
            'A cat wearing glasses',
            'A car on the moon',
            'A birthday cake',
            'A palm tree by the sea',
            'An umbrella in the rain',
            'A camel riding a bicycle',
            'A treehouse',
            'A fish reading a book',
          ];
    values.shuffle(random ?? Random.secure());
    return List<DrawAndGuessPrompt>.generate(
      count,
      (index) => DrawAndGuessPrompt(text: values[index % values.length]),
    );
  }
}
