import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/family_reward.dart';
import '../models/reward_wishlist_proposal.dart';
import '../services/rewards_service.dart';
import 'token_history_screen.dart';
import 'my_digital_rewards_screen.dart';
import 'reward_wishlist_negotiation_screen.dart';

class RewardsHubScreen extends StatefulWidget {
  const RewardsHubScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<RewardsHubScreen> createState() => _RewardsHubScreenState();
}

class _RewardsHubScreenState extends State<RewardsHubScreen> {
  RewardsService? _rewardsService;

  RewardsService get _service => _rewardsService ??= RewardsService();

  bool _isProcessing = false;

  Future<void> _purchaseDigitalReward({
    required String familyId,
    required String userId,
    required FamilyReward reward,
  }) async {
    if (_isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unlock reward?'),
          content: Text(
            'Spend ${reward.tokenCost} Tokens to permanently unlock '
            '"${reward.title}"?',
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
      _isProcessing = true;
    });

    try {
      await _service.purchaseDigitalReward(
        familyId: familyId,
        userId: userId,
        reward: reward,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${reward.title} unlocked!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
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

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No user is signed in.'))),
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
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('Could not load your Rewards account.'),
              ),
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
            child: const _RewardsMessage(
              icon: Icons.family_restroom_rounded,
              title: 'Join a family first',
              message:
                  'Join or create a family to use Wishlist goals and rewards.',
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('rewards')
          .snapshots(),
      builder: (context, rewardsSnapshot) {
        if (rewardsSnapshot.connectionState == ConnectionState.waiting &&
            !rewardsSnapshot.hasData) {
          return _RewardsScaffold(
            tokens: tokens,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (rewardsSnapshot.hasError) {
          return _RewardsScaffold(
            tokens: tokens,
            child: const _RewardsMessage(
              icon: Icons.error_outline_rounded,
              title: 'Rewards could not be loaded',
              message: 'Please try again in a moment.',
            ),
          );
        }

        final digitalRewards =
            rewardsSnapshot.data?.docs
                .map(FamilyReward.fromDocument)
                .where(
                  (reward) =>
                      reward.active && reward.type == FamilyRewardType.digital,
                )
                .toList() ??
            [];

        digitalRewards.sort((a, b) => a.tokenCost.compareTo(b.tokenCost));

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
                          proposal.status ==
                              RewardWishlistStatus.readyToRedeem ||
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
                            builder: (_) =>
                                const RewardWishlistNegotiationScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Wishlist Requests'),
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
                    'My Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Accepted Wishlist offers appear here and update as you make progress.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  if (proposalSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !proposalSnapshot.hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (goals.isEmpty)
                    const _RewardsMessage(
                      icon: Icons.flag_outlined,
                      title: 'No active goals',
                      message:
                          'Accept a Wishlist offer and your goal will appear here.',
                    )
                  else
                    ...goals.map(
                      (proposal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _WishlistGoalCard(
                          proposal: proposal,
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
                                    'Redemption request sent to ${proposal.recipientName}.',
                                  ),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_messageFromError(error)),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 34),

                  _RewardSection(
                    title: 'Digital Rewards',
                    subtitle:
                        'Unlock built-in KinQuest cosmetics and app rewards with Tokens.',
                    emptyMessage: 'There are no digital rewards available yet.',
                    rewards: digitalRewards,
                    tokens: tokens,
                    isProcessing: _isProcessing,
                    pendingRewardIds: const <String>{},
                    onPressed: (reward) => _purchaseDigitalReward(
                      familyId: familyId,
                      userId: userId,
                      reward: reward,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeveloperPreview() {
    const previewRewards = [
      FamilyReward(
        id: 'champion-frame',
        title: 'Champion Profile Frame',
        description: 'A permanent profile frame for competition champions.',
        tokenCost: 500,
        type: FamilyRewardType.digital,
        approvalRequired: false,
        availability: RewardAvailability.oneTime,
        active: true,
        createdBy: 'system',
      ),
    ];

    final digitalRewards = previewRewards
        .where((reward) => reward.type == FamilyRewardType.digital)
        .toList();

    return _RewardsScaffold(
      tokens: 1350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RewardsIntro(),
          const SizedBox(height: 30),

          _RewardSection(
            title: 'Digital Rewards',
            subtitle:
                'Unlock profile cosmetics and other permanent in-app rewards.',
            emptyMessage: '',
            rewards: digitalRewards,
            tokens: 1350,
            isProcessing: false,
            pendingRewardIds: const <String>{},
            onPressed: (_) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
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
                    'Your Tokens',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turn your progress into rewards',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Earn Tokens from competitions and family missions, then use them '
          'for family experiences or digital unlocks.',
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
  });

  final RewardWishlistProposal proposal;
  final int tokens;
  final int dailyWins;
  final int weeklyWins;
  final int monthlyWins;
  final int missionsCompleted;
  final Future<void> Function() onRedeem;

  @override
  Widget build(BuildContext context) {
    final requirements = <_WishlistGoalProgress>[];

    if (proposal.tokenRequirement > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: 'Tokens',
          current: tokens,
          required: proposal.tokenRequirement,
        ),
      );
    }

    if (proposal.dailyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: 'Daily Challenge wins',
          current: dailyWins,
          required: proposal.dailyWinsRequired,
        ),
      );
    }

    if (proposal.weeklyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: 'Weekly Championship wins',
          current: weeklyWins,
          required: proposal.weeklyWinsRequired,
        ),
      );
    }

    if (proposal.monthlyWinsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: 'Monthly Cup wins',
          current: monthlyWins,
          required: proposal.monthlyWinsRequired,
        ),
      );
    }

    if (proposal.missionsRequired > 0) {
      requirements.add(
        _WishlistGoalProgress(
          label: 'Missions completed',
          current: missionsCompleted,
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

    return Card(
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
              ],
            ),
            const SizedBox(height: 8),
            Text('Agreed with ${proposal.recipientName}'),
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
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.celebration_outlined),
                      SizedBox(width: 10),
                      Expanded(child: Text('All requirements completed!')),
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
                  label: const Text('Redeem Reward'),
                ),
              ),

            if (proposal.status == RewardWishlistStatus.redemptionRequested)
              const Text(
                'Waiting for the other family member to confirm fulfillment.',
              ),

            if (proposal.status == RewardWishlistStatus.completed)
              const Text(
                'Reward completed.',
                style: TextStyle(fontWeight: FontWeight.bold),
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
            Text('${progress.current} / ${progress.required}'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value),
      ],
    );
  }
}

class _RewardSection extends StatelessWidget {
  const _RewardSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.rewards,
    required this.tokens,
    required this.isProcessing,
    required this.onPressed,
    required this.pendingRewardIds,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<FamilyReward> rewards;
  final int tokens;
  final bool isProcessing;
  final Set<String> pendingRewardIds;
  final ValueChanged<FamilyReward> onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        if (rewards.isEmpty)
          _RewardsMessage(
            icon: Icons.redeem_outlined,
            title: 'Nothing here yet',
            message: emptyMessage,
          )
        else
          ...rewards.map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RewardCard(
                reward: reward,
                tokens: tokens,
                isProcessing: isProcessing,
                isPending: pendingRewardIds.contains(reward.id),
                onPressed: () => onPressed(reward),
              ),
            ),
          ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.tokens,
    required this.isProcessing,
    required this.onPressed,
    required this.isPending,
  });

  final FamilyReward reward;
  final int tokens;
  final bool isProcessing;
  final bool isPending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final canAfford = tokens >= reward.tokenCost;
    final isDigital = reward.type == FamilyRewardType.digital;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Icon(
                isDigital
                    ? Icons.workspace_premium_rounded
                    : Icons.family_restroom_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (reward.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(reward.description),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.stars_rounded, size: 18),
                        label: Text('${reward.tokenCost} Tokens'),
                      ),
                      if (reward.approvalRequired)
                        const Chip(label: Text('Approval required'))
                      else
                        const Chip(label: Text('Instant unlock')),
                      Chip(
                        label: Text(_availabilityLabel(reward.availability)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: canAfford && !isProcessing && !isPending
                        ? onPressed
                        : null,
                    icon: isPending
                        ? const Icon(Icons.schedule_rounded)
                        : isDigital
                        ? const Icon(Icons.lock_open_rounded)
                        : const Icon(Icons.redeem_rounded),
                    label: Text(
                      isPending
                          ? 'Pending'
                          : !canAfford
                          ? 'Need ${reward.tokenCost - tokens} more Tokens'
                          : isDigital
                          ? 'Unlock'
                          : 'Redeem',
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

  String _availabilityLabel(RewardAvailability availability) {
    switch (availability) {
      case RewardAvailability.unlimited:
        return 'Unlimited';
      case RewardAvailability.daily:
        return 'Once per day';
      case RewardAvailability.weekly:
        return 'Once per week';
      case RewardAvailability.monthly:
        return 'Once per month';
      case RewardAvailability.oneTime:
        return 'One time';
    }
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
