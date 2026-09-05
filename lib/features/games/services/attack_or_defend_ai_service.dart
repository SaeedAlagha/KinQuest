import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

import '../utils/offline_quiz_bank.dart';

class AttackOrDefendQuestion {
  const AttackOrDefendQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  factory AttackOrDefendQuestion.fromJson(Map<String, dynamic> json) {
    return AttackOrDefendQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class AttackOrDefendAiService {
  Future<List<AttackOrDefendQuestion>> generateQuestions({
    required String category,
    required String difficulty,
    required int count,
    required String languageCode,
  }) async {
    try {
      final response = await http
          .post(
            ApiConfig.endpoint('/api/attack-or-defend'),
            headers: await ApiConfig.authenticatedJsonHeaders(),
            body: jsonEncode({
              'category': category,
              'difficulty': difficulty,
              'count': count,
              'language': languageCode,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception('Failed to generate Attack or Defend questions');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawQuestions = data['questions'] as List<dynamic>?;
      final questions = rawQuestions
          ?.map(
            (item) =>
                AttackOrDefendQuestion.fromJson(item as Map<String, dynamic>),
          )
          .where(
            (question) =>
                question.question.trim().isNotEmpty &&
                question.options.length == 4 &&
                question.correctIndex >= 0 &&
                question.correctIndex < 4,
          )
          .take(count)
          .toList();

      if (questions != null && questions.length == count) return questions;
    } on Object {
      // The real game remains playable when the production AI gateway is down.
    }

    return OfflineQuizBank.questions(
          category: category,
          count: count,
          languageCode: languageCode,
        )
        .map(
          (question) => AttackOrDefendQuestion(
            question: question.question,
            options: question.options,
            correctIndex: question.correctIndex,
          ),
        )
        .toList(growable: false);
  }
}
