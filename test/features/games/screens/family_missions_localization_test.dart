import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/games/models/family_mission.dart';
import 'package:kinquest/features/games/models/family_mission_localizations.dart';
import 'package:kinquest/features/games/screens/family_missions_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';
import 'package:kinquest/l10n/app_localizations_ar.dart';

void main() {
  test('every catalog mission has Arabic display copy', () {
    final strings = AppLocalizationsAr();

    expect(FamilyMissionCatalog.all, hasLength(27));

    for (final mission in FamilyMissionCatalog.all) {
      final copy = LocalizedFamilyMissionCopy.forMission(strings, mission);

      expect(copy.title, isNotEmpty, reason: mission.id);
      expect(copy.description, isNotEmpty, reason: mission.id);
      expect(copy.proofHint, isNotEmpty, reason: mission.id);
      expect(copy.title, isNot(mission.title), reason: mission.id);
      expect(copy.description, isNot(mission.description), reason: mission.id);
      expect(copy.proofHint, isNot(mission.proofHint), reason: mission.id);
    }
  });

  testWidgets('Arabic mission board is RTL and usable on a narrow screen', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabicMissions(tester);

    final heading = find.text('أنجزوا المزيد معًا');
    expect(heading, findsOneWidget);
    expect(Directionality.of(tester.element(heading)), TextDirection.rtl);
    expect(find.text('التقدم الشخصي • 0/6'), findsOneWidget);
    expect(find.text('تقدم العائلة • 0/4'), findsOneWidget);
    expect(find.textContaining('هذا الأسبوع •'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('أظهر تقديرك'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('أظهر تقديرك'), findsOneWidget);
    expect(find.text('لطف'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('اخرجوا في نزهة عائلية'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('اخرجوا في نزهة عائلية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic personal mission details are fully localized', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabicMissions(tester);

    final personalMission = find.text('أظهر تقديرك');
    await tester.scrollUntilVisible(
      personalMission,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(personalMission),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(personalMission);
    await tester.pumpAndSettle();

    expect(find.text('مهمة شخصية'), findsOneWidget);
    expect(find.text('إرشادات الإثبات'), findsOneWidget);
    expect(find.text('فترة الانتظار'), findsOneWidget);
    expect(find.text('إرسال الإثبات'), findsOneWidget);
    expect(find.text('ليس الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Arabic family proof flow localizes participant and photo steps',
    (tester) async {
      await _setViewport(tester, const Size(320, 568));
      await _pumpArabicMissions(tester);

      final familyWalk = find.text('اخرجوا في نزهة عائلية');
      await tester.scrollUntilVisible(
        familyWalk,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(familyWalk);
      await tester.pumpAndSettle();

      final submitProof = find.text('إرسال الإثبات');
      await tester.ensureVisible(submitProof);
      await tester.pumpAndSettle();
      await tester.tap(submitProof);
      await tester.pumpAndSettle();

      expect(find.text('من شارك؟'), findsOneWidget);
      expect(find.text('أنت'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);

      final continueButton = find.widgetWithText(FilledButton, 'متابعة');
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

      await tester.tap(find.text('Alex'));
      await tester.pump();

      expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('التقاط صورة'), findsOneWidget);
      expect(find.text('اختيار صورة أو لقطة شاشة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpArabicMissions(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const FamilyMissionsScreen(developerPreview: true),
    ),
  );
  await tester.pumpAndSettle();
}
