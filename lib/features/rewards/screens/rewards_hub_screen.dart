import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/family_reward.dart';
import '../services/rewards_service.dart';
import 'manage_rewards_screen.dart';
import 'reward_approval_screen.dart';
import 'token_history_screen.dart';
import 'my_reward_requests_screen.dart';
import 'my_digital_rewards_screen.dart';
import 'reward_wishlist_screen.dart';

class RewardsHubScreen extends StatefulWidget {
  const RewardsHubScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<RewardsHubScreen> createState() => _RewardsHubScreenState();
}

class _RewardsHubScreenState extends State<RewardsHubScreen> {
  final RewardsService _rewardsService = RewardsService();

  bool _isProcessing = false;

  Future<void> _requestFamilyReward({
    required String familyId,
    required String userId,
    required FamilyReward reward,
  }) async {
    if (_isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request reward?'),
          content: Text(
            'Request "${reward.title}" for ${reward.tokenCost} Tokens?\n\n'
            'Your Tokens will only be deducted if the request is approved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Request'),
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
      await _rewardsService.createRewardRequest(
        familyId: familyId,
        userId: userId,
        reward: reward,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reward request sent. Tokens will be deducted after approval.',
          ),
        ),
      );
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
      await _rewardsService.purchaseDigitalReward(
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

        if (familyId == null || familyId.isEmpty) {
          return _RewardsScaffold(
            tokens: tokens,
            child: const _RewardsMessage(
              icon: Icons.family_restroom_rounded,
              title: 'Join a family first',
              message:
                  'Family Rewards become available after you create or join a family.',
            ),
          );
        }

        return _buildRealRewards(
          familyId: familyId,
          userId: user.uid,
          tokens: tokens,
        );
      },
    );
  }

  Widget _buildRealRewards({
    required String familyId,
    required String userId,
    required int tokens,
  }) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .get(),
      builder: (context, familySnapshot) {
        final familyData = familySnapshot.data?.data();
        final ownerId = familyData?['ownerId']?.toString();

        final approverIds = List<String>.from(
          familyData?['rewardApproverIds'] ?? const <String>[],
        );

        final isFamilyAdmin = ownerId == userId;
        final canApproveRewards = isFamilyAdmin || approverIds.contains(userId);
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

            final rewards =
                rewardsSnapshot.data?.docs
                    .map(FamilyReward.fromDocument)
                    .where((reward) => reward.active)
                    .toList() ??
                [];

            final familyRewards = rewards
                .where((reward) => reward.type == FamilyRewardType.family)
                .toList();

            final digitalRewards = rewards
                .where((reward) => reward.type == FamilyRewardType.digital)
                .toList();

            familyRewards.sort((a, b) => a.tokenCost.compareTo(b.tokenCost));

            digitalRewards.sort((a, b) => a.tokenCost.compareTo(b.tokenCost));

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
                            builder: (_) => const MyRewardRequestsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.card_giftcard_outlined),
                        label: const Text('My Requests'),
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
                            builder: (_) => const RewardWishlistScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Wishlist'),
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

                      if (isFamilyAdmin)
                        FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageRewardsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_rounded),
                          label: const Text('Manage Rewards'),
                        ),

                      if (canApproveRewards)
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RewardApprovalScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.fact_check_rounded),
                          label: const Text('Reward Approvals'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _RewardSection(
                    title: 'Family Rewards',
                    subtitle:
                        'Use Tokens for family experiences and privileges. Approval may be required.',
                    emptyMessage:
                        'Your family has not created any family rewards yet.',
                    rewards: familyRewards,
                    tokens: tokens,
                    isProcessing: _isProcessing,
                    onPressed: (reward) => _requestFamilyReward(
                      familyId: familyId,
                      userId: userId,
                      reward: reward,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _RewardSection(
                    title: 'Digital Rewards',
                    subtitle:
                        'Unlock profile cosmetics and other permanent in-app rewards.',
                    emptyMessage: 'There are no digital rewards available yet.',
                    rewards: digitalRewards,
                    tokens: tokens,
                    isProcessing: _isProcessing,
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
        id: 'movie-night',
        title: 'Choose Movie Night',
        description: 'Pick the movie for the next family movie night.',
        tokenCost: 250,
        type: FamilyRewardType.family,
        approvalRequired: true,
        availability: RewardAvailability.weekly,
        active: true,
        createdBy: 'preview-owner',
      ),
      FamilyReward(
        id: 'choose-dinner',
        title: 'Choose Dinner',
        description: 'Choose what the family has for dinner.',
        tokenCost: 350,
        type: FamilyRewardType.family,
        approvalRequired: true,
        availability: RewardAvailability.weekly,
        active: true,
        createdBy: 'preview-owner',
      ),
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

    final familyRewards = previewRewards
        .where((reward) => reward.type == FamilyRewardType.family)
        .toList();

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
            title: 'Family Rewards',
            subtitle:
                'Use Tokens for family experiences and privileges. Approval may be required.',
            emptyMessage: '',
            rewards: familyRewards,
            tokens: 1350,
            isProcessing: false,
            onPressed: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Developer Preview is read-only.'),
                ),
              );
            },
          ),
          const SizedBox(height: 34),
          _RewardSection(
            title: 'Digital Rewards',
            subtitle:
                'Unlock profile cosmetics and other permanent in-app rewards.',
            emptyMessage: '',
            rewards: digitalRewards,
            tokens: 1350,
            isProcessing: false,
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

class _RewardSection extends StatelessWidget {
  const _RewardSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.rewards,
    required this.tokens,
    required this.isProcessing,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<FamilyReward> rewards;
  final int tokens;
  final bool isProcessing;
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
  });

  final FamilyReward reward;
  final int tokens;
  final bool isProcessing;
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
                  FilledButton(
                    onPressed: canAfford && !isProcessing ? onPressed : null,
                    child: Text(
                      !canAfford
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
