import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

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
  Future<List<TriviaQuestion>> generateQuestions({
    required String category,
    required int count,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/trivia'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'category': category,
            'count': count,
            'language': languageCode,
          }),
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
