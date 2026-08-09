import 'package:flutter/material.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  static const List<_CompetitionItem> _competitions = [
    _CompetitionItem(
      icon: Icons.sports_kabaddi,
      title: 'Friendly Match',
      description:
          'Challenge one family member in Family Quiz, Match My Answer, or Memory Challenge.',
      reward: 'Tokens',
    ),
    _CompetitionItem(
      icon: Icons.today,
      title: 'Daily Challenge',
      description:
          'Play one AI-selected family game every day and maintain your family streak.',
      reward: 'Daily Tokens',
    ),
    _CompetitionItem(
      icon: Icons.emoji_events,
      title: 'Weekly Championship',
      description:
          'Compete through several rounds to become this week\'s Family Champion.',
      reward: 'Family Wish',
    ),
    _CompetitionItem(
      icon: Icons.workspace_premium,
      title: 'Monthly Cup',
      description:
          'The biggest monthly competition. Winners enter the Family Trophy Cabinet.',
      reward: 'Trophy and Bonus Tokens',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitions'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Compete Together',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Competitions organize who plays, when they play, and which games are included.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ..._competitions.map(
            (competition) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CompetitionCard(
                competition: competition,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompetitionPlaceholderScreen(
                        competitionTitle: competition.title,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _SectionPlaceholder(
            icon: Icons.leaderboard,
            title: 'Leaderboard',
            description:
                'Family rankings and competition scores will appear here.',
          ),
          const SizedBox(height: 16),
          const _SectionPlaceholder(
            icon: Icons.military_tech,
            title: 'Family Trophy Cabinet',
            description:
                'Previous weekly and monthly champions will appear here.',
          ),
        ],
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({required this.competition, required this.onTap});

  final _CompetitionItem competition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    competition.icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    competition.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              competition.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.card_giftcard, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reward: ${competition.reward}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: FilledButton(
                    onPressed: onTap,
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 38, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompetitionPlaceholderScreen extends StatelessWidget {
  const CompetitionPlaceholderScreen({
    required this.competitionTitle,
    super.key,
  });

  final String competitionTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(competitionTitle)),
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
                competitionTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Competition logic will be implemented in a future update.',
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

class _CompetitionItem {
  const _CompetitionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.reward,
  });

  final IconData icon;
  final String title;
  final String description;
  final String reward;
}
