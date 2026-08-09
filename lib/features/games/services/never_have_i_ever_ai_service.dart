import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class NeverHaveIEverPrompt {
  final String text;

  const NeverHaveIEverPrompt({required this.text});

  factory NeverHaveIEverPrompt.fromJson(Map<String, dynamic> json) {
    return NeverHaveIEverPrompt(text: json['text'] as String);
  }
}

class NeverHaveIEverAiService {
  Future<List<NeverHaveIEverPrompt>> generatePrompts({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/never-have-i-ever'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'category': category, 'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Never Have I Ever prompts');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final prompts = data['prompts'] as List<dynamic>;

    return prompts
        .map(
          (prompt) =>
              NeverHaveIEverPrompt.fromJson(prompt as Map<String, dynamic>),
        )
        .toList();
  }
}
