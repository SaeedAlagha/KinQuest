import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/features/mascot/widgets/sila_companion_callout.dart';
import 'package:kinquest/features/rewards/digital/equipped_digital_rewards.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('shows the equipped Sila style in a semantic callout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const SilaCompanionCallout(
          title: 'Sila is here',
          message: 'Let us take the next step together.',
          animate: false,
          previewRewards: EquippedDigitalRewards(
            mascotAccessory: SilaMascotAccessories.guardianCrown,
            mascotOutfit: SilaMascotOutfits.familyCape,
            mascotAura: SilaMascotAuras.familySparkles,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('sila-companion-callout')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-accessory-guardian_crown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-outfit-family_cape')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-aura-family_sparkles')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Sila is here. Let us take the next step together.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('stacks safely for Arabic, large text and reduced motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(
        SilaCompanionCallout(
          title: 'سيلا معك',
          message: 'سأساعد عائلتك في اختيار الخطوة التالية بسهولة.',
          action: FilledButton(onPressed: () {}, child: const Text('متابعة')),
        ),
        locale: const Locale('ar'),
        mediaQueryData: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final column = tester.widget<Column>(
      find
          .descendant(
            of: find.byKey(const ValueKey('sila-companion-callout')),
            matching: find.byType(Column),
          )
          .first,
    );
    expect(column.mainAxisSize, MainAxisSize.min);
    expect(
      Directionality.of(tester.element(find.text('سيلا معك'))),
      TextDirection.rtl,
    );
    expect(find.bySemanticsLabel('متابعة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(
  Widget child, {
  Locale locale = const Locale('en'),
  MediaQueryData? mediaQueryData,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: MediaQuery(
        data: mediaQueryData ?? const MediaQueryData(size: Size(800, 600)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: child,
          ),
        ),
      ),
    ),
  );
}
