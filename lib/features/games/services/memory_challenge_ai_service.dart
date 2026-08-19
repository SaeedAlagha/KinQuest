import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class MemoryChallengeQuestion {
  const MemoryChallengeQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.type,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String type;

  factory MemoryChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return MemoryChallengeQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      type: json['type'] as String,
    );
  }
}

class MemoryChallengeAiService {
  Future<List<MemoryChallengeQuestion>> generateQuestions({
    required String imageUrl,
    required String title,
    required String description,
    required String location,
    required String date,
    int count = 1,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/memory-challenge'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'imageUrl': imageUrl,
            'title': title,
            'description': description,
            'location': location,
            'date': date,
            'count': count,
          }),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to generate Memory Challenge questions: '
        '${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>;

    return questions
        .map(
          (item) =>
              MemoryChallengeQuestion.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
