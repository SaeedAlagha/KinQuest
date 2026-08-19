import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/config/api_config.dart';

void main() {
  group('release API configuration', () {
    test('accepts and normalizes an HTTPS endpoint', () {
      expect(
        ApiConfig.resolveBaseUrl(
          configuredBaseUrl: ' https://api.sila.example/// ',
          isRelease: true,
          isWeb: true,
          platform: TargetPlatform.iOS,
        ),
        'https://api.sila.example',
      );
    });

    test('rejects a missing release endpoint', () {
      expect(
        () => ApiConfig.resolveBaseUrl(
          configuredBaseUrl: '',
          isRelease: true,
          isWeb: true,
          platform: TargetPlatform.android,
        ),
        throwsStateError,
      );
    });

    test('rejects a non-HTTPS release endpoint', () {
      expect(
        () => ApiConfig.resolveBaseUrl(
          configuredBaseUrl: 'http://api.sila.example',
          isRelease: true,
          isWeb: false,
          platform: TargetPlatform.android,
        ),
        throwsStateError,
      );
    });

    test('keeps local development defaults outside release mode', () {
      expect(
        ApiConfig.resolveBaseUrl(
          configuredBaseUrl: '',
          isRelease: false,
          isWeb: true,
          platform: TargetPlatform.macOS,
        ),
        'http://localhost:3000',
      );
      expect(
        ApiConfig.resolveBaseUrl(
          configuredBaseUrl: '',
          isRelease: false,
          isWeb: false,
          platform: TargetPlatform.android,
        ),
        'http://10.0.2.2:3000',
      );
    });
  });

  test('authenticated JSON headers attach a Firebase bearer token', () async {
    final headers = await ApiConfig.authenticatedJsonHeaders(
      tokenProvider: () async => 'signed-family-token',
    );

    expect(headers['Content-Type'], 'application/json');
    expect(headers['Authorization'], 'Bearer signed-family-token');
  });

  test('JSON headers omit authorization when no user is signed in', () async {
    final headers = await ApiConfig.authenticatedJsonHeaders(
      tokenProvider: () async => null,
    );

    expect(headers, {'Content-Type': 'application/json'});
  });
}
