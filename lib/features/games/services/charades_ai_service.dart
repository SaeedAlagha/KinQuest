import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class CharadesPrompt {
  final String text;

  const CharadesPrompt({required this.text});

  factory CharadesPrompt.fromJson(Map<String, dynamic> json) {
    return CharadesPrompt(text: json['text'] as String);
  }
}

class CharadesAiService {
  Future<List<CharadesPrompt>> generatePrompts({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/charades'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'category': category, 'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate charades prompts');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final prompts = data['prompts'] as List<dynamic>;

    return prompts
        .map(
          (prompt) => CharadesPrompt.fromJson(prompt as Map<String, dynamic>),
        )
        .toList();
  }
}
