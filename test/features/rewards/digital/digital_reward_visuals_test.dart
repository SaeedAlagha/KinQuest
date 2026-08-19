import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_visuals.dart';
import 'package:kinquest/features/rewards/digital/equipped_digital_rewards.dart';

void main() {
  testWidgets('equipped cosmetics render every supported profile treatment', (
    tester,
  ) async {
    const rewards = EquippedDigitalRewards(
      profileFrame: 'gold',
      profileBadge: 'champion',
      profileTheme: 'galaxy',
      nameplate: 'neon',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DigitalRewardProfileSurface(
            rewards: rewards,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DigitalRewardAvatar(rewards: rewards),
                DigitalRewardNameplate(name: 'Alya', rewards: rewards),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('digital-profile-theme-galaxy')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('digital-frame-gold')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('digital-badge-champion')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('digital-nameplate-neon')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown cosmetic keys fall back without breaking layout', (
    tester,
  ) async {
    const rewards = EquippedDigitalRewards(
      profileFrame: 'removed-frame',
      profileBadge: 'removed-badge',
      profileTheme: 'removed-theme',
      nameplate: 'removed-nameplate',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DigitalRewardProfileSurface(
            rewards: rewards,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DigitalRewardAvatar(rewards: rewards),
                DigitalRewardNameplate(name: 'Alya', rewards: rewards),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Alya'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('digital-frame-removed-frame')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('digital-nameplate-removed-nameplate')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
