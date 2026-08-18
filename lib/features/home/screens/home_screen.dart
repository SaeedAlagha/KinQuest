import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../core/widgets/sila_brand_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../../competitions/screens/daily_challenge_screen.dart';
import '../../games/screens/games_screen.dart';
import '../../memories/screens/add_memory_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../rewards/screens/rewards_hub_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onFamilyOverview});

  final VoidCallback? onFamilyOverview;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(strings.noUserSignedIn))),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data();
        final name = userData?['name'] as String? ?? strings.silaMember;
        final tokens = userData?['tokens'] ?? 0;
        final familyId = userData?['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return HomeDashboard(
            name: name,
            familyName: strings.noFamilyJoined,
            memberCount: 0,
            tokens: tokens.toString(),
            onFamilyOverview: onFamilyOverview,
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .snapshots(),
          builder: (context, familySnapshot) {
            final familyData = familySnapshot.data?.data();
            final familyName =
                familyData?['name'] as String? ?? strings.yourFamily;
            final members = List<String>.from(
              familyData?['members'] ?? const [],
            );

            return HomeDashboard(
              name: name,
              familyName: familyName,
              memberCount: members.length,
              tokens: tokens.toString(),
              onFamilyOverview: onFamilyOverview,
            );
          },
        );
      },
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.name,
    required this.familyName,
    required this.memberCount,
    required this.tokens,
    this.developerPreview = false,
    this.onFamilyOverview,
  });

  final String name;
  final String familyName;
  final int memberCount;
  final String tokens;
  final bool developerPreview;
  final VoidCallback? onFamilyOverview;

  void _showPreviewNotice(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.developerPreviewMemoryReadOnly)),
    );
  }

  void _openFamilyOverview(BuildContext context) {
    final overviewCallback = onFamilyOverview;

    if (overviewCallback != null) {
      overviewCallback();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(developerPreview: developerPreview),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;
            final pagePadding = constraints.maxWidth < 480 ? 20.0 : 32.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pagePadding, 28, pagePadding, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(name: name, familyName: familyName),
                      const SizedBox(height: 18),
                      FamilyYearBanner(compact: constraints.maxWidth < 480),
                      const SizedBox(height: 22),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _FamilyOverviewCard(
                                familyName: familyName,
                                memberCount: memberCount,
                                onOverview: () => _openFamilyOverview(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: _FamilyStats(
                                stacked: true,
                                memberCount: memberCount,
                                tokens: tokens,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _FamilyOverviewCard(
                          familyName: familyName,
                          memberCount: memberCount,
                          onOverview: () => _openFamilyOverview(context),
                        ),
                        const SizedBox(height: 16),
                        _FamilyStats(
                          stacked: false,
                          memberCount: memberCount,
                          tokens: tokens,
                        ),
                      ],
                      const SizedBox(height: 34),
                      _QuickActionCard(
                        icon: Icons.today_rounded,
                        accent: AppTheme.goldColor,
                        title: strings.todaysDailyChallenge,
                        subtitle: strings.dailyChallengeHomeDescription,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DailyChallengeScreen(
                              developerPreview: developerPreview,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeading(
                        eyebrow: strings.growingInUnity,
                        title: strings.smallMomentsStrongerBonds,
                        subtitle: strings.homeBondDescription,
                      ),
                      const SizedBox(height: 16),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.add_photo_alternate_outlined,
                                accent: AppTheme.coralColor,
                                title: strings.addMemory,
                                subtitle: strings.addMemoryDescription,
                                onTap: developerPreview
                                    ? () => _showPreviewNotice(context)
                                    : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AddMemoryScreen(),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.sports_esports_outlined,
                                accent: AppTheme.tealColor,
                                title: strings.challengeFamily,
                                subtitle: strings.challengeFamilyDescription,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GamesScreen(
                                      developerPreview: developerPreview,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.redeem_rounded,
                                accent: AppTheme.goldColor,
                                title: 'Rewards',
                                subtitle:
                                    'Spend Tokens on family and digital rewards.',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RewardsHubScreen(
                                      developerPreview: developerPreview,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _QuickActionCard(
                          icon: Icons.add_photo_alternate_outlined,
                          accent: AppTheme.coralColor,
                          title: strings.addMemory,
                          subtitle: strings.addMemoryDescription,
                          onTap: developerPreview
                              ? () => _showPreviewNotice(context)
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddMemoryScreen(),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        _QuickActionCard(
                          icon: Icons.sports_esports_outlined,
                          accent: AppTheme.tealColor,
                          title: strings.challengeFamily,
                          subtitle: strings.challengeFamilyDescription,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GamesScreen(
                                developerPreview: developerPreview,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _QuickActionCard(
                          icon: Icons.redeem_rounded,
                          accent: AppTheme.goldColor,
                          title: 'Rewards',
                          subtitle:
                              'Spend Tokens on family and digital rewards.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RewardsHubScreen(
                                developerPreview: developerPreview,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.familyName});

  final String name;
  final String familyName;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      strings.welcomeName(name),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.waving_hand_rounded,
                    color: AppTheme.goldColor,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                strings.silaFamilySpace,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.tealColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.75,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                familyName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const SilaBrandMark(size: 48, showShadow: false),
      ],
    );
  }
}

class _FamilyOverviewCard extends StatelessWidget {
  const _FamilyOverviewCard({
    required this.familyName,
    required this.memberCount,
    required this.onOverview,
  });

  final String familyName;
  final int memberCount;
  final VoidCallback onOverview;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -36,
            top: -48,
            child: _DecorativeOrb(size: 190, opacity: 0.1),
          ),
          const Positioned(
            right: 60,
            bottom: -70,
            child: _DecorativeOrb(size: 150, opacity: 0.07),
          ),
          const Positioned(
            left: -38,
            bottom: -52,
            child: _DecorativeOrb(
              size: 132,
              opacity: 0.15,
              color: AppTheme.uaeRed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.join_inner_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            strings.rootsBondsGrowth,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  familyName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.familyMembersConnected(memberCount),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onOverview,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                  ),
                  icon: const Icon(Icons.groups_2_rounded),
                  label: Text(strings.familyOverview),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({
    required this.size,
    required this.opacity,
    this.color = Colors.white,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FamilyStats extends StatelessWidget {
  const _FamilyStats({
    required this.stacked,
    required this.memberCount,
    required this.tokens,
  });

  final bool stacked;
  final int memberCount;
  final String tokens;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (stacked) {
      return Column(
        children: [
          _MetricCard(
            icon: Icons.groups_2_rounded,
            accent: AppTheme.tealColor,
            value: memberCount.toString(),
            label: strings.familyMembers,
          ),
          const SizedBox(height: 14),
          _MetricCard(
            icon: Icons.stars_rounded,
            accent: AppTheme.goldColor,
            value: tokens,
            label: strings.familyTokens,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.groups_2_rounded,
            accent: AppTheme.tealColor,
            value: memberCount.toString(),
            label: strings.familyMembers,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: Icons.stars_rounded,
            accent: AppTheme.goldColor,
            value: tokens,
            label: strings.familyTokens,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color accent;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 18),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: accent, size: 27),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
