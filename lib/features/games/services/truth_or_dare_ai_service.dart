import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class TruthOrDarePrompt {
  final String type;
  final String text;

  const TruthOrDarePrompt({required this.type, required this.text});

  factory TruthOrDarePrompt.fromJson(Map<String, dynamic> json) {
    return TruthOrDarePrompt(
      type: json['type'] as String,
      text: json['text'] as String,
    );
  }
}

class TruthOrDareAiService {
  Future<List<TruthOrDarePrompt>> generatePrompts({
    required String category,
    required int count,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/truth-or-dare'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'category': category,
            'count': count,
            'language': languageCode,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Truth or Dare prompts');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final prompts = data['prompts'] as List<dynamic>;

    return prompts
        .map((item) => TruthOrDarePrompt.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
