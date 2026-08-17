import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'daily_challenge_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../games/screens/games_screen.dart';

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
    ),
    _CompetitionItem(
      icon: Icons.today,
      title: 'Daily Challenge',
      description:
          'Compete in today\'s selected game. The winner earns Tokens.',
      reward: 'Winner Tokens',
    ),
    _CompetitionItem(
      icon: Icons.emoji_events,
      title: 'Weekly Championship',
      description:
          'Compete across several game rounds and become this week\'s Family Champion.',
      reward: 'Family Wish',
    ),
    _CompetitionItem(
      icon: Icons.workspace_premium,
      title: 'Monthly Cup',
      description:
          'The family\'s biggest monthly competition. Win a trophy and bonus Tokens.',
      reward: 'Trophy and Bonus Tokens',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.navPlay), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            strings.playTogether,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            strings.playTogetherDescription,
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
                  if (competition.title == 'Quick Play') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GamesScreen(developerPreview: developerPreview),
                      ),
                    );
                    return;
                  }
                  if (competition.title == 'Daily Challenge') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DailyChallengeScreen(
                          developerPreview: developerPreview,
                        ),
                      ),
                    );
                    return;
                  }

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
          _FamilyLeaderboard(developerPreview: developerPreview),
          const SizedBox(height: 16),
          _SectionPlaceholder(
            icon: Icons.military_tech,
            title: strings.familyTrophyCabinet,
            description: strings.familyTrophyCabinetDescription,
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
    final strings = AppLocalizations.of(context)!;

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
                    _localizedCompetitionTitle(strings, competition.title),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
            Row(
              children: [
                Icon(Icons.card_giftcard, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    competition.title == 'Quick Play'
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
                    child: Text(strings.view),
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

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(name),
                        trailing: Text(
                          strings.tokenCount(tokens),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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
  });

  final IconData icon;
  final String title;
  final String description;
  final String reward;
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
