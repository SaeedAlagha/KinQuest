import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/secret_mission_screen.dart';
import 'package:kinquest/features/games/services/secret_mission_ai_service.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  test('offline missions preserve players and support Arabic', () {
    final missions = SecretMissionAiService.offlineMissions(
      playerNames: const ['Amal', 'Omar', 'Mariam'],
      languageCode: 'ar',
    );

    expect(missions.map((mission) => mission.playerName), [
      'Amal',
      'Omar',
      'Mariam',
    ]);
    expect(missions, hasLength(3));
    expect(
      missions.every(
        (mission) => RegExp(r'[\u0600-\u06FF]').hasMatch(mission.mission),
      ),
      isTrue,
    );
  });

  testWidgets('developer preview runs the Arabic private mission flow in RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SecretMissionScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('sila-game-coach-banner')),
      findsOneWidget,
    );
    expect(find.text('مهمة سرية'), findsOneWidget);
    expect(find.text('من سيلعب؟'), findsOneWidget);
    expect(find.textContaining('10 دقائق لكل جولة'), findsOneWidget);

    final startButton = find.text('ابدأ مهمة سرية');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.text('الجولة 1 من 3'), findsOneWidget);
    expect(find.text('اللاعب 1 من 4'), findsOneWidget);
    expect(find.text('Alex، خذ الهاتف'), findsOneWidget);

    await tester.tap(find.text('اكشف مهمتي'));
    await tester.pump();

    expect(find.text('مهمتك السرية'), findsOneWidget);
    expect(find.text('تذكّرها ولا تخبر أحدًا.'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
