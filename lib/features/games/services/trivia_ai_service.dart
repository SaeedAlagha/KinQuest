import 'dart:convert';

import 'package:http/http.dart' as http;

class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class TriviaAiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<TriviaQuestion>> generateQuestions({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/trivia'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'category': category, 'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate trivia questions');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>;

    return questions
        .map((item) => TriviaQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
