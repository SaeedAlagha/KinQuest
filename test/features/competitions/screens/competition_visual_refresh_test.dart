import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/widgets/family_year_banner.dart';
import 'package:kinquest/core/widgets/sila_page_backdrop.dart';
import 'package:kinquest/features/competitions/screens/competitions_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('competition hub keeps its branded layout on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const CompetitionsScreen(developerPreview: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SilaPageBackdrop), findsOneWidget);
    expect(find.byType(UaeColorRibbon), findsOneWidget);
    expect(find.byKey(const ValueKey('competition-sila-host')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sila-mascot-aura-victory_burst')),
      findsOneWidget,
    );
    expect(find.text('Play Together'), findsOneWidget);
    expect(find.text('Quick Play'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Monthly Cup'), 300);
    expect(find.text('Monthly Cup'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Family Trophy Cabinet'), 300);
    expect(find.text('Monthly Cup Trophy'), findsOneWidget);
    expect(find.text('Weekly Champion Medal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
