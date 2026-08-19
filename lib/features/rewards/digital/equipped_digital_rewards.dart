import 'digital_reward_definition.dart';

class EquippedDigitalRewards {
  const EquippedDigitalRewards({
    this.profileFrame = 'default',
    this.profileBadge = 'none',
    this.profileTheme = 'default',
    this.celebrationEffect = 'default',
    this.nameplate = 'default',
  });

  final String profileFrame;
  final String profileBadge;
  final String profileTheme;
  final String celebrationEffect;
  final String nameplate;

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
    );
  }

  String assetFor(DigitalRewardCategory category) {
    return switch (category) {
      DigitalRewardCategory.profileFrame => profileFrame,
      DigitalRewardCategory.profileBadge => profileBadge,
      DigitalRewardCategory.profileTheme => profileTheme,
      DigitalRewardCategory.celebrationEffect => celebrationEffect,
      DigitalRewardCategory.nameplate => nameplate,
    };
  }
}
