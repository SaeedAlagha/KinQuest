import 'package:flutter/material.dart';
import 'family_missions_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import 'charades_screen.dart';
import 'emoji_guess_screen.dart';
import 'family_quiz_screen.dart';
import 'never_have_i_ever_screen.dart';
import 'trivia_screen.dart';
import 'truth_or_dare_screen.dart';
import 'would_you_rather_screen.dart';
import 'memory_challenge_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

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
      icon: Icons.compare_arrows_rounded,
      accent: AppTheme.tealColor,
      title: 'Match My Answer',
      description: 'Try to match another family member\'s private answer.',
      eyebrow: 'COMING SOON',
    ),
    _GameItem(
      icon: Icons.photo_library_rounded,
      accent: AppTheme.primaryColor,
      title: 'Memory Challenge',
      description:
          'Play AI-generated challenges inspired by your family memories.',
      eyebrow: 'SILA SIGNATURE',
      isAvailable: true,
      isSignatureFeature: true,
    ),
    _GameItem(
      icon: Icons.psychology_rounded,
      accent: AppTheme.goldColor,
      title: 'AI Knowledge Challenge',
      description:
          'Explore science, geography, history, sports, and more together.',
      eyebrow: 'COMING SOON',
    ),
    _GameItem(
      icon: Icons.groups_rounded,
      accent: Color(0xFF4B91F1),
      title: 'Family Missions',
      description:
          'Complete real-life activities together and earn family rewards.',
      eyebrow: 'DAILY MISSIONS',
      isAvailable: true,
    ),
    _GameItem(
      icon: Icons.celebration_rounded,
      accent: Color(0xFFE35EAB),
      title: 'Party Games',
      description:
          'Jump into Trivia, Charades, Emoji Guess, and more quick games.',
      eyebrow: '6 GAMES INSIDE',
      isAvailable: true,
    ),
  ];

  void _openGame(BuildContext context, _GameItem game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => switch (game.title) {
          'Family Quiz' => FamilyQuizScreen(developerPreview: developerPreview),
          'Memory Challenge' => const MemoryChallengeScreen(),
          'Family Missions' => const FamilyMissionsScreen(),
          'Party Games' => const PartyGamesScreen(),
          _ => GamePlaceholderScreen(gameTitle: game.title),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'FAMILY YEAR • BONDS THROUGH PLAY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Find your next family favorite',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share a quick laugh, a thoughtful question, or a challenge that brings every generation closer.',
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
                      game.eyebrow,
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
              Text(game.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                game.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    game.isAvailable ? 'Open game' : 'Preview',
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
      icon: Icons.quiz_rounded,
      accent: AppTheme.primaryColor,
      title: 'Trivia',
      description: 'Answer AI-generated questions and test your knowledge.',
    ),
    _PartyGameItem(
      icon: Icons.compare_arrows_rounded,
      accent: AppTheme.coralColor,
      title: 'Would You Rather',
      description: 'Choose between two playful AI-generated options.',
    ),
    _PartyGameItem(
      icon: Icons.theater_comedy_rounded,
      accent: AppTheme.tealColor,
      title: 'Charades',
      description: 'Act out creative prompts for the whole family.',
    ),
    _PartyGameItem(
      icon: Icons.emoji_emotions_rounded,
      accent: AppTheme.goldColor,
      title: 'Emoji Guess',
      description: 'Solve AI-generated answers from emoji clues.',
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
      'Trivia' => const TriviaScreen(),
      'Would You Rather' => const WouldYouRatherScreen(),
      'Charades' => const CharadesScreen(),
      'Emoji Guess' => const EmojiGuessScreen(),
      'Never Have I Ever' => const NeverHaveIEverScreen(),
      'Truth or Dare' => const TruthOrDareScreen(),
      _ => GamePlaceholderScreen(gameTitle: title),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Games')),
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
                        'Quick games. Big laughs.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a game and pass the device around—no setup required.',
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
                      game.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      game.description,
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
    return Scaffold(
      appBar: AppBar(title: Text(gameTitle)),
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
                    gameTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This game will be implemented in a future update.',
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
