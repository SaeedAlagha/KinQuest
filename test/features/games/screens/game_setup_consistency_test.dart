import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/charades_screen.dart';
import 'package:kinquest/features/games/screens/never_have_i_ever_screen.dart';
import 'package:kinquest/features/games/screens/truth_or_dare_screen.dart';
import 'package:kinquest/features/games/screens/would_you_rather_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  final games = <String, Widget>{
    'Would You Rather': const WouldYouRatherScreen(),
    'Charades': const CharadesScreen(),
    'Never Have I Ever': const NeverHaveIEverScreen(),
    'Truth or Dare': const TruthOrDareScreen(),
  };

  for (final game in games.entries) {
    testWidgets('${game.key} uses the shared 1, 3, 5-round setup', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: game.value,
        ),
      );
      await tester.pump();

      expect(find.text('1 round'), findsOneWidget);
      expect(find.text('3 rounds'), findsOneWidget);
      expect(find.text('5 rounds'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
