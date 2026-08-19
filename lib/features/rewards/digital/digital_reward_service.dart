import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'equipped_digital_rewards.dart';

typedef DigitalRewardEndpointBuilder = Uri Function(String path);
typedef DigitalRewardHeadersProvider = Future<Map<String, String>> Function();

class DigitalRewardService {
  DigitalRewardService({
    http.Client? client,
    this.firestore,
    DigitalRewardEndpointBuilder? endpointBuilder,
    DigitalRewardHeadersProvider? headersProvider,
  }) : _client = client ?? http.Client(),
       _endpointBuilder = endpointBuilder ?? ApiConfig.endpoint,
       _headersProvider = headersProvider ?? ApiConfig.authenticatedJsonHeaders;

  final http.Client _client;
  final FirebaseFirestore? firestore;
  final DigitalRewardEndpointBuilder _endpointBuilder;
  final DigitalRewardHeadersProvider _headersProvider;

  Stream<EquippedDigitalRewards> watchEquipped(String userId) {
    return (firestore ?? FirebaseFirestore.instance)
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('digitalRewards')
        .snapshots()
        .map((snapshot) => EquippedDigitalRewards.fromMap(snapshot.data()));
  }

  Future<void> purchase(String rewardId) {
    return _post('/api/digital-rewards/purchase', {'rewardId': rewardId});
  }

  Future<void> equip(String rewardId) {
    return _post('/api/digital-rewards/equip', {'rewardId': rewardId});
  }

  Future<void> unequip(String rewardId) {
    return _post('/api/digital-rewards/unequip', {'rewardId': rewardId});
  }

  Future<void> _post(String path, Map<String, dynamic> payload) async {
    final response = await _client
        .post(
          _endpointBuilder(path),
          headers: await _headersProvider(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message = 'Digital Reward could not be updated.';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['error'] is String) {
        message = data['error'] as String;
      }
    } on FormatException {
      // Keep the privacy-safe fallback when a proxy returns a non-JSON body.
    }

    throw Exception(message);
  }
}
