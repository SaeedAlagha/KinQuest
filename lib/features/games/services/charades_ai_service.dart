import 'dart:convert';

import 'package:http/http.dart' as http;

class CharadesPrompt {
  final String text;

  const CharadesPrompt({required this.text});

  factory CharadesPrompt.fromJson(Map<String, dynamic> json) {
    return CharadesPrompt(text: json['text'] as String);
  }
}

class CharadesAiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<CharadesPrompt>> generatePrompts({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/charades'),
          headers: {'Content-Type': 'application/json'},
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
