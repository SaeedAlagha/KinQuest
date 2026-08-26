import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/widgets/family_year_banner.dart';
import 'package:kinquest/core/widgets/sila_brand_mark.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_visuals.dart';
import 'package:kinquest/features/rewards/digital/equipped_digital_rewards.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('brand and reward visuals expose Arabic semantic labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SilaBrandMark(size: 72),
                FamilyYearBanner(compact: true),
                DigitalRewardAvatar(
                  rewards: EquippedDigitalRewards(profileFrame: 'gold'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('شعار صلة للترابط العائلي'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('عام الأسرة في الإمارات 2026، نماء وانتماء'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('تم تجهيز إطار الملف الشخصي')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
