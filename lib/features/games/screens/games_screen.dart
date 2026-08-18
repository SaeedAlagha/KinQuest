import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../l10n/app_localizations.dart';
import 'caption_battle_screen.dart';
import 'charades_screen.dart';
import 'dont_say_it_screen.dart';
import 'draw_and_guess_screen.dart';
import 'emoji_guess_screen.dart';
import 'family_impostor_screen.dart';
import 'family_quiz_screen.dart';
import 'never_have_i_ever_screen.dart';
import 'pass_the_bomb_screen.dart';
import 'secret_mission_screen.dart';
import 'trivia_screen.dart';
import 'truth_or_dare_screen.dart';
import 'would_you_rather_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({
    super.key,
    this.developerPreview = false,
    this.participantIds,
  });

  final bool developerPreview;
  final Set<String>? participantIds;
  static const List<_GameItem> _games = [
    _GameItem(
      icon: Icons.favorite_rounded,
      accent: AppTheme.coralColor,
      title: 'Family Quiz',
      description:
          'Share real answers and discover how well your family knows one another.',
      eyebrow: 'CONNECTED PLAY',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.quiz_rounded,
      accent: AppTheme.tealColor,
      title: 'Trivia',
      description:
          'Team up, choose a category, and race through family-friendly questions.',
      eyebrow: 'KNOWLEDGE',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.emoji_emotions_rounded,
      accent: Color(0xFF4B91F1),
      title: 'Emoji Guess',
      description:
          'Decode playful emoji puzzles with your team before time runs out.',
      eyebrow: 'GUESSING GAME',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.celebration_rounded,
      accent: Color(0xFFE35EAB),
      title: 'Party Games',
      description: 'Quick family games for laughs and fun.',
      eyebrow: '4 GAMES INSIDE',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.person_search_rounded,
      accent: AppTheme.coralColor,
      title: 'Family Impostor',
      description:
          'Find the hidden impostor through clues, discussion, and family voting.',
      eyebrow: 'SOCIAL DEDUCTION',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.visibility_off_rounded,
      accent: AppTheme.tealColor,
      title: 'Secret Mission',
      description:
          'Complete a hidden mission without your family figuring out what you are doing.',
      eyebrow: 'SECRET CHALLENGE',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.add_comment_rounded,
      accent: AppTheme.goldColor,
      title: 'Caption Battle',
      description:
          'Caption real family photos, vote anonymously, and crown the funniest family member.',
      eyebrow: 'PHOTO PARTY',
      isAvailable: true,
      isSignatureFeature: true,
    ),
    _GameItem(
      icon: Icons.timer_rounded,
      accent: AppTheme.goldColor,
      title: 'Pass the Bomb',
      description:
          'Answer quickly, pass the phone, and avoid being caught when the hidden timer explodes.',
      eyebrow: 'FAST FAMILY FUN',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.draw_outlined,
      accent: AppTheme.coralColor,
      title: 'Draw & Guess',
      description: 'Draw AI-generated prompts while your family guesses aloud.',
      eyebrow: 'CREATIVE PLAY',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.record_voice_over_outlined,
      accent: AppTheme.coralColor,
      title: 'Don\'t Say It',
      description:
          'Describe the secret word without saying any of the forbidden words.',
      eyebrow: 'WORD CHALLENGE',
      isAvailable: true,
    ),
  ];

  void _openGame(BuildContext context, _GameItem game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => switch (game.title) {
          'Family Quiz' => FamilyQuizScreen(
            developerPreview: developerPreview,
            participantIds: participantIds,
          ),
          'Family Impostor' => FamilyImpostorScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Secret Mission' => SecretMissionScreen(
            participantIds: participantIds,
          ),
          'Caption Battle' => CaptionBattleScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Pass the Bomb' => PassTheBombScreen(participantIds: participantIds),
          'Draw & Guess' => DrawAndGuessScreen(participantIds: participantIds),
          'Don\'t Say It' => DontSayItScreen(participantIds: participantIds),
          'Trivia' => TriviaScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Emoji Guess' => EmojiGuessScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Party Games' => const PartyGamesScreen(),
          _ => GamePlaceholderScreen(gameTitle: game.title),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: Navigator.of(context).canPop()
          ? AppBar(title: Text(strings.games))
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pagePadding = constraints.maxWidth < 480 ? 20.0 : 32.0;
            final columns = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 650
                ? 2
                : 1;
            final cardHeight = columns == 1 ? 266.0 : 298.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pagePadding, 28, pagePadding, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GamesHeader(),
                      const SizedBox(height: 28),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _games.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: cardHeight,
                        ),
                        itemBuilder: (context, index) {
                          final game = _games[index];
                          return _GameCard(
                            game: game,
                            onOpen: () => _openGame(context, game),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GamesHeader extends StatelessWidget {
  const _GamesHeader();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UaeColorRibbon(height: 5),
          const SizedBox(height: 22),
          Wrap(
            spacing: 28,
            runSpacing: 22,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.gamesEyebrow,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.gamesHeading,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.gamesDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onOpen});

  final _GameItem game;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final borderColor = game.isSignatureFeature
        ? AppTheme.primaryColor.withValues(alpha: 0.5)
        : AppTheme.outlineColor;

    return Material(
      color: game.isSignatureFeature
          ? AppTheme.primaryColor.withValues(alpha: 0.045)
          : AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: borderColor,
          width: game.isSignatureFeature ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: game.accent.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(game.icon, color: game.accent, size: 28),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: game.isAvailable
                          ? AppTheme.tealColor.withValues(alpha: 0.12)
                          : AppTheme.textColor.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _localizedGameEyebrow(strings, game.title, game.eyebrow),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: game.isAvailable
                            ? const Color(0xFF167A70)
                            : AppTheme.secondaryTextColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _localizedGameTitle(strings, game.title),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _localizedGameDescription(
                  strings,
                  game.title,
                  game.description,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    game.isAvailable ? strings.openGame : strings.preview,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartyGamesScreen extends StatelessWidget {
  const PartyGamesScreen({super.key});

  static const List<_PartyGameItem> _games = [
    _PartyGameItem(
      icon: Icons.compare_arrows_rounded,
      accent: AppTheme.coralColor,
      title: 'Would You Rather',
      description: 'Choose between two playful options.',
    ),
    _PartyGameItem(
      icon: Icons.theater_comedy_rounded,
      accent: AppTheme.tealColor,
      title: 'Charades',
      description: 'Act out creative prompts for the whole family.',
    ),

    _PartyGameItem(
      icon: Icons.sentiment_satisfied_alt_rounded,
      accent: Color(0xFF4B91F1),
      title: 'Never Have I Ever',
      description: 'Share family-friendly moments and surprises.',
    ),
    _PartyGameItem(
      icon: Icons.casino_rounded,
      accent: Color(0xFFE35EAB),
      title: 'Truth or Dare',
      description: 'Pick a friendly truth or a fun challenge.',
    ),
  ];

  void _openGame(BuildContext context, String title) {
    final screen = switch (title) {
      'Would You Rather' => const WouldYouRatherScreen(),
      'Charades' => const CharadesScreen(),
      'Never Have I Ever' => const NeverHaveIEverScreen(),
      'Truth or Dare' => const TruthOrDareScreen(),
      _ => GamePlaceholderScreen(gameTitle: title),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.partyGames)),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            final pagePadding = constraints.maxWidth < 480 ? 20.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pagePadding, 12, pagePadding, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.partyGamesHeading,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.partyGamesSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _games.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 150,
                        ),
                        itemBuilder: (context, index) {
                          final game = _games[index];
                          return _PartyGameCard(
                            game: game,
                            onTap: () => _openGame(context, game.title),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PartyGameCard extends StatelessWidget {
  const _PartyGameCard({required this.game, required this.onTap});

  final _PartyGameItem game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Material(
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppTheme.outlineColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: game.accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(game.icon, color: game.accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedPartyGameTitle(strings, game.title),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _localizedPartyGameDescription(
                        strings,
                        game.title,
                        game.description,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePlaceholderScreen extends StatelessWidget {
  const GamePlaceholderScreen({required this.gameTitle, super.key});

  final String gameTitle;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final localizedTitle = _localizedAnyGameTitle(strings, gameTitle);

    return Scaffold(
      appBar: AppBar(title: Text(localizedTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.outlineColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      size: 42,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.gameFutureUpdate,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameItem {
  const _GameItem({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.eyebrow,
    this.isAvailable = false,
    this.isSignatureFeature = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final String eyebrow;
  final bool isAvailable;
  final bool isSignatureFeature;
}

class _PartyGameItem {
  const _PartyGameItem({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
}

String _localizedGameTitle(AppLocalizations strings, String title) =>
    switch (title) {
      'Family Quiz' => strings.familyQuiz,
      'Trivia' => strings.trivia,
      'Emoji Guess' => strings.emojiGuess,
      'Party Games' => strings.partyGames,
      'Family Impostor' => strings.familyImpostor,
      'Secret Mission' => strings.secretMission,
      'Caption Battle' => strings.captionBattle,
      'Pass the Bomb' => strings.passTheBomb,
      'Draw & Guess' => strings.drawAndGuess,
      'Don\'t Say It' => strings.dontSayIt,
      _ => title,
    };

String _localizedGameDescription(
  AppLocalizations strings,
  String title,
  String fallback,
) => switch (title) {
  'Family Quiz' => strings.familyQuizDescription,
  'Trivia' => strings.triviaDescription,
  'Emoji Guess' => strings.emojiGuessDescription,
  'Party Games' => strings.partyGamesDescription,
  'Family Impostor' => strings.familyImpostorDescription,
  'Secret Mission' => strings.secretMissionDescription,
  'Caption Battle' => strings.captionBattleDescription,
  'Pass the Bomb' => strings.passTheBombDescription,
  'Draw & Guess' => strings.drawAndGuessDescription,
  'Don\'t Say It' => strings.dontSayItDescription,
  _ => fallback,
};

String _localizedGameEyebrow(
  AppLocalizations strings,
  String title,
  String fallback,
) => switch (title) {
  'Family Quiz' => strings.connectedPlay,
  'Trivia' => strings.knowledge,
  'Emoji Guess' => strings.guessingGame,
  'Party Games' => strings.fourGamesInside,
  'Family Impostor' => strings.socialDeduction,
  'Secret Mission' => strings.secretChallenge,
  'Caption Battle' => strings.photoParty,
  'Pass the Bomb' => strings.fastFamilyFun,
  'Draw & Guess' => strings.creativePlay,
  'Don\'t Say It' => strings.wordChallenge,
  _ => fallback,
};

String _localizedPartyGameTitle(AppLocalizations strings, String title) =>
    switch (title) {
      'Would You Rather' => strings.wouldYouRather,
      'Charades' => strings.charades,
      'Never Have I Ever' => strings.neverHaveIEver,
      'Truth or Dare' => strings.truthOrDare,
      _ => title,
    };

String _localizedPartyGameDescription(
  AppLocalizations strings,
  String title,
  String fallback,
) => switch (title) {
  'Would You Rather' => strings.wouldYouRatherDescription,
  'Charades' => strings.charadesDescription,
  'Never Have I Ever' => strings.neverHaveIEverDescription,
  'Truth or Dare' => strings.truthOrDareDescription,
  _ => fallback,
};

String _localizedAnyGameTitle(AppLocalizations strings, String title) {
  final gameTitle = _localizedGameTitle(strings, title);
  return gameTitle == title
      ? _localizedPartyGameTitle(strings, title)
      : gameTitle;
}
