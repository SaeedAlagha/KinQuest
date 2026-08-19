import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/widgets/game_setup_widgets.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('round selector consistently offers 1, 3, and 5 rounds', (
    tester,
  ) async {
    var selectedRounds = 3;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GameRoundSelector(
                value: selectedRounds,
                onChanged: (rounds) {
                  setState(() {
                    selectedRounds = rounds;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1 round'), findsOneWidget);
    expect(find.text('3 rounds'), findsOneWidget);
    expect(find.text('5 rounds'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('round-option-5')));
    await tester.pump();

    expect(selectedRounds, 5);
  });

  testWidgets('round selector disables options above the available maximum', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GameRoundSelector(value: 1, maximum: 1, onChanged: (_) {}),
        ),
      ),
    );

    final fiveRounds = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('round-option-5')),
    );

    expect(fiveRounds.onSelected, isNull);
  });
}
