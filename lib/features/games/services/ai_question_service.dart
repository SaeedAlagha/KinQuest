import 'dart:convert';

import 'package:http/http.dart' as http;

class AiQuestion {
  final String optionA;
  final String optionB;

  const AiQuestion({required this.optionA, required this.optionB});

  factory AiQuestion.fromJson(Map<String, dynamic> json) {
    return AiQuestion(
      optionA: json['optionA'] as String,
      optionB: json['optionB'] as String,
    );
  }
}

class AiQuestionService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<AiQuestion>> generateWouldYouRatherQuestions({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/would-you-rather'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'category': category, 'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate questions: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final questions = data['questions'] as List<dynamic>;

    return questions
        .map(
          (question) => AiQuestion.fromJson(question as Map<String, dynamic>),
        )
        .toList();
  }
}
