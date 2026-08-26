import 'package:flutter/foundation.dart';

enum DigitalRewardCategory {
  profileFrame,
  profileBadge,
  profileTheme,
  celebrationEffect,
  nameplate,
  mascotAccessory,
  mascotOutfit,
  mascotAura;

  static DigitalRewardCategory? tryParse(String? value) {
    for (final category in values) {
      if (category.name == value) return category;
    }

    return null;
  }
}

@immutable
class DigitalRewardDefinition {
  const DigitalRewardDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.category,
    required this.assetKey,
    required this.previewAsset,
    required this.isActive,
    required this.isLimited,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final DigitalRewardCategory category;
  final String assetKey;
  final String previewAsset;
  final bool isActive;
  final bool isLimited;
  final int sortOrder;

  factory DigitalRewardDefinition.fromJson(Map<String, dynamic> json) {
    final category = DigitalRewardCategory.tryParse(
      json['category']?.toString(),
    );

    if (category == null) {
      throw FormatException(
        'Unknown Digital Reward category: ${json['category']}',
      );
    }

    final reward = DigitalRewardDefinition(
      id: json['id']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      category: category,
      assetKey: json['assetKey']?.toString().trim() ?? '',
      previewAsset: json['previewAsset']?.toString().trim() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      isLimited: json['isLimited'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

    if (reward.id.isEmpty ||
        reward.name.isEmpty ||
        reward.assetKey.isEmpty ||
        reward.cost <= 0) {
      throw const FormatException('Digital Reward definition is incomplete.');
    }

    return reward;
  }
}
