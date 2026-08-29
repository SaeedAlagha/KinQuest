import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import 'daily_challenge_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';
import '../../games/screens/games_screen.dart';
import 'weekly_championship_screen.dart';
import 'monthly_cup_screen.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  static const List<_CompetitionItem> _competitions = [
    _CompetitionItem(
      icon: Icons.flash_on,
      title: 'Quick Play',
      description:
          'Choose any game and play together on one phone. No Tokens or official ranking.',
      reward: 'Just for fun • No Tokens',
      accent: AppTheme.primaryColor,
    ),
    _CompetitionItem(
      icon: Icons.today,
      title: 'Daily Challenge',
      description:
          'Compete in today\'s selected game. The winner earns Tokens.',
      reward: 'Winner Tokens',
      accent: AppTheme.coralColor,
    ),
    _CompetitionItem(
      icon: Icons.emoji_events,
      title: 'Weekly Championship',
      description:
          'Compete across four official games and become this week\'s Family Champion.',
      reward: '+50 Tokens + Ranking Points',
      accent: AppTheme.goldColor,
    ),
    _CompetitionItem(
      icon: Icons.workspace_premium,
      title: 'Monthly Cup',
      description:
          'The family\'s biggest monthly competition. Win a trophy and bonus Tokens.',
      reward: 'Trophy and Bonus Tokens',
      accent: Color(0xFF7B4BB7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.navPlay), centerTitle: true),
      body: SilaPageBackdrop(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 38),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CompetitionArenaHero(
                    strings: strings,
                    developerPreview: developerPreview,
                  ),
                  const SizedBox(height: 22),
                  ..._competitions.map(
                    (competition) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CompetitionCard(
                        competition: competition,
                        onTap: () => _openCompetition(context, competition),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FamilyLeaderboard(developerPreview: developerPreview),
                  const SizedBox(height: 16),
                  _FamilyTrophyCabinet(developerPreview: developerPreview),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCompetition(BuildContext context, _CompetitionItem competition) {
    final Widget destination = switch (competition.title) {
      'Quick Play' => GamesScreen(developerPreview: developerPreview),

      'Daily Challenge' => DailyChallengeScreen(
        developerPreview: developerPreview,
      ),
      'Weekly Championship' => WeeklyChampionshipScreen(
        developerPreview: developerPreview,
      ),
      'Monthly Cup' => MonthlyCupScreen(developerPreview: developerPreview),
      _ => CompetitionPlaceholderScreen(competitionTitle: competition.title),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
  }
}

class _CompetitionArenaHero extends StatelessWidget {
  const _CompetitionArenaHero({
    required this.strings,
    required this.developerPreview,
  });

  final AppLocalizations strings;
  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    return DigitalRewardStyleBuilder(
      userId: developerPreview ? null : FirebaseAuth.instance.currentUser?.uid,
      preview: developerPreview
          ? const EquippedDigitalRewards(
              mascotAccessory: SilaMascotAccessories.guardianCrown,
              mascotOutfit: SilaMascotOutfits.gameJersey,
              mascotAura: SilaMascotAuras.victoryBurst,
            )
          : null,
      builder: (context, rewards) => _buildHero(context, rewards),
    );
  }

  Widget _buildHero(BuildContext context, EquippedDigitalRewards rewards) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -38,
            top: -58,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UaeColorRibbon(height: 4),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SilaMascot(
                      key: const ValueKey('competition-sila-host'),
                      pose: SilaMascotPose.winner,
                      motion: SilaMascotMotion.celebrate,
                      loop: !developerPreview,
                      height: 126,
                      semanticLabel: strings.mascotSemanticLabel,
                      accessoryAssetKey: rewards.mascotAccessory,
                      outfitAssetKey: rewards.mascotOutfit,
                      auraAssetKey: rewards.mascotAura,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.growingInUnity.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.05,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            strings.playTogether,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.playTogetherDescription,
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
              ],
            ),
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
    final strings = AppLocalizations.of(context)!;
    final accent = competition.accent;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [colorScheme.surface, accent.withValues(alpha: 0.075)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(19),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(competition.icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _localizedCompetitionTitle(strings, competition.title),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _localizedCompetitionDescription(
                strings,
                competition.title,
                competition.description,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.card_giftcard,
                            size: 18,
                            color: accent,
                          ),
                        ),
                        const TextSpan(text: '  '),
                        TextSpan(
                          text: competition.title == 'Quick Play'
                              ? _localizedCompetitionReward(
                                  strings,
                                  competition.title,
                                  competition.reward,
                                )
                              : strings.rewardLabel(
                                  _localizedCompetitionReward(
                                    strings,
                                    competition.title,
                                    competition.reward,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Color.lerp(accent, AppTheme.primaryDark, 0.35),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                  label: Text(strings.view),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyLeaderboard extends StatelessWidget {
  const _FamilyLeaderboard({required this.developerPreview});

  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (developerPreview) {
      return const _DeveloperFamilyLeaderboard();
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _SectionPlaceholder(
        icon: Icons.leaderboard,
        title: strings.leaderboard,
        description: strings.leaderboardSignIn,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final familyId = userSnapshot.data?.data()?['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return _SectionPlaceholder(
            icon: Icons.leaderboard,
            title: strings.leaderboard,
            description: strings.leaderboardJoinFamily,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('familyId', isEqualTo: familyId)
              .snapshots(),
          builder: (context, membersSnapshot) {
            if (membersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (membersSnapshot.hasError) {
              return _SectionPlaceholder(
                icon: Icons.leaderboard,
                title: strings.leaderboard,
                description: strings.leaderboardLoadError,
              );
            }

            final members = membersSnapshot.data?.docs.toList() ?? [];

            members.sort((a, b) {
              final aTokens = a.data()['tokens'] as num? ?? 0;
              final bTokens = b.data()['tokens'] as num? ?? 0;

              return bTokens.compareTo(aTokens);
            });

            if (members.isEmpty) {
              return _SectionPlaceholder(
                icon: Icons.leaderboard,
                title: strings.leaderboard,
                description: strings.leaderboardNoMembers,
              );
            }

            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.familyLeaderboard,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(members.length, (index) {
                      final data = members[index].data();
                      final name =
                          data['name'] as String? ?? strings.familyMember;
                      final tokens = data['tokens'] as num? ?? 0;

                      return DigitalRewardStyleBuilder(
                        userId: members[index].id,
                        builder: (context, rewards) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: DigitalRewardAvatar(
                            rewards: rewards,
                            initials: '${index + 1}',
                          ),
                          title: DigitalRewardNameplate(
                            name: name,
                            rewards: rewards,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          trailing: Text(
                            strings.tokenCount(tokens),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DeveloperFamilyLeaderboard extends StatelessWidget {
  const _DeveloperFamilyLeaderboard();

  static const _members = [
    ('Amal', 480),
    ('Omar', 415),
    ('Mariam', 360),
    ('Zayed', 290),
    ('Noor', 245),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.developerFamilyLeaderboard,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(_members.length, (index) {
              final member = _members[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(member.$1),
                trailing: Text(
                  strings.tokenCount(member.$2),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FamilyTrophyCabinet extends StatelessWidget {
  const _FamilyTrophyCabinet({required this.developerPreview});

  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (developerPreview) {
      return _TrophyCabinetCard(
        trophies: [
          _TrophyEntry(
            type: 'monthlyCup',
            winnerName: 'Amal',
            period: '2026-08',
          ),
          _TrophyEntry(
            type: 'weeklyChampionship',
            winnerName: 'Omar',
            period: '2026-W34',
          ),
        ],
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _SectionPlaceholder(
        icon: Icons.emoji_events_outlined,
        title: strings.familyTrophyCabinet,
        description: strings.trophyCabinetSignIn,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData && !userSnapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }

        final familyId = userSnapshot.data?.data()?['familyId']?.toString();
        if (userSnapshot.hasError || familyId == null || familyId.isEmpty) {
          return _SectionPlaceholder(
            icon: Icons.emoji_events_outlined,
            title: strings.familyTrophyCabinet,
            description: userSnapshot.hasError
                ? strings.trophyCabinetLoadError
                : strings.trophyCabinetJoinFamily,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('trophies')
              .orderBy('earnedAt', descending: true)
              .limit(6)
              .snapshots(),
          builder: (context, trophySnapshot) {
            if (!trophySnapshot.hasData && !trophySnapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            if (trophySnapshot.hasError) {
              return _SectionPlaceholder(
                icon: Icons.emoji_events_outlined,
                title: strings.familyTrophyCabinet,
                description: strings.trophyCabinetLoadError,
              );
            }

            final trophies =
                trophySnapshot.data?.docs.map((document) {
                  final data = document.data();
                  return _TrophyEntry(
                    type: data['type']?.toString() ?? '',
                    winnerName:
                        data['winnerName']?.toString() ?? strings.familyMember,
                    period:
                        data['monthKey']?.toString() ??
                        data['weekKey']?.toString() ??
                        '',
                  );
                }).toList() ??
                const <_TrophyEntry>[];

            if (trophies.isEmpty) {
              return _SectionPlaceholder(
                icon: Icons.emoji_events_outlined,
                title: strings.familyTrophyCabinet,
                description: strings.familyTrophyCabinetDescription,
              );
            }
            return _TrophyCabinetCard(trophies: trophies);
          },
        );
      },
    );
  }
}

class _TrophyCabinetCard extends StatelessWidget {
  const _TrophyCabinetCard({required this.trophies});

  final List<_TrophyEntry> trophies;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.goldColor.withValues(alpha: 0.2),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppTheme.goldColor,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.familyTrophyCabinet,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...trophies.map(
                (trophy) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.goldColor.withValues(alpha: 0.18),
                    child: Icon(
                      trophy.type == 'monthlyCup'
                          ? Icons.workspace_premium_rounded
                          : Icons.military_tech_rounded,
                      color: AppTheme.goldColor,
                    ),
                  ),
                  title: Text(
                    trophy.type == 'monthlyCup'
                        ? strings.monthlyCupTrophy
                        : strings.weeklyChampionTrophy,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(strings.trophyWonBy(trophy.winnerName)),
                  trailing: trophy.period.isEmpty
                      ? null
                      : Text(
                          trophy.period,
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrophyEntry {
  const _TrophyEntry({
    required this.type,
    required this.winnerName,
    required this.period,
  });

  final String type;
  final String winnerName;
  final String period;
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
    final strings = AppLocalizations.of(context)!;
    final localizedTitle = _localizedCompetitionTitle(
      strings,
      competitionTitle,
    );

    return Scaffold(
      appBar: AppBar(title: Text(localizedTitle)),
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
                localizedTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                strings.competitionFutureUpdate,
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
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final String reward;
  final Color accent;
}

String _localizedCompetitionTitle(AppLocalizations strings, String title) =>
    switch (title) {
      'Quick Play' => strings.quickPlay,
      'Daily Challenge' => strings.dailyChallenge,
      'Weekly Championship' => strings.weeklyChampionship,
      'Monthly Cup' => strings.monthlyCup,
      _ => title,
    };

String _localizedCompetitionDescription(
  AppLocalizations strings,
  String title,
  String fallback,
) => switch (title) {
  'Quick Play' => strings.quickPlayDescription,
  'Daily Challenge' => strings.dailyChallengeCompetitionDescription,
  'Weekly Championship' => strings.weeklyChampionshipDescription,
  'Monthly Cup' => strings.monthlyCupDescription,
  _ => fallback,
};

String _localizedCompetitionReward(
  AppLocalizations strings,
  String title,
  String fallback,
) => switch (title) {
  'Quick Play' => strings.quickPlayReward,
  'Daily Challenge' => strings.dailyChallengeCompetitionReward,
  'Weekly Championship' => strings.weeklyChampionshipReward,
  'Monthly Cup' => strings.monthlyCupReward,
  _ => fallback,
};
