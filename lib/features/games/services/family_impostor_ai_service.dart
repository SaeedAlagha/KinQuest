import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class FamilyImpostorRound {
  const FamilyImpostorRound({
    required this.category,
    required this.word,
  });

  final String category;
  final String word;

  factory FamilyImpostorRound.fromJson(Map<String, dynamic> json) {
    return FamilyImpostorRound(
      category: json['category'] as String,
      word: json['word'] as String,
    );
  }
}

class FamilyImpostorAiService {
  const FamilyImpostorAiService();

  Future<List<FamilyImpostorRound>> generateRounds({
    int count = 5,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/family-impostor'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'rounds': count,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Family Impostor rounds');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rounds = data['rounds'] as List<dynamic>;

    return rounds
        .map(
          (item) => FamilyImpostorRound.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}