import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_visuals.dart';
import 'package:kinquest/features/rewards/screens/rewards_hub_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('catalogue is responsive and blocks preview purchases', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1350'), findsOneWidget);
    expect(find.text('Digital Rewards'), findsOneWidget);
    expect(find.text('Golden Profile Frame'), findsOneWidget);
    expect(find.text('Profile Frames'), findsOneWidget);
    expect(find.text('Celebration Effects'), findsOneWidget);
    expect(find.text('Sila Wardrobe'), findsOneWidget);
    expect(find.text('Family Guardian Crown'), findsOneWidget);
    expect(find.byType(DigitalRewardPreview), findsNWidgets(18));
    expect(find.text('Equipped'), findsOneWidget);
    expect(find.text('Equip'), findsOneWidget);
    expect(find.text('Family Rewards'), findsNothing);

    await tester.ensureVisible(find.text('Neon Profile Frame'));
    await tester.pump();

    final buyButton = find.byKey(
      const ValueKey('digital-reward-action-frame_neon'),
    );
    expect(buyButton, findsOneWidget);

    await tester.tap(buyButton);
    await tester.pump();

    expect(find.text('Developer Preview is read-only.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: RewardsHubScreen(developerPreview: true),
  );
}
