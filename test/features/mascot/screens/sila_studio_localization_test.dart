import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/mascot/screens/sila_studio_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('Sila Studio is localized and responsive in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const TickerMode(
          enabled: false,
          child: SilaStudioScreen(developerPreview: true),
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text('استوديو صلة'), findsOneWidget);
    expect(find.text('أغطية الرأس'), findsOneWidget);
    expect(find.text('تاج حارس العائلة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('استوديو صلة'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
