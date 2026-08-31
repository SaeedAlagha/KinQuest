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
      ['Home', 'Memories', 'Play', 'Missions', 'Sila', 'Rewards', 'Profile'],
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
      6,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sila is a direct destination between Missions and Rewards', (
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
    await tester.pump(const Duration(seconds: 1));

    var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    final labels = navigation.destinations
        .map((destination) => (destination as NavigationDestination).label)
        .toList();
    expect(navigation.destinations, hasLength(7));
    expect(labels.indexOf('Sila'), labels.indexOf('Missions') + 1);
    expect(labels.indexOf('Rewards'), labels.indexOf('Sila') + 1);
    expect(
      navigation.labelBehavior,
      NavigationDestinationLabelBehavior.onlyShowSelected,
    );

    await tester.tap(find.byKey(const ValueKey('nav-sila-destination')));
    await tester.pump(const Duration(milliseconds: 300));

    navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 4);
    final studio = tester.widget<SilaStudioScreen>(
      find.byType(SilaStudioScreen),
    );
    expect(studio.showBackButton, isFalse);
    expect(studio.active, isTrue);
    expect(studio.stageFocusRequest, 1);

    await tester.drag(
      find.byKey(const ValueKey('sila-studio-scroll')),
      const Offset(0, -1100),
    );
    await tester.pump(const Duration(milliseconds: 200));
    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(0);
    await tester.pump(const Duration(milliseconds: 200));
    tester
        .widget<NavigationBar>(find.byType(NavigationBar))
        .onDestinationSelected!(4);
    await tester.pump(const Duration(milliseconds: 300));

    final revisitedStudio = tester.widget<SilaStudioScreen>(
      find.byType(SilaStudioScreen),
    );
    expect(revisitedStudio.stageFocusRequest, 2);
    final revisitedStage = tester.getRect(
      find.byKey(const ValueKey('sila-studio-mascot')),
    );
    expect(revisitedStage.top, lessThan(700));
    expect(revisitedStage.bottom, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home greeting and desktop Sila identity open the Studio', (
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
    await tester.tap(find.byKey(const ValueKey('desktop-sila-brand-action')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      4,
    );
    expect(find.byType(SilaStudioScreen), findsOneWidget);

    // Simulate a previous deep wardrobe visit. The Home chat action must not
    // inherit this scroll offset when it returns to Sila.
    await tester.drag(
      find.byKey(const ValueKey('sila-studio-scroll')),
      const Offset(0, -1100),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getRect(find.byKey(const ValueKey('sila-studio-mascot'))).bottom,
      lessThan(500),
    );

    final homeDestination = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Home'),
    );
    await tester.tap(homeDestination);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('home-sila-action')));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('sila-chat-panel')),
    );

    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      4,
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
    expect(
      chatRect.top,
      lessThan(
        tester.getRect(find.byKey(const ValueKey('sila-studio-mascot'))).top,
      ),
    );

    final draftInput = find.byKey(const ValueKey('sila-chat-input'));
    await tester.ensureVisible(draftInput);
    await tester.enterText(draftInput, 'A family-game draft');

    // The Home CTA is intentionally chat-first, but a later normal Sila tab
    // visit must restore the character showcase as the Studio's hero without
    // destroying an unfinished conversation.
    await tester.tap(homeDestination);
    await tester.pump(const Duration(milliseconds: 300));
    tester
        .widget<NavigationRail>(find.byType(NavigationRail))
        .onDestinationSelected!(4);
    await tester.pump(const Duration(milliseconds: 300));

    final normalStudio = tester.widget<SilaStudioScreen>(
      find.byType(SilaStudioScreen),
    );
    expect(normalStudio.chatFocusRequest, 0);
    expect(
      tester.getRect(find.byKey(const ValueKey('sila-studio-mascot'))).top,
      lessThan(
        tester.getRect(find.byKey(const ValueKey('sila-chat-panel'))).top,
      ),
    );
    expect(
      tester.widget<TextField>(draftInput).controller?.text,
      'A family-game draft',
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 30; frame += 1) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
}
