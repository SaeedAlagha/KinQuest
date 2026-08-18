import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/profile/screens/profile_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Arabic developer profile stays usable on a narrow screen', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const ProfileScreen(developerPreview: true));

    final profileTitle = find.text('الملف الشخصي');
    expect(profileTitle, findsOneWidget);
    expect(Directionality.of(tester.element(profileTitle)), TextDirection.rtl);
    expect(find.text('مطوّر صلة'), findsOneWidget);
    expect(find.text('عائلة المطوّر'), findsWidgets);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('السلسلة الحالية'),
      220,
      scrollable: scrollable,
    );
    expect(find.textContaining('أيام'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('حافظ الذكريات'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('خبير الاختبارات'), findsOneWidget);
    expect(find.text('روح الفريق'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('لا توجد أمنيات عائلية بعد'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('لا توجد أمنيات عائلية بعد'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Monthly Cup Champion'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('Monthly Cup Champion'), findsOneWidget);
    expect(find.textContaining('2026-08'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('إعدادات التطبيق'),
      400,
      scrollable: scrollable,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('إعدادات التطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('الخصوصية والأمان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpArabic(WidgetTester tester, Widget home) async {
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
