import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/screens/my_digital_rewards_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('owned collection groups cosmetics and supports live actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyDigitalRewardsScreen(developerPreview: true),
      ),
    );
    await _pumpUntilFound(tester, find.text('Your Sila style'));

    expect(find.text('Your Sila style'), findsOneWidget);
    expect(find.text('Profile Frames'), findsOneWidget);
    expect(find.text('Golden Profile Frame'), findsOneWidget);
    expect(find.text('Currently equipped'), findsOneWidget);

    await tester.ensureVisible(find.text('Neon Profile Frame'));
    await tester.tap(find.widgetWithText(FilledButton, 'Equip').first);
    await tester.pump();

    expect(
      find.text('Developer preview is read-only. No data was changed.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 100 && finder.evaluate().isEmpty; frame += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
