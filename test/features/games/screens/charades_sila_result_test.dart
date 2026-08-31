import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/charades_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Charades completion Sila does not cover replay actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const CharadesScreen(),
      ),
    );
    await tester.pump();

    final oneRound = find.byKey(const ValueKey('round-option-1'));
    await tester.ensureVisible(oneRound);
    await tester.tap(oneRound);
    await tester.pump();

    final start = find.widgetWithText(ElevatedButton, 'Start Charades');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await _pumpUntilFound(tester, find.text('Next Prompt'));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next Prompt'));
    await tester.pump(const Duration(milliseconds: 300));

    final coach = find.byKey(const ValueKey('sila-game-coach-phone'));
    final playAgain = find.widgetWithText(ElevatedButton, 'Play Again');
    final changeCategory = find.widgetWithText(
      OutlinedButton,
      'Change Category',
    );
    expect(coach, findsOneWidget);
    expect(playAgain, findsOneWidget);
    expect(changeCategory, findsOneWidget);
    expect(tester.getRect(coach).overlaps(tester.getRect(playAgain)), isFalse);
    expect(
      tester.getRect(coach).overlaps(tester.getRect(changeCategory)),
      isFalse,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 80; frame += 1) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget);
}
