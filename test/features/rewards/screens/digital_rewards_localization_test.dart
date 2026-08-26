import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/screens/my_digital_rewards_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('digital collection is fully localized and RTL in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyDigitalRewardsScreen(developerPreview: true),
      ),
    );

    for (var frame = 0; frame < 30; frame += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('مكافآتي الرقمية'), findsOneWidget);
    expect(find.text('إطلالة صلة الخاصة بك'), findsOneWidget);
    expect(find.text('إطارات الملف الشخصي'), findsOneWidget);
    expect(find.text('الإطار الذهبي للملف الشخصي'), findsOneWidget);
    expect(find.text('Golden Profile Frame'), findsNothing);
    expect(
      Directionality.of(tester.element(find.byType(ListView))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
