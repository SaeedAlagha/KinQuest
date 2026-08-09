import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'KINQUEST_API_BASE_URL',
  );

  static String get baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.trim();

    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'http://localhost:3000';
    }

    return 'http://10.0.2.2:3000';
  }

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
