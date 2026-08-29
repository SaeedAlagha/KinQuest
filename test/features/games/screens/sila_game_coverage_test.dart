import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/attack_or_defend_screen.dart';
import 'package:kinquest/features/games/screens/caption_battle_screen.dart';
import 'package:kinquest/features/games/screens/charades_screen.dart';
import 'package:kinquest/features/games/screens/code_breaker_screen.dart';
import 'package:kinquest/features/games/screens/dont_say_it_screen.dart';
import 'package:kinquest/features/games/screens/draw_and_guess_screen.dart';
import 'package:kinquest/features/games/screens/emoji_guess_screen.dart';
import 'package:kinquest/features/games/screens/family_impostor_screen.dart';
import 'package:kinquest/features/games/screens/family_quiz_screen.dart';
import 'package:kinquest/features/games/screens/games_screen.dart';
import 'package:kinquest/features/games/screens/memory_challenge_screen.dart';
import 'package:kinquest/features/games/screens/never_have_i_ever_screen.dart';
import 'package:kinquest/features/games/screens/pass_the_bomb_screen.dart';
import 'package:kinquest/features/games/screens/risk_it_screen.dart';
import 'package:kinquest/features/games/screens/secret_mission_screen.dart';
import 'package:kinquest/features/games/screens/trivia_screen.dart';
import 'package:kinquest/features/games/screens/truth_or_dare_screen.dart';
import 'package:kinquest/features/games/screens/would_you_rather_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  final gameSetups = <String, Widget>{
    'Attack or Defend': const AttackOrDefendScreen(developerPreview: true),
    'Caption Battle': const CaptionBattleScreen(developerPreview: true),
    'Charades': const CharadesScreen(),
    'Code Breaker': const CodeBreakerScreen(developerPreview: true),
    "Don't Say It": const DontSayItScreen(developerPreview: true),
    'Draw & Guess': const DrawAndGuessScreen(developerPreview: true),
    'Emoji Guess': const EmojiGuessScreen(developerPreview: true),
    'Family Impostor': const FamilyImpostorScreen(developerPreview: true),
    'Family Quiz': const FamilyQuizScreen(developerPreview: true),
    'Memory Challenge': const MemoryChallengeScreen(),
    'Never Have I Ever': const NeverHaveIEverScreen(),
    'Pass the Bomb': const PassTheBombScreen(developerPreview: true),
    'Risk It': const RiskItScreen(developerPreview: true),
    'Secret Mission': const SecretMissionScreen(developerPreview: true),
    'Trivia': const TriviaScreen(developerPreview: true),
    'Truth or Dare': const TruthOrDareScreen(),
    'Would You Rather': const WouldYouRatherScreen(),
  };

  for (final entry in gameSetups.entries) {
    testWidgets('${entry.key} setup shows inline Sila without an overlay', (
      tester,
    ) async {
      await _setViewport(tester, const Size(390, 844));
      await tester.pumpWidget(_app(entry.value));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('sila-game-coach-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('sila-game-coach-button')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('both game catalogues introduce Sila without overflow', (
    tester,
  ) async {
    await _setViewport(tester, const Size(390, 844));

    for (final catalogue in const [
      GamesScreen(developerPreview: true),
      PartyGamesScreen(),
    ]) {
      await tester.pumpWidget(_app(catalogue));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('sila-game-coach-banner')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
