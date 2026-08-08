import 'package:flutter/material.dart';
import 'trivia_screen.dart';
import 'charades_screen.dart';
import 'never_have_i_ever_screen.dart';
import 'would_you_rather_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  static const List<_GameItem> _games = [
    _GameItem(
      icon: Icons.favorite,
      title: 'Family Quiz',
      description:
          'Answer personalized questions and discover how well you know your family.',
    ),
    _GameItem(
      icon: Icons.compare_arrows,
      title: 'Match My Answer',
      description: 'Try to match another family member\'s private answer.',
    ),
    _GameItem(
      icon: Icons.photo_library,
      title: 'Memory Challenge',
      description:
          'Play AI-generated challenges based on your family memories.',
      isSignatureFeature: true,
    ),
    _GameItem(
      icon: Icons.psychology,
      title: 'AI Knowledge Challenge',
      description:
          'Test your knowledge in science, geography, history, sports, and more.',
    ),
    _GameItem(
      icon: Icons.groups,
      title: 'Family Missions',
      description:
          'Complete real-life activities together and earn family rewards.',
    ),
    _GameItem(
      icon: Icons.celebration,
      title: 'Party Games',
      description:
          'Enjoy quick games such as Charades, Emoji Guess, and Would You Rather.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _games.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final game = _games[index];

          return _GameCard(
            game: game,
            onPlay: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => game.title == 'Party Games'
                      ? const PartyGamesScreen()
                      : GamePlaceholderScreen(gameTitle: game.title),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onPlay});

  final _GameItem game;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: game.isSignatureFeature
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: game.isSignatureFeature ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    game.icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (game.isSignatureFeature)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'KINQUEST SIGNATURE',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                      Text(
                        game.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              game.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartyGamesScreen extends StatelessWidget {
  const PartyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Games')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Trivia'),
              subtitle: const Text(
                'Answer AI-generated questions and test your knowledge.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TriviaScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Would You Rather'),
              subtitle: const Text(
                'Choose between two fun AI-generated options.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WouldYouRatherScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.theater_comedy),
              title: const Text('Charades'),
              subtitle: const Text(
                'Act out AI-generated prompts for your family.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CharadesScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sentiment_satisfied_alt),
              title: const Text('Never Have I Ever'),
              subtitle: const Text(
                'Play with fun AI-generated family-friendly statements.',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NeverHaveIEverScreen(),
                  ),
                );
              },
            ),
          ),
        ],
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                gameTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'This game will be implemented in a future update.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameItem {
  const _GameItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isSignatureFeature = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSignatureFeature;
}
