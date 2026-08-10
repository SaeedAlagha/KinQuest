import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/games/screens/games_screen.dart';
import 'package:kinquest/features/home/screens/home_screen.dart';

void main() {
  testWidgets('Home and Games render on desktop without layout errors', (
    tester,
  ) async {
    await _setViewport(tester, const Size(1440, 810));
    await _pumpScreen(tester, _homeDashboard);

    expect(find.text('Welcome, Demo User'), findsOneWidget);
    expect(find.text('Demo Family'), findsWidgets);
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
}

const _homeDashboard = HomeDashboard(
  name: 'Demo User',
  familyName: 'Demo Family',
  memberCount: 4,
  tokens: '120',
);

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.lightTheme, home: screen),
  );
  await tester.pumpAndSettle();
}
