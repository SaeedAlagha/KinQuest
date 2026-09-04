import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/competitions/models/competition_player_result.dart';
import 'package:kinquest/features/competitions/screens/competition_tie_break_screen.dart';
import 'package:kinquest/features/competitions/screens/monthly_cup_screen.dart';
import 'package:kinquest/features/competitions/screens/weekly_championship_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  Future<void> pumpArabic(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );
    await tester.pump();
  }

  testWidgets('Weekly Championship is Arabic and RTL on a narrow screen', (
    tester,
  ) async {
    await pumpArabic(
      tester,
      const WeeklyChampionshipScreen(developerPreview: true),
    );

    final title = find.text('البطولة الأسبوعية');
    expect(title, findsWidgets);
    expect(
      find.text('أربع ألعاب رسمية، وتتراكم نقاط البطولة عبر كل جولة.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('اكتملت 0 من أصل 4 جولات رسمية'),
      220,
    );
    expect(find.text('اكتملت 0 من أصل 4 جولات رسمية'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('ألعاب هذا الأسبوع'), 220);
    expect(find.text('ألعاب هذا الأسبوع'), findsOneWidget);
    expect(Directionality.of(tester.element(title.first)), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Monthly Cup setup is Arabic and RTL on a narrow screen', (
    tester,
  ) async {
    await pumpArabic(tester, const MonthlyCupScreen(developerPreview: true));

    final title = find.text('الكأس الشهري');
    expect(title, findsWidgets);
    expect(find.text('تم اختيار 4 من أصل 4 متنافسين'), findsOneWidget);
    expect(find.text('اختر فردين من العائلة على الأقل.'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -620));
    await tester.pump();
    expect(find.text('ابدأ الكأس الشهري'), findsOneWidget);

    await tester.tap(find.text('ابدأ الكأس الشهري'));
    await tester.pump();

    expect(find.text('مخطط الكأس الشهري'), findsOneWidget);
    expect(find.text('اكتملت 0 من أصل 3 جولات رسمية'), findsOneWidget);
    expect(Directionality.of(tester.element(title.first)), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  testWidgets('competition tie-break instructions switch to Arabic', (
    tester,
  ) async {
    await pumpArabic(
      tester,
      const CompetitionTieBreakScreen(
        players: [
          CompetitionPlayerResult(
            userId: 'player-1',
            name: 'سارة',
            gameScore: 10,
            placement: 1,
          ),
          CompetitionPlayerResult(
            userId: 'player-2',
            name: 'عمر',
            gameScore: 10,
            placement: 1,
          ),
        ],
      ),
    );

    final title = find.text('كسر التعادل');
    expect(title, findsOneWidget);
    expect(find.text('مرر الهاتف إلى سارة'), findsOneWidget);
    expect(find.text('ابدأ'), findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
