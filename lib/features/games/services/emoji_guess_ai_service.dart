import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class EmojiGuessPuzzle {
  final String emojis;
  final String answer;
  final String hint;

  const EmojiGuessPuzzle({
    required this.emojis,
    required this.answer,
    required this.hint,
  });

  factory EmojiGuessPuzzle.fromJson(Map<String, dynamic> json) {
    return EmojiGuessPuzzle(
      emojis: json['emojis'] as String,
      answer: json['answer'] as String,
      hint: json['hint'] as String,
    );
  }
}

class EmojiGuessAiService {
  Future<List<EmojiGuessPuzzle>> generatePuzzles({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/emoji-guess'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'category': category, 'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Emoji Guess puzzles');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final puzzles = data['puzzles'] as List<dynamic>;

    return puzzles
        .map((item) => EmojiGuessPuzzle.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
