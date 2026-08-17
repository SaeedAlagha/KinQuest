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

    Future<bool> checkAnswer({
    required String expectedAnswer,
    required String playerAnswer,
  }) async {
    final normalizedExpected = _normalize(expectedAnswer);
    final normalizedPlayer = _normalize(playerAnswer);

    if (normalizedExpected == normalizedPlayer) {
      return true;
    }
    if (normalizedExpected.contains(normalizedPlayer) ||
    normalizedPlayer.contains(normalizedExpected)) {
  return true;
  } 

    final response = await http
        .post(
          ApiConfig.endpoint('/api/emoji-guess/check-answer'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'expectedAnswer': expectedAnswer,
            'playerAnswer': playerAnswer,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return false;
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return data['match'] == true;
  }

 String _normalize(String value) {
  final ignoredWords = {
    'the',
    'a',
    'an',
  };

  final words = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .split(' ')
      .where(
        (word) =>
            word.isNotEmpty &&
            !ignoredWords.contains(word),
      )
      .toList();

  return words.join(' ');
}
}