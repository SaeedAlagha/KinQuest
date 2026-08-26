import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/mascot/sila_mascot.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';

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
    return SilaPageBackdrop(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameSetupHero(
                  icon: icon,
                  title: title,
                  description: description,
                ),
                const SizedBox(height: 18),
                ...children,
              ],
            ),
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
    final strings = AppLocalizations.of(context)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -42,
            top: -48,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          PositionedDirectional(
            start: -46,
            bottom: -72,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.uaeRed.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UaeColorRibbon(height: 4),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 31),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.gameFamilyEyebrow,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.05,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SilaMascotGuide(
                  key: const ValueKey('game-setup-mascot-guide'),
                  title: strings.mascotName,
                  message: strings.mascotGameSetupMessage,
                  semanticLabel: strings.mascotSemanticLabel,
                  pose: SilaMascotPose.welcome,
                  compact: true,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
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
    this.title,
    this.description,
    this.keyPrefix = 'round-option',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int? maximum;
  final String? title;
  final String? description;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? strings.rounds,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            description ?? strings.roundsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                label: Text(strings.roundCount(rounds)),
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
