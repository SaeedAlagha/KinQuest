import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

const List<int> gameRoundOptions = [1, 3, 5];

class GameSetupView extends StatelessWidget {
  const GameSetupView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GameSetupHero(icon: icon, title: title, description: description),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class GameSetupHero extends StatelessWidget {
  const GameSetupHero({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.75),
            AppTheme.goldColor.withValues(alpha: 0.1),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(icon, color: colors.onPrimary, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameSetupSectionCard extends StatelessWidget {
  const GameSetupSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: child,
    );
  }
}

class GameRoundSelector extends StatelessWidget {
  const GameRoundSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.maximum,
    this.title = 'Rounds',
    this.description =
        'Choose a quick round or play a longer 3 or 5-round game.',
    this.keyPrefix = 'round-option',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int? maximum;
  final String title;
  final String description;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: gameRoundOptions.map((rounds) {
              final available = maximum == null || rounds <= maximum!;

              return ChoiceChip(
                key: ValueKey('$keyPrefix-$rounds'),
                avatar: Icon(
                  rounds == 1
                      ? Icons.flash_on_rounded
                      : rounds == 3
                      ? Icons.auto_awesome_rounded
                      : Icons.emoji_events_rounded,
                  size: 18,
                ),
                label: Text('$rounds ${rounds == 1 ? 'round' : 'rounds'}'),
                selected: value == rounds,
                onSelected: available ? (_) => onChanged(rounds) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
