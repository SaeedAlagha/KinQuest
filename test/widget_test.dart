import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/widgets/sila_brand_mark.dart';
import 'package:kinquest/features/authentication/screens/login_screen.dart';
import 'package:kinquest/features/home/screens/main_navigation_screen.dart';
import 'package:kinquest/features/mascot/screens/sila_studio_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';
import 'package:kinquest/main.dart';

void main() {
  testWidgets('shows the Sila welcome screen', (tester) async {
    await tester.pumpWidget(const SilaApp());

    expect(find.text('Sila'), findsWidgets);
    expect(find.text('صِلَة'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('welcome-sila-spotlight')),
      findsOneWidget,
    );
    expect(find.text('MEET SILA • YOUR FAMILY COMPANION'), findsOneWidget);
    expect(find.text('Closer, one moment at a time.'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byKey(const ValueKey('competition-demo-cta')), findsNothing);
  });

  testWidgets('login omits the legacy mark while signup keeps its branding', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const LoginScreen()));

    expect(find.byType(SilaBrandMark), findsNothing);
    expect(find.text('عام الأسرة 2026'), findsNothing);

    await tester.ensureVisible(find.text('Create one'));
    await tester.tap(find.text('Create one'));
    await tester.pumpAndSettle();

    expect(find.text('Join Sila'), findsOneWidget);
    expect(find.byType(SilaBrandMark), findsOneWidget);
    expect(find.text('عام الأسرة 2026'), findsNothing);
  });

  testWidgets('developer preview navigation works on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(const MainNavigationScreen(developerPreview: true)),
    );
    await tester.pump(const Duration(seconds: 1));

    final navigationBar = find.byType(NavigationBar);

    await tester.tap(_navigationDestination(navigationBar, 'Memories'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Developer Family memories'), findsOneWidget);
    expect(
      find.text('Developer Family preview • Demo data only'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(_navigationDestination(navigationBar, 'Play'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.scrollUntilVisible(
      find.text('Developer Family Leaderboard'),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Developer Family Leaderboard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(_navigationDestination(navigationBar, 'Home'));
    await tester.pump(const Duration(milliseconds: 300));
    tester
        .widget<FilledButton>(find.byKey(const ValueKey('home-sila-action')))
        .onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SilaStudioScreen), findsOneWidget);
    expect(
      tester
          .widget<SilaStudioScreen>(find.byType(SilaStudioScreen))
          .showBackButton,
      isTrue,
    );
    expect(
      tester.widget<SilaStudioScreen>(find.byType(SilaStudioScreen)).active,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(_navigationDestination(navigationBar, 'Profile'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('preview@sila.local'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

Finder _navigationDestination(Finder navigationBar, String label) {
  return find.descendant(
    of: navigationBar,
    matching: find.byWidgetPredicate(
      (widget) => widget is NavigationDestination && widget.label == label,
    ),
  );
}
