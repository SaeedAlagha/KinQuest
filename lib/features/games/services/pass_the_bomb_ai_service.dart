import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class PassTheBombAiService {
  const PassTheBombAiService();

  Future<List<String>> generateCategories({
    int count = 5,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/pass-the-bomb'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'count': count, 'language': languageCode}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Pass the Bomb categories');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>;

    return categories.cast<String>();
  }

  static List<String> offlineCategories({
    required int count,
    required String languageCode,
    Random? random,
  }) {
    final categories = languageCode == 'ar'
        ? <String>[
            'أطعمة تبدأ بحرف م',
            'أماكن في الإمارات',
            'حيوانات',
            'أشياء في المنزل',
            'رياضات',
            'أفلام عائلية',
            'أشياء تأخذها في السفر',
            'مهن',
          ]
        : <String>[
            'Foods beginning with P',
            'Places in the UAE',
            'Animals',
            'Things at home',
            'Sports',
            'Family movies',
            'Things you take when travelling',
            'Jobs',
          ];
    categories.shuffle(random ?? Random.secure());
    return List<String>.generate(
      count,
      (index) => categories[index % categories.length],
    );
  }

  Future<PassTheBombValidationResult> validateAnswer({
    required String category,
    required String answer,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/pass-the-bomb/validate'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'category': category,
            'answer': answer,
            'language': languageCode,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to validate Pass the Bomb answer');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return PassTheBombValidationResult(
      valid: data['valid'] as bool? ?? false,
      reason: data['reason'] as String? ?? '',
    );
  }
}

class PassTheBombValidationResult {
  const PassTheBombValidationResult({
    required this.valid,
    required this.reason,
  });

  final bool valid;
  final String reason;
}
