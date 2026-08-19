import 'dart:convert';

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

  Future<List<DrawAndGuessPrompt>> generatePrompts({int count = 6}) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/draw-and-guess'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'count': count}),
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
}
