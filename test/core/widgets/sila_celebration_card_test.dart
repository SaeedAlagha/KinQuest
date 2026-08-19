import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
