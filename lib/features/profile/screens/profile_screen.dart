import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileHeader(colorScheme: colorScheme),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Statistics'),
          const SizedBox(height: 12),
          const _StatisticsGrid(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Rewards'),
          const SizedBox(height: 12),
          const _RewardsSummary(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Achievements'),
          const SizedBox(height: 12),
          const _AchievementsSection(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Family Wishes'),
          const SizedBox(height: 12),
          const _FamilyWishesSection(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Family Trophy Cabinet'),
          const SizedBox(height: 12),
          const _TrophyCabinetPlaceholder(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Settings'),
          const SizedBox(height: 12),
          const _SettingsSection(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No user is currently signed in.'),
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

        final data = snapshot.data?.data();

        final name = data?['name'] as String? ?? 'KinQuest User';
        final email = data?['email'] as String? ?? user.email ?? '';
        final familyId = data?['familyId'] as String?;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  familyId == null
                      ? 'No family joined yet'
                      : 'Family: $familyId',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final gamesPlayed = data?['gamesPlayed'] ?? 0;
final wins = data?['wins'] ?? 0;
final currentStreak = data?['currentStreak'] ?? 0;
final achievementsCompleted = wins >= 20 ? 1 : 0;
        final statistics = [
          _StatisticItem(
            icon: Icons.sports_esports,
            label: 'Games Played',
            value: gamesPlayed.toString(),
          ),
         _StatisticItem(
  icon: Icons.emoji_events,
  label: 'Wins',
  value: wins.toString(),
),
          _StatisticItem(
  icon: Icons.local_fire_department,
  label: 'Current Streak',
  value: '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
),
          _StatisticItem(
  icon: Icons.stars,
  label: 'Achievements',
  value: achievementsCompleted.toString(),
),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statistics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Row(
        children: [
          Expanded(
            child: _RewardCard(
              icon: Icons.monetization_on,
              value: '0',
              label: 'Family Tokens',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _RewardCard(
              icon: Icons.auto_awesome,
              value: '0',
              label: 'Family Wishes',
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
                label: 'Family Tokens',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _RewardCard(
                icon: Icons.auto_awesome,
                value: '0',
                label: 'Family Wishes',
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final wins = data?['wins'] ?? 0;

        final quizProgress = (wins / 20).clamp(0.0, 1.0);

        final achievements = [
          const _AchievementItem(
            icon: Icons.photo_library,
            title: 'Memory Keeper',
            description: 'Save 100 family memories.',
            progress: 0,
            progressText: '0 / 100',
          ),
          _AchievementItem(
            icon: Icons.quiz,
            title: 'Quiz Master',
            description: 'Win 20 Family Quizzes.',
            progress: quizProgress,
            progressText: '$wins / 20',
          ),
          const _AchievementItem(
            icon: Icons.groups,
            title: 'Team Player',
            description: 'Complete 30 Family Missions.',
            progress: 0,
            progressText: '0 / 30',
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
      },
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

class _FamilyWishesSection extends StatelessWidget {
  const _FamilyWishesSection();

  @override
  Widget build(BuildContext context) {
    return const _EmptyStateCard(
      icon: Icons.auto_awesome,
      title: 'No Family Wishes yet',
      description:
          'Family Wishes earned from major competitions will appear here.',
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TrophyCabinetPlaceholder extends StatelessWidget {
  const _TrophyCabinetPlaceholder();

  @override
  Widget build(BuildContext context) {
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
            'No trophies yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Weekly and monthly championship trophies will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Privacy'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            trailing: Icon(Icons.chevron_right),
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
