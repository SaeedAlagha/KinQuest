import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/caption_battle_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('preview setup offers varied caption prompt styles', (
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
        home: CaptionBattleScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('sila-game-coach-banner')),
      findsOneWidget,
    );
    expect(find.text('Prompt variety'), findsOneWidget);
    expect(find.text('Surprise Me'), findsOneWidget);
    expect(find.text('Storytelling'), findsOneWidget);
    expect(find.text('Headlines & Posts'), findsOneWidget);
    expect(find.text('Wild Ideas'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('caption-style-Storytelling')),
    );
    await tester.tap(find.byKey(const ValueKey('caption-style-Storytelling')));
    await tester.pump();

    expect(
      find.text('What Happened Next? • Before This Photo • Plot Twist'),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('caption-round-option-5')),
    );
    expect(find.text('1 round'), findsOneWidget);
    expect(find.text('3 rounds'), findsOneWidget);
    expect(find.text('5 rounds'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview setup localizes prompt variety and RTL in Arabic', (
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
        home: CaptionBattleScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(find.text('معركة التعليقات'), findsWidgets);
    expect(find.text('تنوع التحديات'), findsOneWidget);
    expect(find.text('فاجئني'), findsOneWidget);
    expect(find.text('سرد القصص'), findsOneWidget);
    expect(find.text('عناوين ومنشورات'), findsOneWidget);
    expect(find.text('أفكار جامحة'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
