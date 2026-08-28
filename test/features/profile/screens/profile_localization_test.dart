import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/profile/screens/edit_profile_screen.dart';
import 'package:kinquest/features/profile/screens/family_management_screen.dart';
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
      find.text('بطل الكأس الشهري'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('بطل الكأس الشهري'), findsOneWidget);
    expect(find.textContaining('لاعب تجريبي'), findsOneWidget);
    expect(find.textContaining('2026-08'), findsOneWidget);
    expect(find.byIcon(Icons.checkroom_rounded), findsOneWidget);

    final appSettings = find.text('إعدادات التطبيق');

    await tester.scrollUntilVisible(appSettings, 300, scrollable: scrollable);

    await Scrollable.ensureVisible(tester.element(appSettings), alignment: 0.5);

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.tap(appSettings);
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('الخصوصية والأمان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic profile editing is localized and read-only in preview', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const EditProfileScreen(developerPreview: true));

    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
    expect(find.text('بياناتك الشخصية'), findsOneWidget);
    expect(find.text('الاسم الكامل'), findsOneWidget);
    expect(find.text('البريد الإلكتروني للحساب'), findsOneWidget);

    final saveButton = find.widgetWithText(FilledButton, 'حفظ الملف الشخصي');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('معاينة المطوّر للقراءة فقط. لم يتم تغيير أي بيانات.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('developer profile opens editing and family management', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const ProfileScreen(developerPreview: true));

    await tester.tap(find.byTooltip('تعديل الملف الشخصي'));
    await tester.pumpAndSettle();
    expect(find.text('بياناتك الشخصية'), findsOneWidget);

    Navigator.of(tester.element(find.text('بياناتك الشخصية'))).pop();
    await tester.pumpAndSettle();

    final manageFamily = find.widgetWithText(FilledButton, 'إدارة العائلة');
    await tester.scrollUntilVisible(
      manageFamily,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(manageFamily),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(manageFamily);
    await tester.pumpAndSettle();

    expect(find.text('دعوة الأقارب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic family management explains roles on a narrow screen', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(
      tester,
      const FamilyManagementScreen(developerPreview: true),
    );

    final title = find.text('إدارة العائلة');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(find.text('دعوة الأقارب'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('أدوار العائلة'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('أدوار العائلة'), findsOneWidget);
    expect(find.text('المالك'), findsWidgets);
    expect(find.text('مسؤول المكافآت'), findsWidgets);

    await tester.scrollUntilVisible(
      find.textContaining('مطوّر صلة'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('(أنت)'), findsOneWidget);
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
