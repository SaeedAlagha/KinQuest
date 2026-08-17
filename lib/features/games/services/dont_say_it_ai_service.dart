import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class DontSayItCard {
  const DontSayItCard({
    required this.word,
    required this.forbiddenWords,
  });

  final String word;
  final List<String> forbiddenWords;

  factory DontSayItCard.fromJson(Map<String, dynamic> json) {
    return DontSayItCard(
      word: json['word'] as String,
      forbiddenWords: List<String>.from(
        json['forbiddenWords'] as List<dynamic>,
      ),
    );
  }
}

class DontSayItAiService {
  const DontSayItAiService();

  Future<List<DontSayItCard>> generateCards({
    required int count,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/dont-say-it'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'count': count,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Don\'t Say It cards');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final cards = data['cards'] as List<dynamic>;

    return cards
        .map(
          (item) => DontSayItCard.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}