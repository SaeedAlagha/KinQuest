import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/competitions/screens/daily_challenge_screen.dart';
import 'package:kinquest/features/home/screens/home_screen.dart';
import 'package:kinquest/features/home/screens/main_navigation_screen.dart';
import 'package:kinquest/features/mascot/screens/sila_studio_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Arabic navigation and Play catalogue render right to left', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpLocalized(
      tester,
      const MainNavigationScreen(developerPreview: true),
    );

    final navigationBar = find.byType(NavigationBar);
    final homeLabel = find.descendant(
      of: navigationBar,
      matching: find.text('الرئيسية'),
    );

    expect(homeLabel, findsOneWidget);
    expect(Directionality.of(tester.element(homeLabel)), TextDirection.rtl);
    expect(
      find.text('معاينة عائلة المطوّر • بيانات تجريبية فقط'),
      findsOneWidget,
    );

    await tester.tap(_navigationDestination(navigationBar, 'اللعب'));
    await tester.pumpAndSettle();

    expect(find.text('العبوا معًا'), findsOneWidget);
    expect(find.text('لعب سريع'), findsOneWidget);

    final quickPlayView = find.widgetWithText(FilledButton, 'عرض').first;
    await tester.ensureVisible(quickPlayView);
    await tester.pumpAndSettle();
    await tester.tap(quickPlayView);
    await tester.pumpAndSettle();

    expect(find.text('الألعاب'), findsOneWidget);
    expect(find.text('اختاروا لعبتكم العائلية المفضلة'), findsOneWidget);
    expect(find.text('اختبار العائلة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic Home remains usable on a narrow screen', (tester) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpLocalized(
      tester,
      const HomeDashboard(
        name: 'أمل',
        familyName: 'عائلة صلة',
        memberCount: 4,
        tokens: '120',
        developerPreview: true,
      ),
    );

    expect(find.text('مرحبًا، أمل'), findsOneWidget);
    expect(find.text('جذور • روابط • نمو'), findsOneWidget);

    final dailyChallenge = find.text('تحدي اليوم');
    await tester.scrollUntilVisible(dailyChallenge, 250);
    expect(dailyChallenge, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic seven-destination navigation fits at 320px', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpLocalized(
      tester,
      const MainNavigationScreen(developerPreview: true),
    );

    var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    final labels = navigation.destinations
        .map((destination) => (destination as NavigationDestination).label)
        .toList();
    expect(labels, [
      'الرئيسية',
      'الذكريات',
      'اللعب',
      'المهام',
      'صلة',
      'المكافآت',
      'الملف الشخصي',
    ]);
    expect(
      navigation.labelBehavior,
      NavigationDestinationLabelBehavior.onlyShowSelected,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('nav-sila-destination')));
    await tester.pump(const Duration(milliseconds: 300));

    navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 4);
    expect(find.byType(SilaStudioScreen), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(SilaStudioScreen))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Daily Challenge presents its core experience in Arabic', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpLocalized(
      tester,
      const DailyChallengeScreen(developerPreview: true),
    );

    expect(find.text('التحدي اليومي'), findsOneWidget);
    expect(find.text('تحدي العائلة اليوم'), findsOneWidget);
    expect(find.text('المكافأة اليومية'), findsOneWidget);
    expect(find.text('العب تحدي اليوم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpLocalized(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

Finder _navigationDestination(Finder navigationBar, String label) {
  return find.descendant(
    of: navigationBar,
    matching: find.byWidgetPredicate(
      (widget) => widget is NavigationDestination && widget.label == label,
    ),
  );
}
