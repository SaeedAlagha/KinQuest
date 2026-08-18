import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/profile/screens/settings_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppearanceController.instance.load();
  });

  testWidgets('Settings switches between Dark and UAE Family Year themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const _AppearanceTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Sila Light'), findsOneWidget);

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('UAE Family Year 2026'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(AppearanceController.instance.appearance, AppAppearance.dark);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UAE Family Year 2026'));
    await tester.pumpAndSettle();

    final theme = Theme.of(tester.element(find.byType(SettingsScreen)));
    expect(
      AppearanceController.instance.appearance,
      AppAppearance.familyYear2026,
    );
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<SilaThemeTokens>()?.isFamilyYear, isTrue);
    expect(find.text('UAE Family Year 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic Settings localizes all appearance choices', (
    tester,
  ) async {
    await tester.pumpWidget(const _AppearanceTestApp(locale: Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('التفضيلات'), findsOneWidget);
    expect(find.text('المظهر'), findsOneWidget);

    await tester.tap(find.text('المظهر'));
    await tester.pumpAndSettle();

    expect(find.text('الوضع الداكن'), findsOneWidget);
    expect(find.text('عام الأسرة الإماراتي 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _AppearanceTestApp extends StatelessWidget {
  const _AppearanceTestApp({this.locale = const Locale('en')});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppearanceController.instance,
      builder: (context, child) {
        return MaterialApp(
          theme: AppTheme.forAppearance(
            AppearanceController.instance.appearance,
          ),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SettingsScreen(),
        );
      },
    );
  }
}
