import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../mascot/screens/sila_studio_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/screens/family_choice_screen.dart';
import '../../authentication/screens/welcome_screen.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';
import 'edit_profile_screen.dart';
import 'family_management_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: strings.editProfileTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditProfileScreen(developerPreview: developerPreview),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (developerPreview)
            const _DeveloperProfileHeader()
          else
            _ProfileHeader(colorScheme: colorScheme),

          const SizedBox(height: 24),

          _SectionTitle(title: strings.profileFamilySection),
          const SizedBox(height: 12),

          if (developerPreview)
            const _DeveloperFamilyCard()
          else
            const _FamilyDetailsCard(),

          const SizedBox(height: 24),

          _SectionTitle(title: strings.statistics),
          const SizedBox(height: 12),
          if (developerPreview)
            const _DeveloperStatisticsGrid()
          else
            const _StatisticsGrid(),
          const SizedBox(height: 24),
          _SectionTitle(title: strings.rewards),
          const SizedBox(height: 12),
          if (developerPreview)
            const _DeveloperRewardsSummary()
          else
            const _RewardsSummary(),
          const SizedBox(height: 24),
          _SectionTitle(title: strings.achievements),
          const SizedBox(height: 12),
          if (developerPreview)
            const _DeveloperAchievementsSection()
          else
            const _AchievementsSection(),
          const SizedBox(height: 24),
          _SectionTitle(title: strings.familyTrophyCabinet),
          const SizedBox(height: 12),
          _TrophyCabinetSection(developerPreview: developerPreview),
          const SizedBox(height: 24),
          _SectionTitle(title: strings.settings),
          const SizedBox(height: 12),
          _SettingsSection(developerPreview: developerPreview),
          const SizedBox(height: 28),

          if (!developerPreview)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  strings.logOut,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DeveloperProfileHeader extends StatelessWidget {
  const _DeveloperProfileHeader();

  static const _previewRewards = EquippedDigitalRewards(
    profileFrame: 'gold',
    profileBadge: 'family_star',
    profileTheme: 'sunset',
    nameplate: 'champion',
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return DigitalRewardProfileSurface(
      rewards: _previewRewards,
      child: Column(
        children: [
          const DigitalRewardAvatar(
            rewards: _previewRewards,
            radius: 44,
            icon: Icons.developer_mode_rounded,
          ),
          const SizedBox(height: 14),
          DigitalRewardNameplate(
            name: strings.silaDeveloper,
            rewards: _previewRewards,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'preview@sila.local',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.familyNameLabel(strings.developerFamilyName),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperStatisticsGrid extends StatelessWidget {
  const _DeveloperStatisticsGrid();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final statistics = [
      _StatisticItem(
        icon: Icons.sports_esports,
        label: strings.gamesPlayed,
        value: '12',
      ),
      _StatisticItem(icon: Icons.emoji_events, label: strings.wins, value: '7'),
      _StatisticItem(
        icon: Icons.local_fire_department,
        label: strings.currentStreak,
        value: strings.profileDayCount(4),
      ),
      _StatisticItem(
        icon: Icons.stars,
        label: strings.achievements,
        value: '2',
      ),
    ];

    return _StatisticsCardsGrid(statistics: statistics);
  }
}

class _DeveloperRewardsSummary extends StatelessWidget {
  const _DeveloperRewardsSummary();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _RewardCard(
            icon: Icons.monetization_on,
            value: '480',
            label: strings.familyTokens,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RewardCard(
            icon: Icons.auto_awesome,
            value: '2',
            label: strings.familyWishes,
          ),
        ),
      ],
    );
  }
}

class _DeveloperAchievementsSection extends StatelessWidget {
  const _DeveloperAchievementsSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final achievements = [
      _AchievementItem(
        icon: Icons.photo_library,
        title: strings.memoryKeeper,
        description: strings.memoryKeeperDescription,
        progress: 0.18,
        progressText: '18 / 100',
      ),
      _AchievementItem(
        icon: Icons.quiz,
        title: strings.quizMaster,
        description: strings.quizMasterDescription,
        progress: 0.35,
        progressText: '7 / 20',
      ),
      _AchievementItem(
        icon: Icons.groups,
        title: strings.teamPlayer,
        description: strings.teamPlayerDescription,
        progress: 0.4,
        progressText: '12 / 30',
      ),
    ];

    return Column(
      children: achievements
          .map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AchievementCard(achievement: achievement),
            ),
          )
          .toList(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(strings.noUserSignedIn),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(strings.couldNotLoadProfile),
            ),
          );
        }

        final data = snapshot.data?.data();

        final name = data?['name'] as String? ?? strings.silaMember;
        final email = data?['email'] as String? ?? user.email ?? '';
        final familyId = data?['familyId'] as String?;

        return DigitalRewardStyleBuilder(
          userId: user.uid,
          builder: (context, rewards) {
            final themed = rewards.profileTheme != 'default';
            final secondaryColor = themed
                ? Colors.white.withValues(alpha: 0.82)
                : colorScheme.onSurfaceVariant;
            final accentColor = themed ? Colors.white : colorScheme.primary;

            return DigitalRewardProfileSurface(
              rewards: rewards,
              child: Column(
                children: [
                  DigitalRewardAvatar(rewards: rewards, radius: 44),
                  const SizedBox(height: 14),
                  DigitalRewardNameplate(
                    name: name,
                    rewards: rewards,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: secondaryColor),
                  ),
                  const SizedBox(height: 4),
                  if (familyId == null || familyId.isEmpty)
                    Text(
                      strings.noFamilyJoinedYet,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('families')
                          .doc(familyId)
                          .snapshots(),
                      builder: (context, familySnapshot) {
                        if (familySnapshot.hasError) {
                          return Text(
                            strings.familyLoadError,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: secondaryColor),
                          );
                        }

                        final familyData = familySnapshot.data?.data();
                        final familyName =
                            familyData?['name'] as String? ??
                            strings.yourFamily;

                        return Text(
                          strings.familyNameLabel(familyName),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final data = userSnapshot.data?.data();

        final gamesPlayed = (data?['gamesPlayed'] as num?)?.toInt() ?? 0;
        final officialWins = (data?['officialWins'] as num?)?.toInt() ?? 0;
        final dailyWins = (data?['dailyWins'] as num?)?.toInt() ?? 0;
        final weeklyWins = (data?['weeklyWins'] as num?)?.toInt() ?? 0;
        final monthlyWins = (data?['monthlyWins'] as num?)?.toInt() ?? 0;
        final missionsCompleted =
            (data?['missionsCompleted'] as num?)?.toInt() ?? 0;
        final currentStreak = (data?['currentStreak'] as num?)?.toInt() ?? 0;
        final rankingPoints = (data?['rankingPoints'] as num?)?.toInt() ?? 0;
        final familyId = data?['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return _buildStatistics(
            strings: strings,
            gamesPlayed: gamesPlayed,
            officialWins: officialWins,
            dailyWins: dailyWins,
            weeklyWins: weeklyWins,
            monthlyWins: monthlyWins,
            missionsCompleted: missionsCompleted,
            currentStreak: currentStreak,
            rankingPoints: rankingPoints,
            memoryCount: 0,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('memories')
              .where('createdBy', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, memorySnapshot) {
            final memoryCount = memorySnapshot.data?.docs.length ?? 0;

            return _buildStatistics(
              strings: strings,
              gamesPlayed: gamesPlayed,
              officialWins: officialWins,
              dailyWins: dailyWins,
              weeklyWins: weeklyWins,
              monthlyWins: monthlyWins,
              missionsCompleted: missionsCompleted,
              currentStreak: currentStreak,
              rankingPoints: rankingPoints,
              memoryCount: memoryCount,
            );
          },
        );
      },
    );
  }

  Widget _buildStatistics({
    required AppLocalizations strings,
    required int gamesPlayed,
    required int officialWins,
    required int dailyWins,
    required int weeklyWins,
    required int monthlyWins,
    required int missionsCompleted,
    required int currentStreak,
    required int rankingPoints,
    required int memoryCount,
  }) {
    final statistics = [
      _StatisticItem(
        icon: Icons.sports_esports,
        label: strings.gamesPlayed,
        value: gamesPlayed.toString(),
      ),
      _StatisticItem(
        icon: Icons.emoji_events,
        label: strings.officialWins,
        value: officialWins.toString(),
      ),
      _StatisticItem(
        icon: Icons.today_rounded,
        label: strings.dailyWins,
        value: dailyWins.toString(),
      ),
      _StatisticItem(
        icon: Icons.emoji_events_outlined,
        label: strings.weeklyWins,
        value: weeklyWins.toString(),
      ),
      _StatisticItem(
        icon: Icons.workspace_premium_outlined,
        label: strings.monthlyWins,
        value: monthlyWins.toString(),
      ),
      _StatisticItem(
        icon: Icons.flag_rounded,
        label: strings.missionsCompleted,
        value: missionsCompleted.toString(),
      ),
      _StatisticItem(
        icon: Icons.photo_library_outlined,
        label: strings.memoriesAdded,
        value: memoryCount.toString(),
      ),
      _StatisticItem(
        icon: Icons.local_fire_department,
        label: strings.currentStreak,
        value: strings.profileDayCount(currentStreak),
      ),
      _StatisticItem(
        icon: Icons.leaderboard_rounded,
        label: strings.rankingPoints,
        value: rankingPoints.toString(),
      ),
    ];

    return _StatisticsCardsGrid(statistics: statistics);
  }
}

class _StatisticsCardsGrid extends StatelessWidget {
  const _StatisticsCardsGrid({required this.statistics});

  final List<_StatisticItem> statistics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final childAspectRatio = constraints.maxWidth < 360 ? 0.75 : 1.25;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statistics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _StatisticCard(statistic: statistics[index]);
          },
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({required this.statistic});

  final _StatisticItem statistic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statistic.icon, color: colorScheme.primary, size: 30),
          const SizedBox(height: 10),
          Text(
            statistic.value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            statistic.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RewardsSummary extends StatelessWidget {
  const _RewardsSummary();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Row(
        children: [
          Expanded(
            child: _RewardCard(
              icon: Icons.monetization_on,
              value: '0',
              label: strings.familyTokens,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RewardCard(
              icon: Icons.auto_awesome,
              value: '0',
              label: strings.familyWishes,
            ),
          ),
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final tokens = data?['tokens'] ?? 0;

        return Row(
          children: [
            Expanded(
              child: _RewardCard(
                icon: Icons.monetization_on,
                value: tokens.toString(),
                label: strings.familyTokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RewardCard(
                icon: Icons.auto_awesome,
                value: '0',
                label: strings.familyWishes,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 32),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data();
        final officialWins = (userData?['officialWins'] as num?)?.toInt() ?? 0;
        final missionsCompleted =
            (userData?['missionsCompleted'] as num?)?.toInt() ?? 0;
        final familyId = userData?['familyId'] as String?;

        final quizProgress = (officialWins / 20).clamp(0.0, 1.0);

        if (familyId == null || familyId.isEmpty) {
          return _buildAchievements(
            strings: strings,
            wins: officialWins,
            quizProgress: quizProgress,
            memoryCount: 0,
            missionsCompleted: missionsCompleted,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('memories')
              .where('createdBy', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, memorySnapshot) {
            final memoryCount = memorySnapshot.data?.docs.length ?? 0;

            return _buildAchievements(
              strings: strings,
              wins: officialWins,
              quizProgress: quizProgress,
              memoryCount: memoryCount,
              missionsCompleted: missionsCompleted,
            );
          },
        );
      },
    );
  }

  Widget _buildAchievements({
    required AppLocalizations strings,
    required int wins,
    required double quizProgress,
    required int memoryCount,
    required int missionsCompleted,
  }) {
    final memoryProgress = (memoryCount / 100).clamp(0.0, 1.0);
    final missionProgress = (missionsCompleted / 30).clamp(0.0, 1.0);
    final achievements = [
      _AchievementItem(
        icon: Icons.photo_library,
        title: strings.memoryKeeper,
        description: strings.memoryKeeperDescription,
        progress: memoryProgress,
        progressText: '$memoryCount / 100',
      ),
      _AchievementItem(
        icon: Icons.quiz,
        title: strings.quizMaster,
        description: strings.quizMasterDescription,
        progress: quizProgress,
        progressText: '$wins / 20',
      ),
      _AchievementItem(
        icon: Icons.groups,
        title: strings.teamPlayer,
        description: strings.teamPlayerDescription,
        progress: missionProgress,
        progressText: '$missionsCompleted / 30',
      ),
    ];

    return Column(
      children: achievements
          .map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AchievementCard(achievement: achievement),
            ),
          )
          .toList(),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final _AchievementItem achievement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                achievement.icon,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: achievement.progress),
                  const SizedBox(height: 6),
                  Text(
                    achievement.progressText,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyCabinetSection extends StatelessWidget {
  const _TrophyCabinetSection({required this.developerPreview});

  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    if (developerPreview) {
      return _buildTrophies(context, [
        _ProfileTrophy(
          title: strings.monthlyCupChampion,
          monthKey: '2026-08',
          winnerName: strings.previewPlayer,
        ),
      ]);
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmpty(context, strings);
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userSnapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(strings.couldNotLoadTrophies),
            ),
          );
        }

        final familyId = userSnapshot.data
            ?.data()?['familyId']
            ?.toString()
            .trim();

        if (familyId == null || familyId.isEmpty) {
          return _buildEmpty(context, strings);
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('trophies')
              .orderBy('earnedAt', descending: true)
              .snapshots(),
          builder: (context, trophySnapshot) {
            if (trophySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (trophySnapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  strings.couldNotLoadTrophies,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final trophies =
                trophySnapshot.data?.docs
                    .where(
                      (document) => document.data()['winnerId'] == user.uid,
                    )
                    .map((document) {
                      final data = document.data();
                      final storedTitle = data['title']?.toString();

                      return _ProfileTrophy(
                        title:
                            storedTitle == null ||
                                storedTitle == 'Monthly Cup Champion'
                            ? strings.monthlyCupChampion
                            : storedTitle,
                        monthKey: data['monthKey']?.toString() ?? '',
                        winnerName:
                            data['winnerName']?.toString() ?? strings.champion,
                      );
                    })
                    .toList() ??
                [];

            if (trophies.isEmpty) {
              return _buildEmpty(context, strings);
            }

            return _buildTrophies(context, trophies);
          },
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations strings) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            strings.noTrophiesYet,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            strings.trophiesEmptyDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTrophies(BuildContext context, List<_ProfileTrophy> trophies) {
    return Column(
      children: trophies.map((trophy) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.emoji_events_rounded),
            ),
            title: Text(
              trophy.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              trophy.monthKey.isEmpty
                  ? trophy.winnerName
                  : '${trophy.monthKey} • ${trophy.winnerName}',
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProfileTrophy {
  const _ProfileTrophy({
    required this.title,
    required this.monthKey,
    required this.winnerName,
  });

  final String title;
  final String monthKey;
  final String winnerName;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.developerPreview});

  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.checkroom_rounded),
            title: Text(strings.navSila),
            subtitle: const Text('Customize your Sila avatar'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SilaStudioScreen(developerPreview: developerPreview),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: Text(strings.appSettings),
            subtitle: Text(strings.appSettingsDescription),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(developerPreview: developerPreview),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(strings.privacySecurity),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(strings.notifications),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _StatisticItem {
  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _AchievementItem {
  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.progressText,
  });

  final IconData icon;
  final String title;
  final String description;
  final double progress;
  final String progressText;
}

class _FamilyDetailsCard extends StatelessWidget {
  const _FamilyDetailsCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(strings.noUserSignedIn),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (userSnapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(strings.familyLoadError),
            ),
          );
        }

        final userData = userSnapshot.data?.data();
        final familyId = userData?['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.group_add_outlined, size: 46),
                  const SizedBox(height: 12),
                  Text(
                    strings.youHaveNotJoinedFamily,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FamilyChoiceScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.family_restroom_rounded),
                    label: Text(strings.createOrJoinFamilyAction),
                  ),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .snapshots(),
          builder: (context, familySnapshot) {
            if (familySnapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (familySnapshot.hasError ||
                familySnapshot.data?.exists != true) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(strings.familyLoadError),
                ),
              );
            }

            final familyData = familySnapshot.data?.data();

            final familyName =
                familyData?['name'] as String? ?? strings.yourFamily;

            final inviteCode = familyData?['inviteCode'] as String? ?? familyId;

            final members =
                familyData?['members'] as List<dynamic>? ?? const [];

            return Card(
              margin: EdgeInsets.zero,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.family_restroom_rounded, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            familyName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      strings.inviteCodeLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            inviteCode,
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: strings.copyInviteCode,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: inviteCode),
                            );

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.familyInviteCodeCopied),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.profileFamilyMemberCount(members.length),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.shareFamilyInviteCode,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FamilyManagementScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.manage_accounts_outlined),
                        label: Text(strings.manageFamily),
                      ),
                    ),
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

class _DeveloperFamilyCard extends StatelessWidget {
  const _DeveloperFamilyCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.developerFamilyName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Text(strings.inviteCodeLabel),
            const SizedBox(height: 6),
            Text(
              'DEV123',
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(strings.profileFamilyMemberCount(5)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FamilyManagementScreen(developerPreview: true),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_accounts_outlined),
                label: Text(strings.manageFamily),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
