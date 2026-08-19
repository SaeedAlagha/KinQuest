import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class FamilyQuizQuestion {
  final String question;
  final List<String> options;

  const FamilyQuizQuestion({required this.question, required this.options});

  factory FamilyQuizQuestion.fromJson(Map<String, dynamic> json) {
    return FamilyQuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
    );
  }
}

class FamilyQuizAiService {
  const FamilyQuizAiService();

  Future<List<FamilyQuizQuestion>> generateQuestions({
    required String category,
    required int count,
    required List<String> familyMembers,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/family-quiz'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'category': category,
            'count': count,
            'familyMembers': familyMembers,
            'language': languageCode,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Family Quiz questions');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>;

    return questions
        .map(
          (item) => FamilyQuizQuestion.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
