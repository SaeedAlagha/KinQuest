import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../../mascot/widgets/sila_companion_callout.dart';
import '../models/reward_wishlist_proposal.dart';
import '../services/rewards_service.dart';
import 'rewards_hub_screen.dart';

enum WishlistSection { newRequest, sent, received }

class RewardWishlistNegotiationScreen extends StatefulWidget {
  const RewardWishlistNegotiationScreen({
    super.key,
    this.familyId,
    this.proposalId,
    this.initialSection,
  });

  final String? familyId;
  final String? proposalId;
  final WishlistSection? initialSection;

  @override
  State<RewardWishlistNegotiationScreen> createState() =>
      _RewardWishlistNegotiationScreenState();
}

class _RewardWishlistNegotiationScreenState
    extends State<RewardWishlistNegotiationScreen> {
  final RewardsService _rewardsService = RewardsService();

  String? _familyId;
  String? _currentUserName;
  String? _processingProposalId;

  bool _loading = true;
  bool _loadFailed = false;
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

    DocumentSnapshot<Map<String, dynamic>> userDoc;
    try {
      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
      return;
    }

    if (!mounted) return;

    final strings = AppLocalizations.of(context)!;

    final data = userDoc.data();

    final name = data?['name']?.toString().trim();
    final email = data?['email']?.toString().trim();

    final storedFamilyId = data?['familyId']?.toString().trim();
    final notificationFamilyId = widget.familyId?.trim();

    final resolvedFamilyId =
        notificationFamilyId != null && notificationFamilyId.isNotEmpty
        ? notificationFamilyId
        : storedFamilyId;

    var initialTabIndex = widget.initialSection?.index ?? 0;

    final proposalId = widget.proposalId?.trim();

    if (widget.initialSection == null &&
        resolvedFamilyId != null &&
        resolvedFamilyId.isNotEmpty &&
        proposalId != null &&
        proposalId.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> proposalDoc;
      try {
        proposalDoc = await FirebaseFirestore.instance
            .collection('families')
            .doc(resolvedFamilyId)
            .collection('rewardWishlistProposals')
            .doc(proposalId)
            .get();
      } catch (_) {
        if (mounted) {
          setState(() {
            _loading = false;
            _loadFailed = true;
          });
        }
        return;
      }

      if (proposalDoc.exists) {
        final proposal = RewardWishlistProposal.fromDocument(proposalDoc);

        if (proposal.recipientId == user.uid) {
          initialTabIndex = 2;
        } else if (proposal.requesterId == user.uid) {
          initialTabIndex = 1;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _familyId = resolvedFamilyId;
      _currentUserName = name != null && name.isNotEmpty
          ? name
          : email ?? strings.familyMemberFallback;
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

  String _messageFromError(Object error) {
    final strings = AppLocalizations.of(context)!;
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return strings.somethingWentWrong;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadFailed) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.wishlist)),
        body: _WishlistLoadError(
          onRetry: () {
            setState(() {
              _loading = true;
              _loadFailed = false;
            });
            _loadCurrentUser();
          },
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null || familyId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.wishlist)),
        body: Center(child: Text(strings.joinFamilyWishlist)),
      );
    }
    return DefaultTabController(
      length: 3,
      initialIndex: _initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.wishlist),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: const Icon(Icons.add_circle_outline),
                text: strings.newRequest,
              ),
              Tab(icon: const Icon(Icons.send_outlined), text: strings.sent),
              Tab(
                icon: const Icon(Icons.inbox_outlined),
                text: strings.received,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewRequestTab(familyId: familyId, userId: user.uid),
            _buildSentTab(familyId: familyId, userId: user.uid),
            _buildReceivedTab(familyId: familyId, userId: user.uid),
          ],
        ),
      ),
    );
  }

  bool _isNotificationProposal(RewardWishlistProposal proposal) {
    final proposalId = widget.proposalId?.trim();

    if (proposalId == null || proposalId.isEmpty) {
      return false;
    }

    return proposal.id == proposalId;
  }

  void _prioritizeNotificationProposal(List<RewardWishlistProposal> proposals) {
    final highlightedIndex = proposals.indexWhere(_isNotificationProposal);
    if (highlightedIndex > 0) {
      proposals.insert(0, proposals.removeAt(highlightedIndex));
    }
  }

  bool _isProcessing(RewardWishlistProposal proposal) =>
      _processingProposalId == proposal.id;

  void _startProcessing(RewardWishlistProposal proposal) {
    setState(() => _processingProposalId = proposal.id);
  }

  void _finishProcessing(RewardWishlistProposal proposal) {
    if (mounted && _processingProposalId == proposal.id) {
      setState(() => _processingProposalId = null);
    }
  }

  Widget _buildNewRequestTab({
    required String familyId,
    required String userId,
  }) {
    final strings = AppLocalizations.of(context)!;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .get(),
      builder: (context, familySnapshot) {
        if (familySnapshot.hasError) {
          return const _WishlistLoadError();
        }

        if (!familySnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!familySnapshot.data!.exists) {
          return Center(child: Text(strings.familyNotFound));
        }

        final familyData = familySnapshot.data!.data()!;

        final memberIds = List<String>.from(
          familyData['members'] ?? const <String>[],
        ).where((id) => id != userId).toList();

        if (memberIds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                strings.noOtherFamilyRewardMembers,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<List<_FamilyMember>>(
          future: _loadFamilyMembers(
            memberIds,
            fallbackName: strings.familyMemberFallback,
          ),
          builder: (context, membersSnapshot) {
            if (membersSnapshot.hasError) {
              return const _WishlistLoadError();
            }

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
                        requesterName:
                            _currentUserName ?? strings.familyMemberFallback,
                        recipientId: recipientId,
                        recipientName: recipientName,
                        title: title,
                        description: description,
                      );

                      _showMessage(strings.wishlistRequestSent(recipientName));

                      return true;
                    } catch (error) {
                      _showMessage(_messageFromError(error));

                      return false;
                    }
                  },
            );
          },
        );
      },
    );
  }

  Future<List<_FamilyMember>> _loadFamilyMembers(
    List<String> memberIds, {
    required String fallbackName,
  }) async {
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
          name: name != null && name.isNotEmpty ? name : email ?? fallbackName,
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
    final strings = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _proposalStream(familyId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _WishlistLoadError();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final proposals = snapshot.data!.docs
            .map(RewardWishlistProposal.fromDocument)
            .where((proposal) => proposal.requesterId == userId)
            .toList();

        proposals.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );
        _prioritizeNotificationProposal(proposals);

        if (proposals.isEmpty) {
          return _EmptyState(
            icon: Icons.send_outlined,
            title: strings.noSentRequests,
            message: strings.noSentRequestsDescription,
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
              highlighted: _isNotificationProposal(proposal),
              processing: _isProcessing(proposal),
              personLabel: strings.requestedFrom,
              personName: proposal.recipientName,
              showRequirements:
                  proposal.status != RewardWishlistStatus.requested,
              actions: proposal.status == RewardWishlistStatus.offered
                  ? [
                      FilledButton.icon(
                        onPressed: _isProcessing(proposal)
                            ? null
                            : () async {
                                await _acceptOffer(familyId, proposal, userId);
                              },
                        icon: const Icon(Icons.check),
                        label: Text(strings.accept),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessing(proposal)
                            ? null
                            : () async {
                                await _rejectOffer(familyId, proposal, userId);
                              },
                        icon: const Icon(Icons.close),
                        label: Text(strings.reject),
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
    final strings = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _proposalStream(familyId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _WishlistLoadError();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final proposals = snapshot.data!.docs
            .map(RewardWishlistProposal.fromDocument)
            .where((proposal) => proposal.recipientId == userId)
            .toList();

        proposals.sort(
          (a, b) => (b.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
            a.createdAt?.millisecondsSinceEpoch ?? 0,
          ),
        );
        _prioritizeNotificationProposal(proposals);

        if (proposals.isEmpty) {
          return _EmptyState(
            icon: Icons.inbox_outlined,
            title: strings.noReceivedRequests,
            message: strings.noReceivedRequestsDescription,
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
              highlighted: _isNotificationProposal(proposal),
              processing: _isProcessing(proposal),
              personLabel: strings.requestedBy,
              personName: proposal.requesterName,
              showRequirements:
                  proposal.status != RewardWishlistStatus.requested,
              actions: proposal.status == RewardWishlistStatus.requested
                  ? [
                      FilledButton.icon(
                        onPressed: _isProcessing(proposal)
                            ? null
                            : () {
                                _showOfferDialog(
                                  familyId: familyId,
                                  proposal: proposal,
                                  recipientId: userId,
                                );
                              },
                        icon: const Icon(Icons.handshake_outlined),
                        label: Text(strings.makeOffer),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isProcessing(proposal)
                            ? null
                            : () async {
                                await _declineRequest(
                                  familyId,
                                  proposal,
                                  userId,
                                );
                              },
                        icon: const Icon(Icons.close),
                        label: Text(strings.decline),
                      ),
                    ]
                  : proposal.status == RewardWishlistStatus.redemptionRequested
                  ? [
                      FilledButton.icon(
                        onPressed: _isProcessing(proposal)
                            ? null
                            : () => _fulfillRedemption(
                                familyId,
                                proposal,
                                userId,
                              ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(strings.confirmFulfillment),
                      ),
                    ]
                  : const [],
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
    final strings = AppLocalizations.of(context)!;
    _startProcessing(proposal);

    try {
      await _rewardsService.acceptWishlistOffer(
        familyId: familyId,
        proposalId: proposal.id,
        requesterId: userId,
      );

      _showMessage(strings.rewardAddedToGoals(proposal.title));

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RewardsHubScreen(highlightedGoalId: proposal.id),
        ),
      );
    } catch (error) {
      _showMessage(_messageFromError(error));
    } finally {
      _finishProcessing(proposal);
    }
  }

  Future<void> _rejectOffer(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    final strings = AppLocalizations.of(context)!;
    _startProcessing(proposal);

    try {
      await _rewardsService.rejectWishlistOffer(
        familyId: familyId,
        proposalId: proposal.id,
        requesterId: userId,
      );

      _showMessage(strings.offerRejected);
    } catch (error) {
      _showMessage(_messageFromError(error));
    } finally {
      _finishProcessing(proposal);
    }
  }

  Future<void> _declineRequest(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    final strings = AppLocalizations.of(context)!;
    _startProcessing(proposal);

    try {
      await _rewardsService.declineWishlistProposal(
        familyId: familyId,
        proposalId: proposal.id,
        recipientId: userId,
      );

      _showMessage(strings.wishlistRequestDeclined);
    } catch (error) {
      _showMessage(_messageFromError(error));
    } finally {
      _finishProcessing(proposal);
    }
  }

  Future<void> _fulfillRedemption(
    String familyId,
    RewardWishlistProposal proposal,
    String userId,
  ) async {
    final strings = AppLocalizations.of(context)!;
    _startProcessing(proposal);

    try {
      await _rewardsService.fulfillWishlistRedemption(
        familyId: familyId,
        proposalId: proposal.id,
        recipientId: userId,
      );
      _showMessage(strings.rewardMarkedFulfilled(proposal.title));
    } catch (error) {
      _showMessage(_messageFromError(error));
    } finally {
      _finishProcessing(proposal);
    }
  }

  Future<void> _showOfferDialog({
    required String familyId,
    required RewardWishlistProposal proposal,
    required String recipientId,
  }) async {
    final strings = AppLocalizations.of(context)!;
    final tokenController = TextEditingController(text: '0');
    final dailyController = TextEditingController(text: '0');
    final weeklyController = TextEditingController(text: '0');
    final monthlyController = TextEditingController(text: '0');
    final missionsController = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.offerForReward(proposal.title)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.offerRequirementsDescription),
                const SizedBox(height: 16),
                _numberField(
                  controller: tokenController,
                  label: strings.tokensRequired,
                  icon: Icons.toll_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: dailyController,
                  label: strings.dailyChallengeWins,
                  icon: Icons.today_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: weeklyController,
                  label: strings.weeklyChampionshipWins,
                  icon: Icons.emoji_events_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: monthlyController,
                  label: strings.monthlyCupWins,
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 10),
                _numberField(
                  controller: missionsController,
                  label: strings.missionsCompleted,
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
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(strings.sendOffer),
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
      _showMessage(strings.addOfferRequirement);
      return;
    }

    try {
      _startProcessing(proposal);
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

      _showMessage(strings.offerSentTo(proposal.requesterName));
    } catch (error) {
      _showMessage(_messageFromError(error));
    } finally {
      _finishProcessing(proposal);
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
    final strings = AppLocalizations.of(context)!;
    final selectedId = _selectedMemberId;
    final title = _titleController.text.trim();

    if (selectedId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.chooseRewardRecipient)));
      return;
    }

    if (title.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.rewardMinimumLength)));
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
    final strings = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          strings.whatWouldYouLikeToEarn,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(strings.chooseMemberForOffer),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedMemberId,
          decoration: InputDecoration(
            labelText: strings.requestFrom,
            prefixIcon: const Icon(Icons.person_outline),
            border: const OutlineInputBorder(),
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
          decoration: InputDecoration(
            labelText: strings.reward,
            hintText: strings.rewardExample,
            prefixIcon: const Icon(Icons.card_giftcard_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          enabled: !_sending,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: strings.optionalMessage,
            hintText: strings.wishlistMessageExample,
            border: const OutlineInputBorder(),
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
          label: Text(_sending ? strings.sending : strings.sendRequest),
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
    this.highlighted = false,
    this.processing = false,
  });

  final RewardWishlistProposal proposal;
  final String personLabel;
  final String personName;
  final bool showRequirements;
  final List<Widget> actions;
  final bool highlighted;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

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
            Text(strings.personLabel(personLabel, personName)),
            if (proposal.description.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(proposal.description),
            ],
            if (highlighted) ...[
              const SizedBox(height: 10),
              Chip(
                avatar: const Icon(Icons.notifications_active_outlined),
                label: Text(strings.openedFromNotification),
              ),
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
            if (processing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
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
    final strings = AppLocalizations.of(context)!;
    final items = <String>[];

    if (proposal.tokenRequirement > 0) {
      items.add(strings.requirementTokens(proposal.tokenRequirement));
    }

    if (proposal.dailyWinsRequired > 0) {
      items.add(strings.requirementDailyWins(proposal.dailyWinsRequired));
    }

    if (proposal.weeklyWinsRequired > 0) {
      items.add(strings.requirementWeeklyWins(proposal.weeklyWinsRequired));
    }

    if (proposal.monthlyWinsRequired > 0) {
      items.add(strings.requirementMonthlyWins(proposal.monthlyWinsRequired));
    }

    if (proposal.missionsRequired > 0) {
      items.add(strings.requirementMissions(proposal.missionsRequired));
    }

    if (items.isEmpty) {
      return Text(strings.noRequirementsSet);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.requirements,
          style: const TextStyle(fontWeight: FontWeight.bold),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RewardWishlistStatus status;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Chip(
      label: Text(_label(strings, status)),
      visualDensity: VisualDensity.compact,
    );
  }

  String _label(AppLocalizations strings, RewardWishlistStatus status) {
    switch (status) {
      case RewardWishlistStatus.requested:
        return strings.statusRequested;
      case RewardWishlistStatus.offered:
        return strings.statusOfferMade;
      case RewardWishlistStatus.accepted:
        return strings.statusActiveGoal;
      case RewardWishlistStatus.declined:
        return strings.statusDeclined;
      case RewardWishlistStatus.rejected:
        return strings.statusRejected;
      case RewardWishlistStatus.readyToRedeem:
        return strings.statusReady;
      case RewardWishlistStatus.redemptionRequested:
        return strings.statusRedeeming;
      case RewardWishlistStatus.completed:
        return strings.statusCompleted;
      case RewardWishlistStatus.cancelled:
        return strings.statusCancelled;
    }
  }
}

class _WishlistLoadError extends StatelessWidget {
  const _WishlistLoadError({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SilaCompanionCallout(
            key: const ValueKey('wishlist-sila-error'),
            userId: FirebaseAuth.instance.currentUser?.uid,
            title: strings.couldNotLoadWishlist,
            message: strings.tryAgain,
            pose: SilaMascotPose.oops,
            action: onRetry == null
                ? null
                : FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.tryAgain),
                  ),
          ),
        ),
      ),
    );
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SilaCompanionCallout(
            key: ValueKey('wishlist-sila-empty-${icon.codePoint}'),
            userId: FirebaseAuth.instance.currentUser?.uid,
            title: title,
            message: message,
            pose: SilaMascotPose.encouraging,
          ),
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
