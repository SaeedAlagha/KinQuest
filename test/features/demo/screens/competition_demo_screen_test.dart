import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/demo/screens/competition_demo_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('judge demo completes the full family impact loop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const CompetitionDemoScreen()));

    expect(find.text('Share a phone-free family meal'), findsOneWidget);
    expect(find.text('480'), findsOneWidget);

    final verifyButton = find.byKey(const ValueKey('verify-demo-mission'));
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pump(const Duration(milliseconds: 701));
    await tester.pumpAndSettle();

    expect(find.text('Family Quiz Challenge'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);

    final saraAnswer = find.byKey(const ValueKey('demo-answer-Sara'));
    await tester.ensureVisible(saraAnswer);
    await tester.tap(saraAnswer);
    await tester.pump();
    final finishButton = find.byKey(const ValueKey('finish-demo-round'));
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pumpAndSettle();

    expect(find.text('Sara is the Family Champion!'), findsOneWidget);
    expect(find.text('550'), findsOneWidget);

    final rewardButton = find.text('Choose a family reward');
    await tester.ensureVisible(rewardButton);
    await tester.tap(rewardButton);
    await tester.pumpAndSettle();

    expect(find.text('Turn progress into a reward'), findsOneWidget);
    final redeemButton = find.byKey(const ValueKey('redeem-demo-reward'));
    await tester.ensureVisible(redeemButton);
    await tester.tap(redeemButton);
    await tester.pumpAndSettle();

    expect(find.text('Approved: Sara chooses Friday dinner.'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);

    await tester.tap(redeemButton);
    await tester.pumpAndSettle();
    expect(find.text('Turn the moment into a memory'), findsOneWidget);

    final saveButton = find.byKey(const ValueKey('save-demo-memory'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('One complete family loop. Real impact.'), findsOneWidget);
    expect(find.text('Mission completed'), findsOneWidget);
    expect(find.text('Champion crowned'), findsOneWidget);
    expect(find.text('Reward redeemed'), findsOneWidget);
    expect(find.text('Memory saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('judge demo renders its Arabic journey', (tester) async {
    await tester.pumpWidget(
      _testApp(const CompetitionDemoScreen(), locale: const Locale('ar')),
    );

    expect(find.text('العرض التنافسي'), findsWidgets);
    expect(find.text('تناولوا وجبة بلا هواتف'), findsOneWidget);
    expect(find.text('تحقق واربح 20 رمزًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home, {Locale? locale}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}
