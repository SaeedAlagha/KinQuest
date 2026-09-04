import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/home/screens/main_navigation_screen.dart';
import 'package:kinquest/features/mascot/screens/sila_studio_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Family Overview opens the family profile from Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const MainNavigationScreen(developerPreview: true),
      ),
    );
    await tester.pumpAndSettle();

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      navigation.destinations
          .map((destination) => (destination as NavigationDestination).label)
          .toList(),
      ['Home', 'Memories', 'Play', 'Missions', 'Rewards', 'Profile'],
    );

    final overviewButton = find.widgetWithText(FilledButton, 'Family Overview');
    await tester.ensureVisible(overviewButton);
    await tester.tap(overviewButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Profile')),
      findsOneWidget,
    );
    expect(find.text('Developer Family'), findsWidgets);
    expect(find.text('5 family members'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and desktop Sila actions open the chat-first Studio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const MainNavigationScreen(developerPreview: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ask Sila for today’s idea'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    final brandNode = tester.getSemantics(
      find.bySemanticsLabel('Open Sila Studio and chat'),
    );
    expect(
      brandNode.getSemanticsData().actions & ui.SemanticsAction.tap.index,
      isNot(0),
    );
    semantics.dispose();

    tester
        .widget<InkWell>(
          find.byKey(const ValueKey('desktop-sila-brand-action')),
        )
        .onTap!();
    await _pumpUntilFound(tester, find.byType(SilaStudioScreen));
    expect(find.byType(SilaStudioScreen), findsOneWidget);
    expect(
      tester
          .widget<SilaStudioScreen>(find.byType(SilaStudioScreen))
          .showBackButton,
      isTrue,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('home-sila-action')))
        .onPressed!();
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('sila-chat-panel')),
    );

    final focusedStudio = tester.widget<SilaStudioScreen>(
      find.byType(SilaStudioScreen),
    );
    expect(focusedStudio.active, isTrue);
    expect(focusedStudio.chatFocusRequest, 1);
    expect(find.byKey(const ValueKey('sila-chat-panel')), findsOneWidget);
    final chatRect = tester.getRect(
      find.byKey(const ValueKey('sila-chat-panel')),
    );
    expect(chatRect.top, lessThan(800));
    expect(chatRect.bottom, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 30; frame += 1) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}
