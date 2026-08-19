import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/screens/my_digital_rewards_screen.dart';

void main() {
  testWidgets('owned collection groups cosmetics and supports live actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MyDigitalRewardsScreen(developerPreview: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Sila style'), findsOneWidget);
    expect(find.text('Profile Frames'), findsOneWidget);
    expect(find.text('Golden Profile Frame'), findsOneWidget);
    expect(find.text('Currently equipped'), findsOneWidget);

    await tester.ensureVisible(find.text('Neon Profile Frame'));
    await tester.tap(find.widgetWithText(FilledButton, 'Equip').first);
    await tester.pump();

    expect(find.text('Developer Preview is read-only.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
