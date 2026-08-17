import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/memories/screens/add_memory_screen.dart';
import 'package:kinquest/features/memories/screens/edit_memory_screen.dart';
import 'package:kinquest/features/memories/screens/memories_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Arabic developer memories render right to left when narrow', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const MemoriesScreen(developerPreview: true));

    final heading = find.text('ذكريات عائلة المطوّر');
    expect(heading, findsOneWidget);
    expect(Directionality.of(tester.element(heading)), TextDirection.rtl);
    expect(find.text('نزهة عائلية في حديقة مشرف'), findsOneWidget);

    await tester.tap(find.text('نزهة عائلية في حديقة مشرف'));
    await tester.pump();

    expect(
      find.text('معاينة المطوّر للقراءة فقط. لم يتم تغيير أي بيانات.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic add-memory form localizes required validation', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const AddMemoryScreen());

    expect(find.text('التقط لحظة عائلية'), findsOneWidget);

    final saveButton = find.widgetWithText(FilledButton, 'حفظ الذكرى');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('عنوان الذكرى مطلوب.'), findsOneWidget);
    expect(find.text('تاريخ الذكرى مطلوب.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic edit-memory form keeps invalid saves local', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(
      tester,
      const EditMemoryScreen(
        memoryId: 'preview-memory',
        familyId: 'preview-family',
        memoryData: <String, dynamic>{},
      ),
    );

    expect(find.text('تعديل الذكرى'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('اختر التاريخ'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('اختر التاريخ'), findsOneWidget);

    final saveButton = find.widgetWithText(FilledButton, 'حفظ التغييرات');
    await tester.scrollUntilVisible(
      saveButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('أدخل عنوانًا للذكرى.'), findsOneWidget);
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
