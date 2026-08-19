import 'dart:convert';

import 'package:flutter/services.dart';

import 'digital_reward_definition.dart';

abstract final class DigitalRewardCatalog {
  static const assetPath = 'assets/config/digital_rewards.json';

  static Future<List<DigitalRewardDefinition>> load() async {
    final source = await rootBundle.loadString(assetPath);
    return decode(source);
  }

  static List<DigitalRewardDefinition> decode(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! List) {
      throw const FormatException('Digital Reward catalog must be a list.');
    }

    final rewards = decoded
        .map(
          (item) => DigitalRewardDefinition.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .where((reward) => reward.isActive)
        .toList();

    final identifiers = rewards.map((reward) => reward.id).toSet();
    if (identifiers.length != rewards.length) {
      throw const FormatException('Digital Reward identifiers must be unique.');
    }

    rewards.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(rewards);
  }
}
