import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'KINQUEST_API_BASE_URL',
  );

  static String get baseUrl {
    return resolveBaseUrl(
      configuredBaseUrl: _configuredBaseUrl,
      isRelease: kReleaseMode,
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

  @visibleForTesting
  static String resolveBaseUrl({
    required String configuredBaseUrl,
    required bool isRelease,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    final normalizedBaseUrl = configuredBaseUrl.trim().replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    if (normalizedBaseUrl.isNotEmpty) {
      final uri = Uri.tryParse(normalizedBaseUrl);

      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        throw StateError(
          'KINQUEST_API_BASE_URL must be an absolute HTTP(S) URL.',
        );
      }

      if (isRelease && uri.scheme != 'https') {
        throw StateError(
          'KINQUEST_API_BASE_URL must use HTTPS in release builds.',
        );
      }

      if (uri.scheme != 'http' && uri.scheme != 'https') {
        throw StateError(
          'KINQUEST_API_BASE_URL must use the HTTP or HTTPS scheme.',
        );
      }

      return normalizedBaseUrl;
    }

    if (isRelease) {
      throw StateError('KINQUEST_API_BASE_URL is required in release builds.');
    }

    if (isWeb || platform != TargetPlatform.android) {
      return 'http://localhost:3000';
    }

    return 'http://10.0.2.2:3000';
  }

  static Uri endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Future<Map<String, String>> authenticatedJsonHeaders({
    Future<String?> Function()? tokenProvider,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final idToken = await (tokenProvider ?? _currentUserIdToken)();

    if (idToken != null && idToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $idToken';
    }

    return headers;
  }

  static Future<String?> _currentUserIdToken() async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }
}
