import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

import '../utils/offline_quiz_bank.dart';

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
    try {
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
      final rawQuestions = data['questions'] as List<dynamic>;
      final questions = rawQuestions
          .map((item) => TriviaQuestion.fromJson(item as Map<String, dynamic>))
          .where(
            (question) =>
                question.question.trim().isNotEmpty &&
                question.options.length == 4 &&
                question.correctIndex >= 0 &&
                question.correctIndex < 4,
          )
          .take(count)
          .toList();

      if (questions.length == count) return questions;
    } on Object {
      // The real game remains playable when the production AI gateway is down.
    }

    return OfflineQuizBank.questions(
          category: category,
          count: count,
          languageCode: languageCode,
        )
        .map(
          (question) => TriviaQuestion(
            question: question.question,
            options: question.options,
            correctIndex: question.correctIndex,
          ),
        )
        .toList(growable: false);
  }
}
