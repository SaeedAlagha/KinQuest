import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/widgets/sila_celebration_card.dart';

void main() {
  testWidgets('celebration card presents the winner and earned rewards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.familyYearTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: SilaCelebrationCard(
              effect: 'fireworks',
              mascotAccessory: SilaMascotAccessories.guardianCrown,
              mascotOutfit: SilaMascotOutfits.gameJersey,
              mascotAura: SilaMascotAuras.victoryBurst,
              eyebrow: 'Daily Challenge complete',
              title: 'Sara takes the family crown',
              subtitle: 'A shared win becomes a family memory.',
              rewards: [
                SilaCelebrationReward(
                  icon: Icons.stars_rounded,
                  label: '+10 Tokens',
                ),
                SilaCelebrationReward(
                  icon: Icons.trending_up_rounded,
                  label: '+10 RP',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('DAILY CHALLENGE COMPLETE'), findsOneWidget);
    expect(find.text('Sara takes the family crown'), findsOneWidget);
    expect(find.text('+10 Tokens'), findsOneWidget);
    expect(find.text('+10 RP'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('celebration-effect-fireworks')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-accessory-guardian_crown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-outfit-game_jersey')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('sila-mascot-aura-victory_burst')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('celebration honors the reduced-motion preference', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SilaCelebrationCard(
              eyebrow: 'Complete',
              title: 'Family win',
              subtitle: 'Together',
            ),
          ),
        ),
      ),
    );

    final mascot = tester.widget<SilaMascot>(find.byType(SilaMascot));
    expect(mascot.animate, isFalse);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
