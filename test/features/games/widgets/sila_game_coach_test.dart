import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/features/games/widgets/sila_game_coach.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('coach is a visible phone pill and repeats a gentle motion', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(_app(const SilaGameCoachButton()));
    await tester.pump();

    final semantics = tester.ensureSemantics();
    final coachNode = tester.getSemantics(
      find.bySemanticsLabel(RegExp(r'^Sila, your family companion')),
    );
    expect(
      coachNode.getSemanticsData().actions & ui.SemanticsAction.tap.index,
      isNot(0),
    );
    semantics.dispose();

    expect(find.byKey(const ValueKey('sila-game-coach-phone')), findsOneWidget);
    expect(find.text('Sila'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sila-game-coach-expanded')),
      findsNothing,
    );
    expect(
      tester
          .getBottomLeft(find.byKey(const ValueKey('sila-game-coach-phone')))
          .dy,
      lessThan(760),
    );

    final firstMascot = tester.widget<SilaMascot>(find.byType(SilaMascot));
    expect(firstMascot.animate, isTrue);
    expect(firstMascot.motion, SilaMascotMotion.gameReady);
    expect(
      find.byKey(const ValueKey('sila-game-coach-motion-0')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 4500));
    expect(
      find.byKey(const ValueKey('sila-game-coach-motion-1')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('coach uses an icon-only fallback on very narrow layouts', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 640));
    await tester.pumpWidget(_app(const SilaGameCoachButton()));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('sila-game-coach-compact')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sila-game-coach-phone')), findsNothing);
    expect(
      tester
          .widget<Material>(
            find.byKey(const ValueKey('sila-game-coach-surface')),
          )
          .clipBehavior,
      Clip.none,
    );
    expect(
      tester
          .getBottomLeft(find.byKey(const ValueKey('sila-game-coach-compact')))
          .dy,
      lessThan(560),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('winner reaction stays compact over phone result screens', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(const SilaGameCoachButton(tone: SilaGameCoachTone.winner)),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('sila-game-coach-compact')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('sila-game-coach-phone')), findsNothing);
    expect(
      tester
          .getBottomLeft(find.byKey(const ValueKey('sila-game-coach-compact')))
          .dy,
      lessThan(730),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final (tone, pose, motion, messageFragment) in [
    (
      SilaGameCoachTone.thinking,
      SilaMascotPose.thinking,
      SilaMascotMotion.thinking,
      'preparing',
    ),
    (
      SilaGameCoachTone.celebrating,
      SilaMascotPose.celebrating,
      SilaMascotMotion.celebrate,
      'Amazing teamwork',
    ),
    (
      SilaGameCoachTone.oops,
      SilaMascotPose.oops,
      SilaMascotMotion.excited,
      'did not work',
    ),
    (
      SilaGameCoachTone.winner,
      SilaMascotPose.winner,
      SilaMascotMotion.celebrate,
      'What a finish',
    ),
  ]) {
    testWidgets('$tone gives Sila a contextual reaction', (tester) async {
      await _setViewport(tester, const Size(800, 844));
      await tester.pumpWidget(_app(SilaGameCoachButton(tone: tone)));
      await tester.pump();

      final mascot = tester.widget<SilaMascot>(find.byType(SilaMascot));
      expect(mascot.pose, pose);
      expect(mascot.motion, motion);
      expect(find.textContaining(messageFragment), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('coach expands on wide layouts and remains RTL-safe', (
    tester,
  ) async {
    await _setViewport(tester, const Size(1000, 720));
    await tester.pumpWidget(
      _app(const SilaGameCoachButton(), locale: const Locale('ar')),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('sila-game-coach-expanded')),
      findsOneWidget,
    );
    expect(find.text('صلة'), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('sila-game-coach-expanded'))),
      ),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('coach disables recurring motion for reduced-motion users', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(const SilaGameCoachButton(), disableAnimations: true),
    );
    await tester.pump();

    final mascot = tester.widget<SilaMascot>(find.byType(SilaMascot));
    expect(mascot.animate, isFalse);

    await tester.pump(const Duration(seconds: 5));
    expect(
      find.byKey(const ValueKey('sila-game-coach-motion-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-game-coach-motion-1')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opening the coach shows the full looping Sila guide', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(const SilaGameCoachButton(message: 'Keep cheering together!')),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('sila-game-coach-button')));
    await tester.pump(const Duration(milliseconds: 300));

    final guide = tester.widget<SilaMascotGuide>(find.byType(SilaMascotGuide));
    expect(guide.message, 'Keep cheering together!');
    expect(guide.loop, isTrue);
    expect(
      find.descendant(
        of: find.byType(SilaMascotGuide),
        matching: find.text('Keep cheering together!'),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('setup banner loops unless reduced motion is requested', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await tester.pumpWidget(_bannerApp(disableAnimations: false));
    await tester.pump();

    var guide = tester.widget<SilaMascotGuide>(
      find.byKey(const ValueKey('sila-game-coach-banner')),
    );
    expect(guide.loop, isTrue);
    expect(guide.loopPause, const Duration(milliseconds: 2600));
    expect(guide.animate, isTrue);

    await tester.pumpWidget(_bannerApp(disableAnimations: true));
    await tester.pump();

    guide = tester.widget<SilaMascotGuide>(
      find.byKey(const ValueKey('sila-game-coach-banner')),
    );
    expect(guide.loop, isTrue);
    expect(guide.animate, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _app(Widget coach, {Locale? locale, bool disableAnimations = false}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: disableAnimations),
      child: child!,
    ),
    home: Scaffold(floatingActionButton: coach),
  );
}

Widget _bannerApp({required bool disableAnimations}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: disableAnimations),
      child: child!,
    ),
    home: const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SilaGameCoachBanner(),
        ),
      ),
    ),
  );
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
