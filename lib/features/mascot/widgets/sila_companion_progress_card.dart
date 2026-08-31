import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/sila_companion_progress.dart';

class SilaCompanionProgressCard extends StatelessWidget {
  const SilaCompanionProgressCard({
    super.key,
    this.developerPreview = false,
    this.progress,
  });

  final bool developerPreview;
  final SilaCompanionProgress? progress;

  @override
  Widget build(BuildContext context) {
    final suppliedProgress = progress;
    if (suppliedProgress != null) {
      return _SilaProgressContent(progress: suppliedProgress);
    }

    if (developerPreview) {
      return const _SilaProgressContent(
        progress: SilaCompanionProgress(
          stats: SilaCompanionStats(
            gamesPlayed: 49,
            missionsCompleted: 8,
            officialWins: 5,
            weeklyWins: 1,
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _SilaProgressContent(
        progress: SilaCompanionProgress(stats: SilaCompanionStats()),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() ?? const <String, dynamic>{};
        final personalProgress = SilaCompanionProgress(
          stats: SilaCompanionStats.fromMembers([userData]),
        );
        final familyId = userData['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return _SilaProgressContent(
            progress: personalProgress,
            loading: userSnapshot.connectionState == ConnectionState.waiting,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('familyId', isEqualTo: familyId)
              .snapshots(),
          builder: (context, familySnapshot) {
            final documents = familySnapshot.data?.docs;
            final familyProgress = documents == null
                ? personalProgress
                : SilaCompanionProgress(
                    stats: SilaCompanionStats.fromMembers(
                      documents.map((document) => document.data()),
                    ),
                  );
            return _SilaProgressContent(
              progress: familyProgress,
              loading:
                  documents == null &&
                  familySnapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      },
    );
  }
}

class _SilaProgressContent extends StatelessWidget {
  const _SilaProgressContent({required this.progress, this.loading = false});

  final SilaCompanionProgress progress;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final next = progress.nextLevel;

    return Container(
      key: const ValueKey('sila-bond-progress-card'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.72),
            colors.surface,
            colors.tertiaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: colors.onPrimary,
                  size: 27,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 610),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.silaBondTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(strings.silaBondDescription),
                  ],
                ),
              ),
              _PointsPill(points: progress.bondPoints),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.silaBondLevel(
                        progress.currentLevel.index + 1,
                        _levelName(strings, progress.currentLevel),
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      next == null
                          ? strings.silaBondMaxLevel
                          : strings.silaBondPointsToNext(
                              progress.pointsToNextLevel,
                              _levelName(strings, next),
                            ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsetsDirectional.only(start: 12),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: strings.silaBondProgressSemantic(
              (progress.levelProgress * 100).round(),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                key: const ValueKey('sila-bond-level-progress'),
                value: progress.levelProgress,
                minHeight: 13,
                backgroundColor: colors.surface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _StatsGrid(stats: progress.stats),
          const SizedBox(height: 25),
          Row(
            children: [
              Icon(Icons.route_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.silaBondJourneyTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            strings.silaBondJourneyDescription,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = width < 330
                  ? width
                  : width < 700
                  ? (width - 10) / 2
                  : (width - 40) / 5;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final level in SilaCompanionLevel.values)
                    SizedBox(
                      width: itemWidth,
                      child: _JourneyMilestone(
                        level: level,
                        name: _levelName(strings, level),
                        reached: progress.hasReached(level),
                        current: progress.currentLevel == level,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PointsPill extends StatelessWidget {
  const _PointsPill({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: colors.tertiary, size: 21),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              strings.silaBondPoints(points),
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final SilaCompanionStats stats;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final items = [
      (Icons.sports_esports_rounded, strings.gamesPlayed, stats.gamesPlayed),
      (
        Icons.task_alt_rounded,
        strings.missionsCompleted,
        stats.missionsCompleted,
      ),
      (Icons.emoji_events_rounded, strings.officialWins, stats.officialWins),
      (
        Icons.workspace_premium_rounded,
        strings.silaBondTrophies,
        stats.trophies,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 560 ? 2 : 4;
        final spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _StatTile(icon: item.$1, label: item.$2, value: item.$3),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 21),
          const SizedBox(height: 7),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyMilestone extends StatelessWidget {
  const _JourneyMilestone({
    required this.level,
    required this.name,
    required this.reached,
    required this.current,
  });

  final SilaCompanionLevel level;
  final String name;
  final bool reached;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final status = current
        ? strings.silaBondCurrent
        : reached
        ? strings.silaBondReached
        : strings.silaBondLocked;

    return Semantics(
      label: '$name, $status',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: current
              ? colors.primary
              : reached
              ? colors.secondaryContainer
              : colors.surface.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: current ? colors.primary : colors.outlineVariant,
            width: current ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  current
                      ? Icons.favorite_rounded
                      : reached
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: current
                      ? colors.onPrimary
                      : reached
                      ? colors.onSecondaryContainer
                      : colors.onSurfaceVariant,
                  size: 21,
                ),
                const Spacer(),
                Text(
                  '${level.index + 1}',
                  style: TextStyle(
                    color: current ? colors.onPrimary : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: current ? colors.onPrimary : null,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: current
                    ? colors.onPrimary.withValues(alpha: 0.82)
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _levelName(AppLocalizations strings, SilaCompanionLevel level) {
  return switch (level) {
    SilaCompanionLevel.newCompanion => strings.silaBondNewCompanion,
    SilaCompanionLevel.familyFriend => strings.silaBondFamilyFriend,
    SilaCompanionLevel.memoryKeeper => strings.silaBondMemoryKeeper,
    SilaCompanionLevel.familyGuardian => strings.silaBondFamilyGuardian,
    SilaCompanionLevel.legacyCompanion => strings.silaBondLegacyCompanion,
  };
}
