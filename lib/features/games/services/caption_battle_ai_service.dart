import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class CaptionBattleAiService {
  const CaptionBattleAiService();

  static const List<String> promptStyles = [
    'Surprise Me',
    'Storytelling',
    'Headlines & Posts',
    'Wild Ideas',
  ];

  static const Map<String, List<String>> _modesByStyle = {
    'Storytelling': [
      'What Happened Next?',
      'Before This Photo',
      'Plot Twist',
      'Future Memory',
      'Family Documentary',
    ],
    'Headlines & Posts': [
      'Breaking News',
      'Sports Commentary',
      'Movie Title',
      'Social Media Post',
      'Travel Postcard',
    ],
    'Wild Ideas': [
      'Wrong Answers Only',
      'Secret Thoughts',
      'Superhero Origin',
      'Advertisement',
      'One-Word Challenge',
    ],
  };

  Future<List<String>> generateModes({
    required int count,
    String languageCode = 'en',
    String promptStyle = 'Surprise Me',
  }) async {
    final selectedStyle = promptStyles.contains(promptStyle)
        ? promptStyle
        : promptStyles.first;
    final response = await http
        .post(
          ApiConfig.endpoint('/api/caption-battle/modes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'count': count,
            'language': languageCode,
            'style': selectedStyle,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Caption Battle server returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawModes = data['modes'] as List<dynamic>?;

    if (rawModes == null || rawModes.isEmpty) {
      throw Exception('Missing Caption Battle modes');
    }

    return rawModes
        .whereType<String>()
        .map((mode) => mode.trim())
        .where((mode) => mode.isNotEmpty)
        .toList();
  }

  static List<String> offlineModes({
    required int count,
    String promptStyle = 'Surprise Me',
    Random? random,
  }) {
    final selectedStyle = promptStyles.contains(promptStyle)
        ? promptStyle
        : promptStyles.first;
    final candidates = selectedStyle == 'Surprise Me'
        ? _modesByStyle.values.expand((modes) => modes).toList()
        : List<String>.from(_modesByStyle[selectedStyle]!);

    candidates.shuffle(random ?? Random.secure());
    return candidates.take(count.clamp(1, 5)).toList();
  }

  static String descriptionForStyle(String promptStyle) {
    return switch (promptStyle) {
      'Storytelling' =>
        'Imagine the moment before, after, or far into the future.',
      'Headlines & Posts' =>
        'Turn the photo into news, a movie, commentary, or a social post.',
      'Wild Ideas' =>
        'Invent unexpected answers, secret thoughts, and playful identities.',
      _ => 'Mix storytelling, headlines, posts, and unexpected challenges.',
    };
  }

  static String examplesForStyle(String promptStyle) {
    return switch (promptStyle) {
      'Storytelling' => 'What Happened Next? • Before This Photo • Plot Twist',
      'Headlines & Posts' => 'Breaking News • Movie Title • Social Media Post',
      'Wild Ideas' => 'Wrong Answers Only • Secret Thoughts • Superhero Origin',
      _ => 'What Happened Next? • Breaking News • Wrong Answers Only',
    };
  }

  static String instructionForMode(String mode) {
    return switch (mode) {
      'What Happened Next?' => 'Imagine the very next moment in this story.',
      'Before This Photo' => 'Invent what happened just before the photo.',
      'Plot Twist' => 'Add an unexpected twist to this family moment.',
      'Future Memory' =>
        'Describe how the family will remember this years later.',
      'Family Documentary' => 'Narrate the photo like a dramatic documentary.',
      'Breaking News' => 'Write the headline for this breaking family story.',
      'Sports Commentary' => 'Call the action like a championship commentator.',
      'Movie Title' => 'Give this moment its perfect movie title.',
      'Social Media Post' => 'Write the post that would go with this photo.',
      'Travel Postcard' => 'Turn the photo into a postcard message.',
      'Wrong Answers Only' =>
        'Explain the photo with a confidently wrong answer.',
      'Secret Thoughts' => 'Write what someone in the photo might be thinking.',
      'Superhero Origin' => 'Turn this moment into a hero origin story.',
      'Advertisement' =>
        'Sell this family moment like a dramatic advertisement.',
      'One-Word Challenge' =>
        'Capture the entire moment in one brilliant word.',
      _ => 'Write a creative caption that matches this round theme.',
    };
  }

  static String hintForMode(String mode) {
    return switch (mode) {
      'What Happened Next?' => 'And then, without warning...',
      'Before This Photo' => 'Five seconds earlier...',
      'Breaking News' => 'Family makes history after...',
      'Movie Title' => 'The Great Family...',
      'Secret Thoughts' => 'I really hope nobody notices...',
      'One-Word Challenge' => 'One unforgettable word...',
      _ => 'Write something your family will remember...',
    };
  }
}
