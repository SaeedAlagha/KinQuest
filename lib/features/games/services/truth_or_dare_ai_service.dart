import 'dart:convert';

import 'package:http/http.dart' as http;

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
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<TruthOrDarePrompt>> generatePrompts({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/truth-or-dare'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'category': category, 'count': count}),
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
