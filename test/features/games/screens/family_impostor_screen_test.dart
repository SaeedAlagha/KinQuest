import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/family_impostor_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('preview setup offers random and selectable categories', (
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
        home: FamilyImpostorScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(find.text('Random mix'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('UAE & Heritage'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('impostor-category-UAE & Heritage')),
    );
    await tester.pump();

    expect(
      find.text('All secret words will come from UAE & Heritage.'),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(find.text('1 round'), findsOneWidget);
    expect(find.text('3 rounds'), findsOneWidget);
    expect(find.text('5 rounds'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();

    expect(find.text('4 selected'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
