import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/reward_wishlist_proposal.dart';
import '../services/rewards_service.dart';

class RewardWishlistNegotiationScreen extends StatefulWidget {
  const RewardWishlistNegotiationScreen({
    super.key,
    this.familyId,
    this.proposalId,
  });

  final String? familyId;
  final String? proposalId;

  @override
  State<RewardWishlistNegotiationScreen> createState() =>
      _RewardWishlistNegotiationScreenState();
}

class _RewardWishlistNegotiationScreenState
    extends State<RewardWishlistNegotiationScreen> {
  final RewardsService _rewardsService = RewardsService();

  String? _familyId;
  String? _currentUserName;

  bool _loading = true;
  int _initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();

    final name = data?['name']?.toString().trim();
    final email = data?['email']?.toString().trim();

    final storedFamilyId = data?['familyId']?.toString().trim();
    final notificationFamilyId = widget.familyId?.trim();

    final resolvedFamilyId =
        notificationFamilyId != null && notificationFamilyId.isNotEmpty
        ? notificationFamilyId
        : storedFamilyId;

    var initialTabIndex = 0;

    final proposalId = widget.proposalId?.trim();

    if (resolvedFamilyId != null &&
        resolvedFamilyId.isNotEmpty &&
        proposalId != null &&
        proposalId.isNotEmpty) {
      final proposalDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(resolvedFamilyId)
          .collection('rewardWishlistProposals')
          .doc(proposalId)
          .get();

      if (proposalDoc.exists) {
        final proposal = RewardWishlistProposal.fromDocument(proposalDoc);

        if (proposal.recipientId == user.uid) {
          initialTabIndex = 2;
        } else if (proposal.requesterId == user.uid) {
          if (proposal.status == RewardWishlistStatus.accepted ||
              proposal.status == RewardWishlistStatus.readyToRedeem ||
              proposal.status == RewardWishlistStatus.redemptionRequested ||
              proposal.status == RewardWishlistStatus.completed) {
            initialTabIndex = 3;
          } else {
            initialTabIndex = 1;
          }
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _familyId = resolvedFamilyId;
      _currentUserName = name != null && name.isNotEmpty
          ? name
          : email ?? 'Family Member';
      _initialTabIndex = initialTabIndex;
      _loading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null || familyId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: const Center(
          child: Text('Join a family to use Wishlist rewards.'),
        ),
      );
    }
    return DefaultTabController(
      length: 4,
      initialIndex: _initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wishlist'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'New Request'),
              Tab(icon: Icon(Icons.send_outlined), text: 'Sent'),
              Tab(icon: Icon(Icons.inbox_outlined), text: 'Received'),
              Tab(icon: Icon(Icons.flag_outlined), text: 'My Goals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewRequestTab(familyId: familyId, userId: user.uid),
            _buildSentTab(familyId: familyId, userId: user.uid),
            _buildReceivedTab(familyId: familyId, userId: user.uid),
            _buildGoalsTab(familyId: familyId, userId: user.uid),
          ],
        ),
      ),
    );
  }

  bool _matchesNotificationProposal(RewardWishlistProposal proposal) {
    final proposalId = widget.proposalId?.trim();

    if (proposalId == null || proposalId.isEmpty) {
      return true;
    }

    return proposal.id == proposalId;
  }

  Widget _buildNewRequestTab({
    required String familyId,
    required String userId,
  }) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .get(),
      builder: (context, familySnapshot) {
        if (!familySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!familySnapshot.data!.exists) {
          return const Center(child: Text('Family not found.'));
        }

        final familyData = familySnapshot.data!.data()!;

        final memberIds = List<String>.from(
          familyData['members'] ?? const <String>[],
        ).where((id) => id != userId).toList();

        if (memberIds.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'There are no other family members to request a reward from.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<List<_FamilyMember>>(
          future: _loadFamilyMembers(memberIds),
          builder: (context, membersSnapshot) {
            if (!membersSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return _NewWishlistRequestForm(
              members: membersSnapshot.data!,
              onSubmit:
                  ({
                    required recipientId,
                    required recipientName,
                    required title,
                    required description,
                  }) async {
                    try {
                      await _rewardsService.createWishlistProposal(
                        familyId: familyId,
                        requesterId: userId,
                        requesterName: _currentUserName ?? 'Family Member',
                        recipientId: recipientId,
                        recipientName: recipientName,
                        title: title,
                        description: description,
                      );

                      _showMessage('Wishlist request sent to $recipientName.');

                      return true;
                    } catch (error) {
                      _showMessage(
                        error.toString().replaceFirst('Exception: ', ''),
                      );

                      return false;
                    }
                  },
            );
          },
        );
      },
    );
  }

  Future<List<_FamilyMember>> _loadFamilyMembers(List<String> memberIds) async {
    final members = <_FamilyMember>[];

    for (final id in memberIds) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (!snapshot.exists) {
        continue;
      }

      final data = snapshot.data()!;

      final name = data['name']?.toString().trim();
      final email = data['email']?.toString().trim();

      members.add(
        _FamilyMember(
          id: id,
          name: name != null && name.isNotEmpty
              ? name
              : email ?? 'Family Member',
        ),
      );
    }

    members.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return members;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _proposalStream(String familyId) {
    return FirebaseFirestore.instance
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .snapshots();
  }

  Widget _buildSentTab({required String familyId, required String userId}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _proposalStream(familyId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final proposals = snapshot.data!.docs
            .map(RewardWishlistProposal.fromDocument)
            .where(
              (proposal) =>
                  proposal.requesterId == userId &&
                  _matchesNotificationProposal(proposal),
            )
            .toList();

        proposals.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );

        if (proposals.isEmpty) {
          return const _EmptyState(
            icon: Icons.send_outlined,
            title: 'No sent requests',
            message:
                'Wishlist requests you send to family members will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: proposals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final proposal = proposals[index];

            return _ProposalCard(
              proposal: proposal,
              personLabel: 'Requested from',
              personName: proposal.recipientName,
              showRequirements:
                  proposal.status != RewardWishlistStatus.requested,
              actions: proposal.status == RewardWishlistStatus.offered
                  ? [
                      FilledButton.icon(
                        onPressed: () async {
                          await _acceptOffer(familyId, proposal, userId);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _rejectOffer(familyId, proposal, userId);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ]
                  : const [],
            );
          },
        );
      },
    );
  }

  Widget _buildReceivedTab({required String familyId, required String userId}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _proposalStream(familyId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final proposals = snapshot.data!.docs
            .map(RewardWishlistProposal.fromDocument)
            .where(
              (proposal) =>
                  proposal.recipientId == userId &&
                  _matchesNotificationProposal(proposal),
            )
            .toList();

        proposals.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );

        if (proposals.isEmpty) {
          return const _EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No received requests',
            message:
                'When a family member requests a reward from you, it will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: proposals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final proposal = proposals[index];

            return _ProposalCard(
              proposal: proposal,
              personLabel: 'Requested by',
              personName: proposal.requesterName,
              showRequirements:
                  proposal.status != RewardWishlistStatus.requested,
              actions: proposal.status == RewardWishlistStatus.requested
                  ? [
                      FilledButton.icon(
                        onPressed: () {
                          _showOfferDialog(
                            familyId: familyId,
                            proposal: proposal,
                            recipientId: userId,
                          );
                        },
                        icon: const Icon(Icons.handshake_outlined),
                        label: const Text('Make Offer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _declineRequest(familyId, proposal, userId);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Decline'),
                      ),
                    ]
                  : proposal.status == RewardWishlistStatus.redemptionRequested
                  ? [
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await _rewardsService.fulfillWishlistRedemption(
                              familyId: familyId,
                              proposalId: proposal.id,
                              recipientId: userId,
                            );

                            _showMessage(
                              '${proposal.title} marked as fulfilled.',
                            );
                          } catch (error) {
                            _showMessage(
                              error.toString().replaceFirst('Exception: ', ''),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm Fulfillment'),
                      ),
                    ]
                  : const [],
            );
          },
        );
      },
    );
  }

  Widget _buildGoalsTab({required String familyId, required String userId}) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data?.data() ?? const <String, dynamic>{};

        final currentTokens = (userData['tokens'] as num?)?.toInt() ?? 0;
        final dailyWins = (userData['dailyWins'] as num?)?.toInt() ?? 0;
        final weeklyWins = (userData['weeklyWins'] as num?)?.toInt() ?? 0;
        final monthlyWins = (userData['monthlyWins'] as num?)?.toInt() ?? 0;
        final missionsCompleted =
            (userData['missionsCompleted'] as num?)?.toInt() ?? 0;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _proposalStream(familyId),
          builder: (context, proposalSnapshot) {
            if (!proposalSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final goals = proposalSnapshot.data!.docs
                .map(RewardWishlistProposal.fromDocument)
                .where(
                  (proposal) =>
                      proposal.requesterId == userId &&
                      _matchesNotificationProposal(proposal) &&
                      (proposal.status == RewardWishlistStatus.accepted ||
                          proposal.status ==
                              RewardWishlistStatus.readyToRedeem ||
                          proposal.status ==
                              RewardWishlistStatus.redemptionRequested ||
                          proposal.status == RewardWishlistStatus.completed),
                )
                .toList();

            if (goals.isEmpty) {
              return const _EmptyState(
                icon: Icons.flag_outlined,
                title: 'No active goals',
                message:
                    'When you accept a family member\'s reward offer, it becomes a goal here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final proposal = goals[index];

                return _GoalCard(
                  proposal: proposal,
                  currentTokens: currentTokens,
                  dailyWins: dailyWins,
                  weeklyWins: weeklyWins,
                  monthlyWins: monthlyWins,
                  missionsCompleted: missionsCompleted,
                  onRedeem: proposal.status == RewardWishlistStatus.accepted
                      ? () async {
                          try {
                            await _rewardsService.requestWishlistRedemption(
                              familyId: familyId,
                              proposalId: proposal.id,
                              requesterId: userId,
                            );

                            _showMessage(
                              'Redemption request sent to ${proposal.recipientName}.',
                            );
                          } catch (error) {
                            _showMessage(
                              error.toString().replaceFirst('Exception: ', ''),
                            );
                          }
                        }
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _acceptOffer(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    try {
      await _rewardsService.acceptWishlistOffer(
        familyId: familyId,
        proposalId: proposal.id,
        requesterId: userId,
      );

      _showMessage('${proposal.title} was added to My Goals.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _rejectOffer(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    try {
      await _rewardsService.rejectWishlistOffer(
        familyId: familyId,
        proposalId: proposal.id,
        requesterId: userId,
      );

      _showMessage('Offer rejected.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _declineRequest(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    try {
      await _rewardsService.declineWishlistProposal(
        familyId: familyId,
        proposalId: proposal.id,
        recipientId: userId,
      );

      _showMessage('Wishlist request declined.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _showOfferDialog({
    required String familyId,
    required RewardWishlistProposal proposal,
    required String recipientId,
  }) async {
    final tokenController = TextEditingController(text: '0');
    final dailyController = TextEditingController(text: '0');
    final weeklyController = TextEditingController(text: '0');
    final monthlyController = TextEditingController(text: '0');
    final missionsController = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Offer for ${proposal.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Set the requirements they must complete to earn this reward.',
                ),
                const SizedBox(height: 16),
                _numberField(
                  controller: tokenController,
                  label: 'Tokens required',
                  icon: Icons.toll_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: dailyController,
                  label: 'Daily Challenge wins',
                  icon: Icons.today_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: weeklyController,
                  label: 'Weekly Championship wins',
                  icon: Icons.emoji_events_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: monthlyController,
                  label: 'Monthly Cup wins',
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: missionsController,
                  label: 'Missions completed',
                  icon: Icons.task_alt_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Send Offer'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      tokenController.dispose();
      dailyController.dispose();
      weeklyController.dispose();
      monthlyController.dispose();
      missionsController.dispose();
      return;
    }

    final tokens = int.tryParse(tokenController.text.trim()) ?? 0;
    final daily = int.tryParse(dailyController.text.trim()) ?? 0;
    final weekly = int.tryParse(weeklyController.text.trim()) ?? 0;
    final monthly = int.tryParse(monthlyController.text.trim()) ?? 0;
    final missions = int.tryParse(missionsController.text.trim()) ?? 0;

    tokenController.dispose();
    dailyController.dispose();
    weeklyController.dispose();
    monthlyController.dispose();
    missionsController.dispose();

    if (tokens == 0 &&
        daily == 0 &&
        weekly == 0 &&
        monthly == 0 &&
        missions == 0) {
      _showMessage('Add at least one requirement to the offer.');
      return;
    }

    try {
      await _rewardsService.makeWishlistOffer(
        familyId: familyId,
        proposalId: proposal.id,
        recipientId: recipientId,
        tokenRequirement: tokens,
        dailyWinsRequired: daily,
        weeklyWinsRequired: weekly,
        monthlyWinsRequired: monthly,
        missionsRequired: missions,
      );

      _showMessage('Offer sent to ${proposal.requesterName}.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _NewWishlistRequestForm extends StatefulWidget {
  const _NewWishlistRequestForm({
    required this.members,
    required this.onSubmit,
  });

  final List<_FamilyMember> members;

  final Future<bool> Function({
    required String recipientId,
    required String recipientName,
    required String title,
    required String description,
  })
  onSubmit;

  @override
  State<_NewWishlistRequestForm> createState() =>
      _NewWishlistRequestFormState();
}

class _NewWishlistRequestFormState extends State<_NewWishlistRequestForm> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedMemberId;
  bool _sending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selectedId = _selectedMemberId;
    final title = _titleController.text.trim();

    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose who you want to request this reward from.'),
        ),
      );
      return;
    }

    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a reward with at least 3 characters.'),
        ),
      );
      return;
    }

    final selectedMember = widget.members.firstWhere(
      (member) => member.id == selectedId,
    );

    setState(() {
      _sending = true;
    });

    final success = await widget.onSubmit(
      recipientId: selectedMember.id,
      recipientName: selectedMember.name,
      title: title,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _sending = false;
    });

    if (success) {
      _titleController.clear();
      _descriptionController.clear();

      setState(() {
        _selectedMemberId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'What would you like to earn?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Choose a family member and ask them to make you an offer.'),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedMemberId,
          decoration: const InputDecoration(
            labelText: 'Request from',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          items: widget.members
              .map(
                (member) => DropdownMenuItem<String>(
                  value: member.id,
                  child: Text(member.name),
                ),
              )
              .toList(),
          onChanged: _sending
              ? null
              : (value) {
                  setState(() {
                    _selectedMemberId = value;
                  });
                },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          enabled: !_sending,
          decoration: const InputDecoration(
            labelText: 'Reward',
            hintText: 'Example: iPad',
            prefixIcon: Icon(Icons.card_giftcard_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          enabled: !_sending,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Message (optional)',
            hintText: 'Example: I would like to earn this as a long-term goal.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Sending...' : 'Send Request'),
        ),
      ],
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.personLabel,
    required this.personName,
    required this.showRequirements,
    required this.actions,
  });

  final RewardWishlistProposal proposal;
  final String personLabel;
  final String personName;
  final bool showRequirements;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.card_giftcard_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    proposal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),
            const SizedBox(height: 12),
            Text('$personLabel: $personName'),
            if (proposal.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(proposal.description),
            ],
            if (showRequirements) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 6),
              _RequirementsList(proposal: proposal),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequirementsList extends StatelessWidget {
  const _RequirementsList({required this.proposal});

  final RewardWishlistProposal proposal;

  @override
  Widget build(BuildContext context) {
    final items = <String>[];

    if (proposal.tokenRequirement > 0) {
      items.add('${proposal.tokenRequirement} Tokens');
    }

    if (proposal.dailyWinsRequired > 0) {
      items.add('${proposal.dailyWinsRequired} Daily Challenge wins');
    }

    if (proposal.weeklyWinsRequired > 0) {
      items.add('${proposal.weeklyWinsRequired} Weekly Championship wins');
    }

    if (proposal.monthlyWinsRequired > 0) {
      items.add('${proposal.monthlyWinsRequired} Monthly Cup wins');
    }

    if (proposal.missionsRequired > 0) {
      items.add('${proposal.missionsRequired} missions completed');
    }

    if (items.isEmpty) {
      return const Text('No requirements set.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requirements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.proposal,
    required this.currentTokens,
    required this.dailyWins,
    required this.weeklyWins,
    required this.monthlyWins,
    required this.missionsCompleted,
    this.onRedeem,
  });

  final RewardWishlistProposal proposal;

  final int currentTokens;
  final int dailyWins;
  final int weeklyWins;
  final int monthlyWins;
  final int missionsCompleted;
  final Future<void> Function()? onRedeem;
  @override
  Widget build(BuildContext context) {
    final requirements = <_GoalProgress>[];

    if (proposal.tokenRequirement > 0) {
      requirements.add(
        _GoalProgress(
          label: 'Tokens',
          current: currentTokens,
          required: proposal.tokenRequirement,
        ),
      );
    }

    if (proposal.dailyWinsRequired > 0) {
      requirements.add(
        _GoalProgress(
          label: 'Daily Challenge wins',
          current: dailyWins,
          required: proposal.dailyWinsRequired,
        ),
      );
    }

    if (proposal.weeklyWinsRequired > 0) {
      requirements.add(
        _GoalProgress(
          label: 'Weekly Championship wins',
          current: weeklyWins,
          required: proposal.weeklyWinsRequired,
        ),
      );
    }

    if (proposal.monthlyWinsRequired > 0) {
      requirements.add(
        _GoalProgress(
          label: 'Monthly Cup wins',
          current: monthlyWins,
          required: proposal.monthlyWinsRequired,
        ),
      );
    }

    if (proposal.missionsRequired > 0) {
      requirements.add(
        _GoalProgress(
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
                    complete ? Icons.emoji_events : Icons.flag_outlined,
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
            const SizedBox(height: 16),
            ...requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ProgressRow(progress: requirement),
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
              if (proposal.status == RewardWishlistStatus.accepted &&
                  onRedeem != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await onRedeem!();
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
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.progress});

  final _GoalProgress progress;

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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RewardWishlistStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label(status)),
      visualDensity: VisualDensity.compact,
    );
  }

  String _label(RewardWishlistStatus status) {
    switch (status) {
      case RewardWishlistStatus.requested:
        return 'Requested';
      case RewardWishlistStatus.offered:
        return 'Offer Made';
      case RewardWishlistStatus.accepted:
        return 'Active Goal';
      case RewardWishlistStatus.declined:
        return 'Declined';
      case RewardWishlistStatus.rejected:
        return 'Rejected';
      case RewardWishlistStatus.readyToRedeem:
        return 'Ready';
      case RewardWishlistStatus.redemptionRequested:
        return 'Redeeming';
      case RewardWishlistStatus.completed:
        return 'Completed';
      case RewardWishlistStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FamilyMember {
  const _FamilyMember({required this.id, required this.name});

  final String id;
  final String name;
}

class _GoalProgress {
  const _GoalProgress({
    required this.label,
    required this.current,
    required this.required,
  });

  final String label;
  final int current;
  final int required;
}
