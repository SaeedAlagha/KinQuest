import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/games/screens/games_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Quick Play lists and opens Trivia and Emoji Guess', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const GamesScreen(
          developerPreview: true,
          participantIds: {'preview-1', 'preview-2', 'preview-3', 'preview-4'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trivia'), findsOneWidget);
    expect(find.text('Emoji Guess'), findsOneWidget);

    await tester.ensureVisible(find.text('Trivia'));
    await tester.tap(find.text('Trivia'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Trivia')),
      findsOneWidget,
    );
    expect(find.text('Who is playing?'), findsOneWidget);
    expect(find.text('Alex'), findsWidgets);
    expect(find.text('1 round'), findsOneWidget);
    expect(find.text('3 rounds'), findsOneWidget);
    expect(find.text('5 rounds'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Emoji Guess'));
    await tester.tap(find.text('Emoji Guess'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Emoji Guess'),
      ),
      findsOneWidget,
    );
    expect(find.text('Who is playing?'), findsOneWidget);
    expect(find.text('Taylor'), findsWidgets);
    expect(find.text('1 round'), findsOneWidget);
    expect(find.text('3 rounds'), findsOneWidget);
    expect(find.text('5 rounds'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
