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
import 'code_breaker_screen.dart';
import 'attack_or_defend_screen.dart';
import 'risk_it_screen.dart';
import '../widgets/sila_game_coach.dart';

enum _GameCategory { family, party, duel }

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
      icon: Icons.lock_open_rounded,
      accent: AppTheme.tealColor,
      title: 'Code Breaker',
      description:
          'Crack hidden codes using logic. Fewer attempts and faster solves earn more points.',
      eyebrow: 'LOGIC DUEL',
      category: _GameCategory.duel,
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.sports_martial_arts_rounded,
      accent: AppTheme.coralColor,
      title: 'Attack or Defend',
      description:
          'Build energy, attack your rival, defend your hearts, and survive the battle.',
      eyebrow: 'BATTLE DUEL',
      category: _GameCategory.duel,
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.casino_rounded,
      accent: AppTheme.goldColor,
      title: 'Risk It',
      description:
          'Build a points pot, bank it safely, or risk everything for a massive score.',
      eyebrow: 'HIGH-STAKES DUEL',
      category: _GameCategory.duel,
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.favorite_rounded,
      accent: AppTheme.coralColor,
      title: 'Family Quiz',
      description:
          'Share real answers and discover how well your family knows one another.',
      eyebrow: 'CONNECTED PLAY',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.quiz_rounded,
      accent: AppTheme.tealColor,
      title: 'Trivia',
      description:
          'Team up, choose a category, and race through family-friendly questions.',
      eyebrow: 'KNOWLEDGE',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.emoji_emotions_rounded,
      accent: Color(0xFF4B91F1),
      title: 'Emoji Guess',
      description:
          'Decode playful emoji puzzles with your team before time runs out.',
      eyebrow: 'GUESSING GAME',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.person_search_rounded,
      accent: AppTheme.coralColor,
      title: 'Family Impostor',
      description:
          'Find the hidden impostor through clues, discussion, and family voting.',
      eyebrow: 'SOCIAL DEDUCTION',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.visibility_off_rounded,
      accent: AppTheme.tealColor,
      title: 'Secret Mission',
      description:
          'Complete a hidden mission without your family figuring out what you are doing.',
      eyebrow: 'SECRET CHALLENGE',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.add_comment_rounded,
      accent: AppTheme.goldColor,
      title: 'Caption Battle',
      description:
          'Caption real family photos, vote anonymously, and crown the best caption.',
      eyebrow: 'PHOTO PARTY',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.timer_rounded,
      accent: AppTheme.goldColor,
      title: 'Pass the Bomb',
      description:
          'Answer quickly, pass the phone, and avoid being caught when the hidden timer explodes.',
      eyebrow: 'FAST FAMILY FUN',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.draw_outlined,
      accent: AppTheme.coralColor,
      title: 'Draw & Guess',
      description: 'Draw prompts while your family guesses aloud.',
      eyebrow: 'CREATIVE PLAY',
      isAvailable: true,
      category: _GameCategory.family,
    ),
    _GameItem(
      icon: Icons.record_voice_over_outlined,
      accent: AppTheme.coralColor,
      title: 'Don\'t Say It',
      description:
          'Describe the secret word without saying any of the forbidden words.',
      eyebrow: 'WORD CHALLENGE',
      isAvailable: true,
      category: _GameCategory.family,
    ),

    _GameItem(
      icon: Icons.compare_arrows_rounded,
      accent: AppTheme.coralColor,
      title: 'Would You Rather',
      description: 'Choose between two playful options.',
      eyebrow: 'CHOICE GAME',
      category: _GameCategory.party,
      isAvailable: true,
    ),

    _GameItem(
      icon: Icons.theater_comedy_rounded,
      accent: AppTheme.tealColor,
      title: 'Charades',
      description: 'Act out creative prompts for the whole family.',
      eyebrow: 'ACT IT OUT',
      category: _GameCategory.party,
      isAvailable: true,
    ),

    _GameItem(
      icon: Icons.sentiment_satisfied_alt_rounded,
      accent: Color(0xFF4B91F1),
      title: 'Never Have I Ever',
      description: 'Share family-friendly moments and surprises.',
      eyebrow: 'PARTY TALK',
      category: _GameCategory.party,
      isAvailable: true,
    ),

    _GameItem(
      icon: Icons.casino_rounded,
      accent: Color(0xFFE35EAB),
      title: 'Truth or Dare',
      description: 'Pick a friendly truth or a fun challenge.',
      eyebrow: 'PARTY CHALLENGE',
      category: _GameCategory.party,
      isAvailable: true,
    ),
  ];
  List<_GameItem> _gamesFor(_GameCategory category) {
    return _games.where((game) => game.category == category).toList();
  }

  void _openGame(BuildContext context, _GameItem game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => switch (game.title) {
          'Risk It' => RiskItScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Code Breaker' => CodeBreakerScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Attack or Defend' => AttackOrDefendScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
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
            developerPreview: developerPreview,
          ),
          'Caption Battle' => CaptionBattleScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Pass the Bomb' => PassTheBombScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Draw & Guess' => DrawAndGuessScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Don\'t Say It' => DontSayItScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Trivia' => TriviaScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Emoji Guess' => EmojiGuessScreen(
            participantIds: participantIds,
            developerPreview: developerPreview,
          ),
          'Would You Rather' => const WouldYouRatherScreen(),
          'Charades' => const CharadesScreen(),
          'Never Have I Ever' => const NeverHaveIEverScreen(),
          'Truth or Dare' => const TruthOrDareScreen(),
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
            final cardHeight = columns == 1 ? 250.0 : 270.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pagePadding, 28, pagePadding, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GamesHeader(),
                      const SizedBox(height: 18),
                      const SilaGameCoachBanner(),
                      const SizedBox(height: 28),
                      _GameSection(
                        icon: Icons.sports_kabaddi_rounded,
                        title: strings.duelGames,
                        subtitle: strings.duelGamesSubtitle,
                        games: _gamesFor(_GameCategory.duel),
                        columns: columns,
                        cardHeight: cardHeight,
                        onOpen: (game) => _openGame(context, game),
                      ),

                      const SizedBox(height: 38),
                      _GameSection(
                        icon: Icons.groups_2_rounded,
                        title: strings.familyGames,
                        subtitle: strings.familyGamesSubtitle,
                        games: _gamesFor(_GameCategory.family),
                        columns: columns,
                        cardHeight: cardHeight,
                        onOpen: (game) => _openGame(context, game),
                      ),

                      const SizedBox(height: 38),

                      _GameSection(
                        icon: Icons.celebration_rounded,
                        title: strings.partyGames,
                        subtitle: strings.partyGamesSectionSubtitle,
                        games: _gamesFor(_GameCategory.party),
                        columns: columns,
                        cardHeight: cardHeight,
                        onOpen: (game) => _openGame(context, game),
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

class _GameSection extends StatelessWidget {
  const _GameSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.games,
    required this.columns,
    required this.cardHeight,
    required this.onOpen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_GameItem> games;
  final int columns;
  final double cardHeight;
  final ValueChanged<_GameItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: games.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            final game = games[index];

            return _GameCard(game: game, onOpen: () => onOpen(game));
          },
        ),
      ],
    );
  }
}

class _GamesHeader extends StatelessWidget {
  const _GamesHeader();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
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
                  gradient: AppTheme.heroGradientFor(context),
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
                        color: colorScheme.primary,
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
                        color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.outlineVariant;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                          : colorScheme.onSurface.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _localizedGameEyebrow(strings, game.title, game.eyebrow),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: game.isAvailable
                            ? const Color(0xFF167A70)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                _localizedGameTitle(strings, game.title),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
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
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const SilaGameCoachBanner(),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _games.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: columns == 1 ? 170 : 150,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outlineVariant),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: colorScheme.outlineVariant),
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
                      color: colorScheme.onSurfaceVariant,
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
    required this.category,
    this.isAvailable = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final String eyebrow;
  final _GameCategory category;
  final bool isAvailable;
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
      'Code Breaker' => strings.codeBreakerTitle,
      'Attack or Defend' => strings.attackOrDefendTitle,
      'Risk It' => strings.riskItTitle,
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
  'Code Breaker' => strings.codeBreakerDescription,
  'Attack or Defend' => strings.attackOrDefendDescription,
  'Risk It' => strings.riskItDescription,
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
  'Code Breaker' => strings.logicDuel,
  'Attack or Defend' => strings.battleDuel,
  'Risk It' => strings.highStakesDuel,
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
