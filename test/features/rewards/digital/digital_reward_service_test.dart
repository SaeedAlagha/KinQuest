import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_service.dart';

void main() {
  test('purchase sends only the canonical reward identifier', () async {
    late http.Request captured;
    final service = DigitalRewardService(
      client: MockClient((request) async {
        captured = request;
        return http.Response('{}', 201);
      }),
      endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
      headersProvider: () async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer test-token',
      },
    );

    await service.purchase('frame_gold');

    expect(captured.url.path, '/api/digital-rewards/purchase');
    expect(captured.headers['authorization'], 'Bearer test-token');
    expect(jsonDecode(captured.body), {'rewardId': 'frame_gold'});
  });

  test('mutation surfaces a safe server error', () async {
    final service = DigitalRewardService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'You already own this Digital Reward.'}),
          409,
        ),
      ),
      endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
      headersProvider: () async => {},
    );

    expect(
      () => service.purchase('frame_gold'),
      throwsA(predicate((error) => error.toString().contains('already own'))),
    );
  });
}
