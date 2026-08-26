import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/attack_or_defend_screen.dart';
import 'package:kinquest/features/games/screens/code_breaker_screen.dart';
import 'package:kinquest/features/games/screens/games_screen.dart';
import 'package:kinquest/features/games/screens/risk_it_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('duel game catalog is localized in Arabic', (tester) async {
    await _pumpArabicGame(tester, const GamesScreen(developerPreview: true));

    expect(find.text('ألعاب المواجهة'), findsOneWidget);
    expect(find.text('كاسر الشفرة'), findsOneWidget);
    expect(find.text('هاجم أو دافع'), findsOneWidget);
    expect(find.text('غامر بها'), findsOneWidget);
    expect(find.text('Duel Games'), findsNothing);
    expect(find.text('Code Breaker'), findsNothing);
    _expectRtlAndClean(tester);
  });

  testWidgets('Code Breaker setup is Arabic, RTL, and responsive', (
    tester,
  ) async {
    await _pumpArabicGame(
      tester,
      const CodeBreakerScreen(developerPreview: true),
    );

    expect(find.text('كاسر الشفرة'), findsWidgets);
    expect(find.text('من سيلعب؟'), findsOneWidget);
    expect(find.text('اختر لاعبين اثنين بالضبط.'), findsOneWidget);
    expect(find.text('الصعوبة'), findsOneWidget);
    expect(find.text('Code Breaker'), findsNothing);
    _expectRtlAndClean(tester);
  });

  testWidgets('Risk It setup is Arabic, RTL, and responsive', (tester) async {
    await _pumpArabicGame(tester, const RiskItScreen(developerPreview: true));

    expect(find.text('غامر بها'), findsWidgets);
    expect(find.text('من سيلعب؟'), findsOneWidget);
    expect(find.text('الفئة'), findsOneWidget);
    expect(find.text('متنوع'), findsOneWidget);
    expect(find.text('Risk It'), findsNothing);
    _expectRtlAndClean(tester);
  });

  testWidgets('Attack or Defend setup is Arabic, RTL, and responsive', (
    tester,
  ) async {
    await _pumpArabicGame(
      tester,
      const AttackOrDefendScreen(developerPreview: true),
    );

    expect(find.text('هاجم أو دافع'), findsWidgets);
    expect(find.text('من سيتنافس؟'), findsOneWidget);
    expect(find.text('الأفضل من'), findsOneWidget);
    expect(find.text('ابدأ المعركة'), findsOneWidget);
    expect(find.text('Attack or Defend'), findsNothing);
    _expectRtlAndClean(tester);
  });
}

Future<void> _pumpArabicGame(WidgetTester tester, Widget game) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: game,
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

void _expectRtlAndClean(WidgetTester tester) {
  expect(
    Directionality.of(tester.element(find.byType(Scaffold).first)),
    TextDirection.rtl,
  );
  expect(tester.takeException(), isNull);
}
