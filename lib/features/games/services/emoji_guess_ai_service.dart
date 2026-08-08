import 'dart:convert';

import 'package:http/http.dart' as http;

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
  static const String _baseUrl = 'http://10.0.2.2:3000';

  Future<List<EmojiGuessPuzzle>> generatePuzzles({
    required String category,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/emoji-guess'),
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
