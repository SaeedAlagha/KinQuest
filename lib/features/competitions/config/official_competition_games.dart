import 'package:flutter/material.dart';

import '../../games/screens/caption_battle_screen.dart';
import '../../games/screens/draw_and_guess_screen.dart';
import '../../games/screens/family_impostor_screen.dart';
import '../../games/screens/pass_the_bomb_screen.dart';
import '../../games/screens/secret_mission_screen.dart';
import '../models/game_play_mode.dart';
import 'competition_games.dart';

typedef OfficialGameBuilder = Widget Function(GamePlayMode playMode);

class OfficialCompetitionGame {
  const OfficialCompetitionGame({
    required this.gameId,
    required this.name,
    required this.icon,
    required this.description,
    required this.builder,
  });

  final String gameId;
  final String name;
  final IconData icon;
  final String description;
  final OfficialGameBuilder builder;

  Widget build(GamePlayMode playMode) {
    return builder(playMode);
  }
}

class OfficialCompetitionGames {
  const OfficialCompetitionGames._();

  static final List<OfficialCompetitionGame> dailyPool = [
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.familyImpostor,
      name: 'Family Impostor',
      icon: Icons.visibility_off_rounded,
      description:
          'Find the impostor, protect the secret word, and outsmart your family.',
      builder: (playMode) => FamilyImpostorScreen(playMode: playMode),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.passTheBomb,
      name: 'Pass the Bomb',
      icon: Icons.timer_rounded,
      description:
          'Think fast, answer before time runs out, and survive every round.',
      builder: (playMode) => PassTheBombScreen(playMode: playMode),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.secretMission,
      name: 'Secret Mission',
      icon: Icons.assignment_ind_rounded,
      description:
          'Complete private missions without making your family suspicious.',
      builder: (playMode) => SecretMissionScreen(playMode: playMode),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.drawAndGuess,
      name: 'Draw & Guess',
      icon: Icons.draw_rounded,
      description:
          'Draw the prompt, help your family guess it, and collect points.',
      builder: (playMode) => DrawAndGuessScreen(playMode: playMode),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.captionBattle,
      name: 'Caption Battle',
      icon: Icons.add_reaction_rounded,
      description:
          'Write hilarious captions for family memories and vote for the best.',
      builder: (playMode) => CaptionBattleScreen(playMode: playMode),
    ),
  ];

  static OfficialCompetitionGame dailyGameFor(DateTime date) {
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    final dayNumber =
        normalizedDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

    final index = dayNumber % dailyPool.length;

    return dailyPool[index];
  }

  static OfficialCompetitionGame? byId(String gameId) {
    for (final game in dailyPool) {
      if (game.gameId == gameId) {
        return game;
      }
    }

    return null;
  }
}
