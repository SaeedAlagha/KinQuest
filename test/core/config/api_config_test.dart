import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/config/api_config.dart';

void main() {
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
