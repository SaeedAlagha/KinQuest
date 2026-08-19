import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class PassTheBombAiService {
  const PassTheBombAiService();

  Future<List<String>> generateCategories({int count = 5}) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/pass-the-bomb'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'count': count}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Pass the Bomb categories');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final categories = data['categories'] as List<dynamic>;

    return categories.cast<String>();
  }

  Future<PassTheBombValidationResult> validateAnswer({
    required String category,
    required String answer,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/pass-the-bomb/validate'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'category': category, 'answer': answer}),
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
