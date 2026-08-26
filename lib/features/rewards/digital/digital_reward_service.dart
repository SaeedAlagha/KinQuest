import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'equipped_digital_rewards.dart';

typedef DigitalRewardEndpointBuilder = Uri Function(String path);
typedef DigitalRewardHeadersProvider = Future<Map<String, String>> Function();

enum DigitalRewardFailure {
  signInRequired,
  unavailable,
  userNotFound,
  familyRequired,
  familyNotFound,
  notFamilyMember,
  alreadyOwned,
  insufficientTokens,
  notOwned,
  invalidReward,
  updateFailed,
}

class DigitalRewardException implements Exception {
  const DigitalRewardException(this.failure, {this.debugMessage});

  final DigitalRewardFailure failure;
  final String? debugMessage;

  @override
  String toString() => 'DigitalRewardException($failure)';
}

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

    throw DigitalRewardException(
      _failureFor(response.statusCode, message),
      debugMessage: message,
    );
  }

  DigitalRewardFailure _failureFor(int statusCode, String message) {
    final normalized = message.toLowerCase();

    if (statusCode == 401 ||
        normalized.contains('sign in') ||
        normalized.contains('session')) {
      return DigitalRewardFailure.signInRequired;
    }
    if (normalized.contains('not currently available')) {
      return DigitalRewardFailure.unavailable;
    }
    if (normalized.contains('user not found')) {
      return DigitalRewardFailure.userNotFound;
    }
    if (normalized.contains('join a family')) {
      return DigitalRewardFailure.familyRequired;
    }
    if (normalized.contains('family not found')) {
      return DigitalRewardFailure.familyNotFound;
    }
    if (normalized.contains('not a member')) {
      return DigitalRewardFailure.notFamilyMember;
    }
    if (normalized.contains('already own')) {
      return DigitalRewardFailure.alreadyOwned;
    }
    if (normalized.contains('enough tokens')) {
      return DigitalRewardFailure.insufficientTokens;
    }
    if (normalized.contains('do not own')) {
      return DigitalRewardFailure.notOwned;
    }
    if (normalized.contains('invalid')) {
      return DigitalRewardFailure.invalidReward;
    }
    return DigitalRewardFailure.updateFailed;
  }
}
