import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../games/screens/trivia_screen.dart';
import '../../games/screens/emoji_guess_screen.dart';
import '../../games/screens/family_quiz_screen.dart';
import '../../games/screens/dont_say_it_screen.dart';
import '../../games/screens/caption_battle_screen.dart';
import '../../games/screens/draw_and_guess_screen.dart';
import '../../games/screens/family_impostor_screen.dart';
import '../../games/screens/pass_the_bomb_screen.dart';
import '../../games/screens/secret_mission_screen.dart';
import '../models/game_play_mode.dart';
import 'competition_games.dart';

typedef OfficialGameBuilder =
    Widget Function(GamePlayMode playMode, Set<String>? participantIds);

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

  Widget build(GamePlayMode playMode, {Set<String>? participantIds}) {
    return builder(playMode, participantIds);
  }

  String localizedName(AppLocalizations strings) => switch (gameId) {
    CompetitionGameIds.familyQuiz => strings.familyQuiz,
    CompetitionGameIds.familyImpostor => strings.familyImpostor,
    CompetitionGameIds.trivia => strings.trivia,
    CompetitionGameIds.emojiGuess => strings.emojiGuess,
    CompetitionGameIds.passTheBomb => strings.passTheBomb,
    CompetitionGameIds.secretMission => strings.secretMission,
    CompetitionGameIds.drawAndGuess => strings.drawAndGuess,
    CompetitionGameIds.captionBattle => strings.captionBattle,
    CompetitionGameIds.dontSayIt => strings.dontSayIt,
    _ => name,
  };

  String localizedDescription(AppLocalizations strings) => switch (gameId) {
    CompetitionGameIds.familyQuiz => strings.familyQuizDescription,
    CompetitionGameIds.familyImpostor => strings.familyImpostorDescription,
    CompetitionGameIds.trivia => strings.triviaDescription,
    CompetitionGameIds.emojiGuess => strings.emojiGuessDescription,
    CompetitionGameIds.passTheBomb => strings.passTheBombDescription,
    CompetitionGameIds.secretMission => strings.secretMissionDescription,
    CompetitionGameIds.drawAndGuess => strings.drawAndGuessDescription,
    CompetitionGameIds.captionBattle => strings.captionBattleDescription,
    CompetitionGameIds.dontSayIt => strings.dontSayItDescription,
    _ => description,
  };
}

class OfficialCompetitionGames {
  const OfficialCompetitionGames._();

  static final List<OfficialCompetitionGame> dailyPool = [
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.familyQuiz,
      name: 'Family Quiz',
      icon: Icons.quiz_rounded,
      description:
          'Answer family-focused questions and compete for the highest score.',
      builder: (playMode, participantIds) =>
          FamilyQuizScreen(playMode: playMode, participantIds: participantIds),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.familyImpostor,
      name: 'Family Impostor',
      icon: Icons.visibility_off_rounded,
      description:
          'Find the impostor, protect the secret word, and outsmart your family.',
      builder: (playMode, participantIds) => FamilyImpostorScreen(
        playMode: playMode,
        participantIds: participantIds,
      ),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.trivia,
      name: 'Trivia',
      icon: Icons.quiz,
      description: 'Compete in teams and answer trivia questions.',
      builder: (playMode, participantIds) =>
          TriviaScreen(playMode: playMode, participantIds: participantIds),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.emojiGuess,
      name: 'Emoji Guess',
      icon: Icons.emoji_emotions_rounded,
      description: 'Decode emoji puzzles with your team and race for the win.',
      builder: (playMode, participantIds) =>
          EmojiGuessScreen(playMode: playMode, participantIds: participantIds),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.passTheBomb,
      name: 'Pass the Bomb',
      icon: Icons.timer_rounded,
      description:
          'Think fast, answer before time runs out, and survive every round.',
      builder: (playMode, participantIds) =>
          PassTheBombScreen(playMode: playMode, participantIds: participantIds),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.secretMission,
      name: 'Secret Mission',
      icon: Icons.assignment_ind_rounded,
      description:
          'Complete private missions without making your family suspicious.',
      builder: (playMode, participantIds) => SecretMissionScreen(
        playMode: playMode,
        participantIds: participantIds,
      ),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.drawAndGuess,
      name: 'Draw & Guess',
      icon: Icons.draw_rounded,
      description:
          'Draw the prompt, help your family guess it, and collect points.',
      builder: (playMode, participantIds) => DrawAndGuessScreen(
        playMode: playMode,
        participantIds: participantIds,
      ),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.captionBattle,
      name: 'Caption Battle',
      icon: Icons.add_reaction_rounded,
      description:
          'Write hilarious captions for family memories and vote for the best.',
      builder: (playMode, participantIds) => CaptionBattleScreen(
        playMode: playMode,
        participantIds: participantIds,
      ),
    ),
    OfficialCompetitionGame(
      gameId: CompetitionGameIds.dontSayIt,
      name: "Don't Say It",
      icon: Icons.record_voice_over_rounded,
      description:
          'Give clues without saying the forbidden words and score with your family.',
      builder: (playMode, participantIds) =>
          DontSayItScreen(playMode: playMode, participantIds: participantIds),
    ),
  ];

  static final List<OfficialCompetitionGame> monthlyPool = dailyPool
      .where(
        (game) =>
            game.gameId == CompetitionGameIds.familyQuiz ||
            game.gameId == CompetitionGameIds.dontSayIt,
      )
      .toList();

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
