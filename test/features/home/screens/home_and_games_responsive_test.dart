import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/games/screens/games_screen.dart';
import 'package:kinquest/features/home/screens/home_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Home and Games render on desktop without layout errors', (
    tester,
  ) async {
    await _setViewport(tester, const Size(1440, 810));
    await _pumpScreen(tester, _homeDashboard);

    expect(find.text('Welcome, Demo User'), findsOneWidget);
    expect(find.text('Demo Family'), findsWidgets);
    expect(
      find.byKey(const ValueKey('sila-mascot-accessory-guardian_crown')),
      findsOneWidget,
    );
    final homeMascot = tester.widget<SilaMascot>(find.byType(SilaMascot));
    expect(homeMascot.pose, SilaMascotPose.welcome);
    expect(homeMascot.motion, SilaMascotMotion.gameReady);
    expect(find.byKey(const ValueKey('home-sila-action')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpScreen(tester, const GamesScreen());

    expect(find.text('Find your next family favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and Games render on mobile without overflow', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpScreen(tester, _homeDashboard);

    expect(find.text('Welcome, Demo User'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpScreen(tester, const GamesScreen());

    expect(find.text('Find your next family favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home Sila respects reduced motion and remains actionable', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    var openedStudio = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(2),
          ),
          child: HomeDashboard(
            name: 'Demo User',
            familyName: 'Demo Family',
            memberCount: 4,
            tokens: '120',
            developerPreview: true,
            onSilaStudio: () => openedStudio = true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.widget<SilaMascot>(find.byType(SilaMascot)).animate, isFalse);
    final action = find.byKey(const ValueKey('home-sila-action'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pump();

    expect(openedStudio, isTrue);
    expect(tester.takeException(), isNull);
  });
}

const _homeDashboard = HomeDashboard(
  name: 'Demo User',
  familyName: 'Demo Family',
  memberCount: 4,
  tokens: '120',
  mascotAccessory: SilaMascotAccessories.guardianCrown,
);

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}
