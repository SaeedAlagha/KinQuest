import 'digital_reward_definition.dart';

class EquippedDigitalRewards {
  const EquippedDigitalRewards({
    this.profileFrame = 'default',
    this.profileBadge = 'none',
    this.profileTheme = 'default',
    this.celebrationEffect = 'default',
    this.nameplate = 'default',
    this.mascotAccessory = 'none',
    this.mascotOutfit = 'none',
    this.mascotAura = 'none',
  });

  final String profileFrame;
  final String profileBadge;
  final String profileTheme;
  final String celebrationEffect;
  final String nameplate;
  final String mascotAccessory;
  final String mascotOutfit;
  final String mascotAura;

  factory EquippedDigitalRewards.fromMap(Map<String, dynamic>? data) {
    String value(String key, String fallback) {
      final configured = data?[key]?.toString().trim();
      return configured == null || configured.isEmpty ? fallback : configured;
    }

    return EquippedDigitalRewards(
      profileFrame: value('profileFrame', 'default'),
      profileBadge: value('profileBadge', 'none'),
      profileTheme: value('profileTheme', 'default'),
      celebrationEffect: value('celebrationEffect', 'default'),
      nameplate: value('nameplate', 'default'),
      mascotAccessory: value('mascotAccessory', 'none'),
      mascotOutfit: value('mascotOutfit', 'none'),
      mascotAura: value('mascotAura', 'none'),
    );
  }

  String assetFor(DigitalRewardCategory category) {
    return switch (category) {
      DigitalRewardCategory.profileFrame => profileFrame,
      DigitalRewardCategory.profileBadge => profileBadge,
      DigitalRewardCategory.profileTheme => profileTheme,
      DigitalRewardCategory.celebrationEffect => celebrationEffect,
      DigitalRewardCategory.nameplate => nameplate,
      DigitalRewardCategory.mascotAccessory => mascotAccessory,
      DigitalRewardCategory.mascotOutfit => mascotOutfit,
      DigitalRewardCategory.mascotAura => mascotAura,
    };
  }

  EquippedDigitalRewards copyWith({
    String? profileFrame,
    String? profileBadge,
    String? profileTheme,
    String? celebrationEffect,
    String? nameplate,
    String? mascotAccessory,
    String? mascotOutfit,
    String? mascotAura,
  }) {
    return EquippedDigitalRewards(
      profileFrame: profileFrame ?? this.profileFrame,
      profileBadge: profileBadge ?? this.profileBadge,
      profileTheme: profileTheme ?? this.profileTheme,
      celebrationEffect: celebrationEffect ?? this.celebrationEffect,
      nameplate: nameplate ?? this.nameplate,
      mascotAccessory: mascotAccessory ?? this.mascotAccessory,
      mascotOutfit: mascotOutfit ?? this.mascotOutfit,
      mascotAura: mascotAura ?? this.mascotAura,
    );
  }

  EquippedDigitalRewards withAsset(
    DigitalRewardCategory category,
    String assetKey,
  ) {
    return switch (category) {
      DigitalRewardCategory.profileFrame => copyWith(profileFrame: assetKey),
      DigitalRewardCategory.profileBadge => copyWith(profileBadge: assetKey),
      DigitalRewardCategory.profileTheme => copyWith(profileTheme: assetKey),
      DigitalRewardCategory.celebrationEffect => copyWith(
        celebrationEffect: assetKey,
      ),
      DigitalRewardCategory.nameplate => copyWith(nameplate: assetKey),
      DigitalRewardCategory.mascotAccessory => copyWith(
        mascotAccessory: assetKey,
      ),
      DigitalRewardCategory.mascotOutfit => copyWith(mascotOutfit: assetKey),
      DigitalRewardCategory.mascotAura => copyWith(mascotAura: assetKey),
    };
  }
}
