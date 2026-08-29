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
      [
        'Home',
        'Memories',
        'Play',
        'Missions',
        'Wardrobe',
        'Rewards',
        'Profile',
      ],
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

  testWidgets('Wardrobe is a direct destination between Missions and Rewards', (
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
    expect(labels.indexOf('Wardrobe'), labels.indexOf('Missions') + 1);
    expect(labels.indexOf('Rewards'), labels.indexOf('Wardrobe') + 1);
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
    expect(tester.takeException(), isNull);
  });
}
