import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../digital/digital_reward_catalog.dart';
import '../digital/digital_reward_definition.dart';
import '../digital/digital_reward_service.dart';
import '../digital/digital_reward_visuals.dart';
import '../models/reward_wishlist_proposal.dart';
import '../services/rewards_service.dart';
import 'token_history_screen.dart';
import 'my_digital_rewards_screen.dart';
import 'reward_wishlist_negotiation_screen.dart';

class RewardsHubScreen extends StatefulWidget {
  const RewardsHubScreen({
    super.key,
    this.developerPreview = false,
    this.highlightedGoalId,
  });

  final bool developerPreview;
  final String? highlightedGoalId;

  @override
  State<RewardsHubScreen> createState() => _RewardsHubScreenState();
}

class _RewardsHubScreenState extends State<RewardsHubScreen> {
  RewardsService? _rewardsService;

  RewardsService get _service => _rewardsService ??= RewardsService();
  final DigitalRewardService _digitalRewardService = DigitalRewardService();
  final Future<List<DigitalRewardDefinition>> _catalog =
      DigitalRewardCatalog.load();

  String? _processingRewardId;

  Future<void> _purchaseDigitalReward({
    required DigitalRewardDefinition reward,
  }) async {
    if (_processingRewardId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unlock reward?'),
          content: Text(
            'Spend ${reward.cost} Tokens to permanently unlock '
            '"${reward.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingRewardId = reward.id;
    });

    try {
      await _digitalRewardService.purchase(reward.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${reward.name} unlocked!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _processingRewardId = null;
        });
      }
    }
  }

  Future<void> _equipDigitalReward(DigitalRewardDefinition reward) async {
    if (_processingRewardId != null) return;

    setState(() {
      _processingRewardId = reward.id;
    });

    try {
      await _digitalRewardService.equip(reward.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${reward.name} equipped across Sila.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _processingRewardId = null;
        });
      }
    }
  }

  String _messageFromError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.developerPreview) {
      return _buildDeveloperPreview();
    }

    final user = FirebaseAuth.instance.currentUser;
    final strings = AppLocalizations.of(context)!;

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
        if (userSnapshot.connectionState == ConnectionState.waiting &&
            !userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Center(child: Text(strings.couldNotLoadRewardsAccount)),
            ),
          );
        }

        final userData = userSnapshot.data?.data();
        final familyId = userData?['familyId']?.toString().trim();

        final tokens = (userData?['tokens'] as num?)?.toInt() ?? 0;
        final dailyWins = (userData?['dailyWins'] as num?)?.toInt() ?? 0;
        final weeklyWins = (userData?['weeklyWins'] as num?)?.toInt() ?? 0;
        final monthlyWins = (userData?['monthlyWins'] as num?)?.toInt() ?? 0;
        final missionsCompleted =
            (userData?['missionsCompleted'] as num?)?.toInt() ?? 0;

        if (familyId == null || familyId.isEmpty) {
          return _RewardsScaffold(
            tokens: tokens,
            child: _RewardsMessage(
              icon: Icons.family_restroom_rounded,
              title: strings.joinFamilyFirst,
              message: strings.joinFamilyRewardsDescription,
            ),
          );
        }

        return _buildRealRewards(
          familyId: familyId,
          userId: user.uid,
          tokens: tokens,
          dailyWins: dailyWins,
          weeklyWins: weeklyWins,
          monthlyWins: monthlyWins,
          missionsCompleted: missionsCompleted,
        );
      },
    );
  }

  Widget _buildRealRewards({
    required String familyId,
    required String userId,
    required int tokens,
    required int dailyWins,
    required int weeklyWins,
    required int monthlyWins,
    required int missionsCompleted,
  }) {
    final strings = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('rewardWishlistProposals')
          .where('requesterId', isEqualTo: userId)
          .snapshots(),
      builder: (context, proposalSnapshot) {
        final goals =
            proposalSnapshot.data?.docs
                .map(RewardWishlistProposal.fromDocument)
                .where(
                  (proposal) =>
                      proposal.status == RewardWishlistStatus.accepted ||
                      proposal.status == RewardWishlistStatus.readyToRedeem ||
                      proposal.status ==
                          RewardWishlistStatus.redemptionRequested ||
                      proposal.status == RewardWishlistStatus.completed,
                )
                .toList() ??
            [];

        goals.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );

        final highlightedGoalId = widget.highlightedGoalId?.trim();
        if (highlightedGoalId != null && highlightedGoalId.isNotEmpty) {
          final highlightedIndex = goals.indexWhere(
            (goal) => goal.id == highlightedGoalId,
          );
          if (highlightedIndex > 0) {
            goals.insert(0, goals.removeAt(highlightedIndex));
          }
        }

        return _RewardsScaffold(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RewardsIntro(),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RewardWishlistNegotiationScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(strings.wishlistRequests),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyDigitalRewardsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: const Text('My Digital Rewards'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TokenHistoryScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('Token History'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                strings.myGoals,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                strings.myGoalsDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (proposalSnapshot.connectionState == ConnectionState.waiting &&
                  !proposalSnapshot.hasData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (goals.isEmpty)
                _RewardsMessage(
                  icon: Icons.flag_outlined,
                  title: strings.noActiveGoals,
                  message: strings.noActiveGoalsDescription,
                )
              else
                ...goals.map(
                  (proposal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WishlistGoalCard(
                      proposal: proposal,
                      highlighted: proposal.id == highlightedGoalId,
                      tokens: tokens,
                      dailyWins: dailyWins,
                      weeklyWins: weeklyWins,
                      monthlyWins: monthlyWins,
                      missionsCompleted: missionsCompleted,
                      onRedeem: () async {
                        try {
                          await _service.requestWishlistRedemption(
                            familyId: familyId,
                            proposalId: proposal.id,
                            requesterId: userId,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                strings.redemptionRequestSent(
                                  proposal.recipientName,
                                ),
                              ),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_messageFromError(error))),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 34),
              _DigitalRewardsStore(
                catalog: _catalog,
                userId: userId,
                tokens: tokens,
                processingRewardId: _processingRewardId,
                onPurchase: (reward) => _purchaseDigitalReward(reward: reward),
                onEquip: _equipDigitalReward,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeveloperPreview() {
    return _RewardsScaffold(
      tokens: 1350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RewardsIntro(),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const MyDigitalRewardsScreen(developerPreview: true),
              ),
            ),
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('My Digital Rewards'),
          ),
          const SizedBox(height: 30),
          _DigitalRewardsStore(
            catalog: _catalog,
            developerPreview: true,
            tokens: 1350,
            processingRewardId: null,
            onPurchase: (_) async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Developer Preview is read-only.'),
                ),
              );
            },
            onEquip: (_) async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Developer Preview is read-only.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RewardsScaffold extends StatelessWidget {
  const _RewardsScaffold({required this.tokens, required this.child});

  final int tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.rewards)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 480 ? 20.0 : 32.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TokenBalanceCard(tokens: tokens),
                      const SizedBox(height: 28),
                      child,
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

class _TokenBalanceCard extends StatelessWidget {
  const _TokenBalanceCard({required this.tokens});

  final int tokens;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.stars_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.yourTokens,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$tokens',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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

class _RewardsIntro extends StatelessWidget {
  const _RewardsIntro();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.rewardsIntroTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          strings.rewardsIntroDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _WishlistGoalCard extends StatelessWidget {
  const _WishlistGoalCard({
    required this.proposal,
    required this.tokens,
    required this.dailyWins,
    required this.weeklyWins,
    required this.monthlyWins,
    required this.missionsCompleted,
    required this.onRedeem,
    this.highlighted = false,
  });

  final RewardWishlistProposal proposal;
  final int tokens;
  final int dailyWins;
  final int weeklyWins;
  final int monthlyWins;
  final int missionsCompleted;
  final Future<void> Function() onRedeem;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final requirements = <_WishlistGoalProgress>[];

    if (proposal.tokenRequirement > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: strings.tokensRequired,
          current: tokens,
          required: proposal.tokenRequirement,
        ),
      );
    }

    if (proposal.dailyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: strings.dailyChallengeWins,
          current: proposal.dailyProgress(dailyWins),
          required: proposal.dailyWinsRequired,
        ),
      );
    }

    if (proposal.weeklyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: strings.weeklyChampionshipWins,
          current: proposal.weeklyProgress(weeklyWins),
          required: proposal.weeklyWinsRequired,
        ),
      );
    }

    if (proposal.monthlyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: strings.monthlyCupWins,
          current: proposal.monthlyProgress(monthlyWins),
          required: proposal.monthlyWinsRequired,
        ),
      );
    }

    if (proposal.missionsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: strings.missionsCompleted,
          current: proposal.missionProgress(missionsCompleted),
          required: proposal.missionsRequired,
        ),
      );
    }

    final complete =
        requirements.isNotEmpty &&
        requirements.every(
          (requirement) => requirement.current >= requirement.required,
        );

    final canRedeem =
        complete &&
        (proposal.status == RewardWishlistStatus.accepted ||
            proposal.status == RewardWishlistStatus.readyToRedeem);
    final completedMilestones = requirements
        .where((requirement) => requirement.current >= requirement.required)
        .length;
    final statusLabel = switch (proposal.status) {
      RewardWishlistStatus.readyToRedeem => strings.goalReadyToRedeem,
      RewardWishlistStatus.redemptionRequested =>
        strings.goalAwaitingConfirmation,
      RewardWishlistStatus.completed => strings.goalFulfilled,
      _ => strings.goalInProgress,
    };

    return Card(
      color: highlighted
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      shape: highlighted
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    complete ? Icons.emoji_events_rounded : Icons.flag_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    proposal.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: 8),
            Text(strings.agreedWith(proposal.recipientName)),
            const SizedBox(height: 6),
            Text(
              strings.milestonesComplete(
                completedMilestones,
                requirements.length,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (highlighted) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.notifications_active_outlined),
                label: Text(strings.openedFromNotification),
              ),
            ],
            if (proposal.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(proposal.description),
            ],
            const SizedBox(height: 16),

            ...requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _WishlistGoalProgressRow(progress: requirement),
              ),
            ),

            if (complete) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_outlined),
                      const SizedBox(width: 10),
                      Expanded(child: Text(strings.allRequirementsCompleted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (canRedeem)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await onRedeem();
                  },
                  icon: const Icon(Icons.redeem_outlined),
                  label: Text(strings.redeemReward),
                ),
              ),

            if (proposal.status == RewardWishlistStatus.redemptionRequested)
              Text(strings.waitingForFulfillment),

            if (proposal.status == RewardWishlistStatus.completed)
              Text(
                strings.rewardCompleted,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

class _WishlistGoalProgress {
  const _WishlistGoalProgress({
    required this.label,
    required this.current,
    required this.required,
  });

  final String label;
  final int current;
  final int required;
}

class _WishlistGoalProgressRow extends StatelessWidget {
  const _WishlistGoalProgressRow({required this.progress});

  final _WishlistGoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final value = progress.required <= 0
        ? 1.0
        : (progress.current / progress.required).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                progress.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(strings.progressCount(progress.current, progress.required)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value),
      ],
    );
  }
}

typedef _DigitalRewardAction =
    Future<void> Function(DigitalRewardDefinition reward);

class _DigitalRewardsStore extends StatelessWidget {
  const _DigitalRewardsStore({
    required this.catalog,
    required this.tokens,
    required this.processingRewardId,
    required this.onPurchase,
    required this.onEquip,
    this.userId,
    this.developerPreview = false,
  });

  final Future<List<DigitalRewardDefinition>> catalog;
  final String? userId;
  final int tokens;
  final String? processingRewardId;
  final _DigitalRewardAction onPurchase;
  final _DigitalRewardAction onEquip;
  final bool developerPreview;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DigitalRewardDefinition>>(
      future: catalog,
      builder: (context, catalogSnapshot) {
        if (!catalogSnapshot.hasData && !catalogSnapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (catalogSnapshot.hasError) {
          return const _RewardsMessage(
            icon: Icons.error_outline_rounded,
            title: 'Digital Rewards could not be loaded',
            message: 'Please restart the app and try again.',
          );
        }

        final rewards = catalogSnapshot.data ?? const [];
        if (developerPreview) {
          return _DigitalRewardsCatalogView(
            rewards: rewards,
            tokens: tokens,
            ownedRewardIds: const {'frame_gold', 'badge_champion'},
            equippedRewardIds: const {'frame_gold'},
            processingRewardId: processingRewardId,
            onPurchase: onPurchase,
            onEquip: onEquip,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('ownedRewards')
              .snapshots(),
          builder: (context, ownedSnapshot) {
            if (!ownedSnapshot.hasData && !ownedSnapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (ownedSnapshot.hasError) {
              return const _RewardsMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Your collection could not be loaded',
                message: 'Check your connection and try again.',
              );
            }

            final documents = ownedSnapshot.data?.docs ?? const [];
            final owned = documents.map((document) => document.id).toSet();
            final equipped = documents
                .where((document) => document.data()['equipped'] == true)
                .map((document) => document.id)
                .toSet();

            return _DigitalRewardsCatalogView(
              rewards: rewards,
              tokens: tokens,
              ownedRewardIds: owned,
              equippedRewardIds: equipped,
              processingRewardId: processingRewardId,
              onPurchase: onPurchase,
              onEquip: onEquip,
            );
          },
        );
      },
    );
  }
}

class _DigitalRewardsCatalogView extends StatelessWidget {
  const _DigitalRewardsCatalogView({
    required this.rewards,
    required this.tokens,
    required this.ownedRewardIds,
    required this.equippedRewardIds,
    required this.processingRewardId,
    required this.onPurchase,
    required this.onEquip,
  });

  final List<DigitalRewardDefinition> rewards;
  final int tokens;
  final Set<String> ownedRewardIds;
  final Set<String> equippedRewardIds;
  final String? processingRewardId;
  final _DigitalRewardAction onPurchase;
  final _DigitalRewardAction onEquip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Digital Rewards',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Unlock permanent Sila cosmetics instantly. No approval needed.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        for (final category in DigitalRewardCategory.values) ...[
          _DigitalRewardCategoryHeader(category: category),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 700
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;
              final categoryRewards = rewards
                  .where((reward) => reward.category == category)
                  .toList();

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final reward in categoryRewards)
                    SizedBox(
                      width: cardWidth,
                      child: _DigitalRewardCard(
                        reward: reward,
                        tokens: tokens,
                        owned: ownedRewardIds.contains(reward.id),
                        equipped: equippedRewardIds.contains(reward.id),
                        processing: processingRewardId == reward.id,
                        anotherRewardProcessing:
                            processingRewardId != null &&
                            processingRewardId != reward.id,
                        onPurchase: () => onPurchase(reward),
                        onEquip: () => onEquip(reward),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ],
    );
  }
}

class _DigitalRewardCategoryHeader extends StatelessWidget {
  const _DigitalRewardCategoryHeader({required this.category});

  final DigitalRewardCategory category;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (category) {
      DigitalRewardCategory.profileFrame => (
        'Profile Frames',
        Icons.filter_frames_rounded,
      ),
      DigitalRewardCategory.profileBadge => (
        'Profile Badges',
        Icons.verified_rounded,
      ),
      DigitalRewardCategory.profileTheme => (
        'Profile Themes',
        Icons.palette_rounded,
      ),
      DigitalRewardCategory.celebrationEffect => (
        'Celebration Effects',
        Icons.celebration_rounded,
      ),
      DigitalRewardCategory.nameplate => ('Nameplates', Icons.badge_rounded),
      DigitalRewardCategory.mascotAccessory => (
        'Sila Wardrobe',
        Icons.smart_toy_rounded,
      ),
    };

    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _DigitalRewardCard extends StatelessWidget {
  const _DigitalRewardCard({
    required this.reward,
    required this.tokens,
    required this.owned,
    required this.equipped,
    required this.processing,
    required this.anotherRewardProcessing,
    required this.onPurchase,
    required this.onEquip,
  });

  final DigitalRewardDefinition reward;
  final int tokens;
  final bool owned;
  final bool equipped;
  final bool processing;
  final bool anotherRewardProcessing;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final canAfford = tokens >= reward.cost;
    final disabled = processing || anotherRewardProcessing || equipped;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: DigitalRewardPreview(reward: reward)),
            const SizedBox(height: 14),
            Text(
              reward.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(reward.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                Chip(
                  avatar: const Icon(Icons.stars_rounded, size: 18),
                  label: Text('${reward.cost} Tokens'),
                ),
                Chip(label: Text(reward.isLimited ? 'Limited' : 'Permanent')),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: ValueKey('digital-reward-action-${reward.id}'),
              onPressed: disabled || (!owned && !canAfford)
                  ? null
                  : owned
                  ? onEquip
                  : onPurchase,
              icon: processing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      equipped
                          ? Icons.check_circle_rounded
                          : owned
                          ? Icons.auto_awesome_rounded
                          : Icons.lock_open_rounded,
                    ),
              label: Text(
                processing
                    ? 'Updating…'
                    : equipped
                    ? 'Equipped'
                    : owned
                    ? 'Equip'
                    : !canAfford
                    ? 'Need ${reward.cost - tokens} more Tokens'
                    : 'Buy for ${reward.cost}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsMessage extends StatelessWidget {
  const _RewardsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
