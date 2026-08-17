import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/validation/form_validators.dart';
import 'package:kinquest/features/authentication/screens/family_choice_screen.dart';
import 'package:kinquest/features/authentication/screens/login_screen.dart';
import 'package:kinquest/features/authentication/screens/signup_screen.dart';
import 'package:kinquest/features/authentication/screens/welcome_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  test('name validators accept Arabic family and member names', () {
    expect(FormValidators.validateName('أمل محمد'), isNull);
    expect(FormValidators.validateFamilyName('عائلة صلة'), isNull);
  });

  testWidgets('Arabic welcome and login screens render right to left', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpArabic(tester, const WelcomeScreen());

    final description = find.text(
      'مساحة عائلية خاصة للقصص المشتركة والتحديات الممتعة واللحظات التي تبقي الجميع على تواصل.',
    );
    expect(description, findsOneWidget);
    expect(Directionality.of(tester.element(description)), TextDirection.rtl);

    final loginButton = find.widgetWithText(FilledButton, 'تسجيل الدخول');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('مرحبًا بعودتك إلى صلة'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic login and sign-up validation stays local', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));
    await _pumpArabic(tester, const LoginScreen());

    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await tester.pump();

    expect(find.text('البريد الإلكتروني مطلوب.'), findsOneWidget);
    expect(find.text('كلمة المرور مطلوبة.'), findsOneWidget);

    await _pumpArabic(tester, const SignupScreen());

    final createButton = find.widgetWithText(FilledButton, 'إنشاء حساب');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();

    expect(find.text('الاسم الكامل مطلوب.'), findsOneWidget);
    expect(find.text('تاريخ الميلاد مطلوب.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic family setup routes and validates on a narrow screen', (
    tester,
  ) async {
    await _setViewport(tester, const Size(320, 568));
    await _pumpArabic(tester, const FamilyChoiceScreen());

    expect(find.text('تواصل مع عائلتك'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'إنشاء عائلة'));
    await tester.pumpAndSettle();
    expect(find.text('أنشئ مجموعتك العائلية'), findsOneWidget);

    final createButton = find.widgetWithText(FilledButton, 'إنشاء عائلة');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();
    expect(find.text('اسم العائلة مطلوب.'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'الانضمام إلى عائلة'));
    await tester.pumpAndSettle();
    expect(find.text('انضم إلى عائلتك'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'الانضمام إلى عائلة'));
    await tester.pump();
    expect(find.text('رمز الدعوة مطلوب.'), findsOneWidget);
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
