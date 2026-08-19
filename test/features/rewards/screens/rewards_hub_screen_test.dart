import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/screens/rewards_hub_screen.dart';

void main() {
  testWidgets('developer preview shows the current rewards catalogue', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());

    expect(find.text('1350'), findsOneWidget);
    expect(find.text('Digital Rewards'), findsOneWidget);
    expect(find.text('Champion Profile Frame'), findsOneWidget);
    expect(find.text('One time'), findsOneWidget);

    expect(find.text('Family Rewards'), findsNothing);
    expect(find.text('Choose Movie Night'), findsNothing);
    expect(find.text('Choose Dinner'), findsNothing);
  });

  testWidgets('developer preview is responsive and blocks digital unlocks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());

    await tester.ensureVisible(find.text('Champion Profile Frame'));
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();

    expect(find.text('Developer Preview is read-only.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp() {
  return const MaterialApp(home: RewardsHubScreen(developerPreview: true));
}
