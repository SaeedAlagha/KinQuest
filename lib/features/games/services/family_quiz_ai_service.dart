import 'dart:convert';

import 'package:http/http.dart' as http;

class FamilyQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const FamilyQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory FamilyQuizQuestion.fromJson(Map<String, dynamic> json) {
    return FamilyQuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class FamilyQuizAiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<FamilyQuizQuestion>> generateQuestions({
    required String category,
    required int count,
    required List<String> familyMembers,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/family-quiz'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'category': category,
            'count': count,
            'familyMembers': familyMembers,
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
