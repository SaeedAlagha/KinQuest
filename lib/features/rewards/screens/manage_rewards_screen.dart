import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/family_reward.dart';
import '../services/rewards_service.dart';
import 'reward_approvers_screen.dart';

class ManageRewardsScreen extends StatefulWidget {
  const ManageRewardsScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<ManageRewardsScreen> createState() => _ManageRewardsScreenState();
}

class _ManageRewardsScreenState extends State<ManageRewardsScreen> {
  final RewardsService _rewardsService = RewardsService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tokenCostController = TextEditingController();

  FamilyRewardType _type = FamilyRewardType.family;
  RewardAvailability _availability = RewardAvailability.unlimited;
  bool _approvalRequired = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tokenCostController.dispose();
    super.dispose();
  }

  Future<void> _createReward({
    required String familyId,
    required String userId,
  }) async {
    if (_isSaving) return;

    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) return;

    final tokenCost = int.tryParse(_tokenCostController.text.trim());

    if (tokenCost == null || tokenCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid Token cost.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _rewardsService.createFamilyReward(
        familyId: familyId,
        creatorId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        tokenCost: tokenCost,
        type: _type,
        approvalRequired: _type == FamilyRewardType.digital
            ? false
            : _approvalRequired,
        availability: _availability,
      );

      if (!mounted) return;

      _titleController.clear();
      _descriptionController.clear();
      _tokenCostController.clear();

      setState(() {
        _type = FamilyRewardType.family;
        _availability = RewardAvailability.unlimited;
        _approvalRequired = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward created successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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

  Future<void> _editReward({
    required String familyId,
    required String userId,
    required FamilyReward reward,
  }) async {
    final titleController = TextEditingController(text: reward.title);

    final descriptionController = TextEditingController(
      text: reward.description,
    );

    final costController = TextEditingController(
      text: reward.tokenCost.toString(),
    );

    var availability = reward.availability;
    var approvalRequired = reward.approvalRequired;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDigital = reward.type == FamilyRewardType.digital;

            return AlertDialog(
              title: const Text('Edit Reward'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Reward name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Token cost',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<RewardAvailability>(
                      initialValue: availability,
                      decoration: const InputDecoration(
                        labelText: 'Redemption limit',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: RewardAvailability.unlimited,
                          child: Text('Unlimited'),
                        ),
                        DropdownMenuItem(
                          value: RewardAvailability.daily,
                          child: Text('Once per day'),
                        ),
                        DropdownMenuItem(
                          value: RewardAvailability.weekly,
                          child: Text('Once per week'),
                        ),
                        DropdownMenuItem(
                          value: RewardAvailability.monthly,
                          child: Text('Once per month'),
                        ),
                        DropdownMenuItem(
                          value: RewardAvailability.oneTime,
                          child: Text('One time'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          availability = value;
                        });
                      },
                    ),

                    if (!isDigital) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Approval required'),
                        value: approvalRequired,
                        onChanged: (value) {
                          setDialogState(() {
                            approvalRequired = value;
                          });
                        },
                      ),
                    ],
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
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) {
      titleController.dispose();
      descriptionController.dispose();
      costController.dispose();
      return;
    }

    final tokenCost = int.tryParse(costController.text.trim());

    try {
      if (tokenCost == null || tokenCost <= 0) {
        throw Exception('Enter a valid Token cost.');
      }

      await _rewardsService.updateFamilyReward(
        familyId: familyId,
        rewardId: reward.id,
        userId: userId,
        title: titleController.text,
        description: descriptionController.text,
        tokenCost: tokenCost,
        availability: availability,
        approvalRequired: reward.type == FamilyRewardType.digital
            ? false
            : approvalRequired,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      titleController.dispose();
      descriptionController.dispose();
      costController.dispose();
    }
  }

  Future<void> _toggleRewardActive({
    required String familyId,
    required String userId,
    required FamilyReward reward,
  }) async {
    try {
      await _rewardsService.setRewardActive(
        familyId: familyId,
        rewardId: reward.id,
        userId: userId,
        active: !reward.active,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.developerPreview) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Manage Rewards is read-only in Developer Preview.'),
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No user is signed in.'))),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = userSnapshot.data?.data();
        final familyId = userData?['familyId']?.toString().trim();

        if (familyId == null || familyId.isEmpty) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('Join a family before managing rewards.'),
              ),
            ),
          );
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .get(),
          builder: (context, familySnapshot) {
            if (familySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final familyData = familySnapshot.data?.data();
            final ownerId = familyData?['ownerId']?.toString();

            if (ownerId != user.uid) {
              return const Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Only the Family Admin can create and manage rewards.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }

            return _buildAdminScreen(familyId: familyId, userId: user.uid);
          },
        );
      },
    );
  }

  Widget _buildAdminScreen({required String familyId, required String userId}) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rewards')),
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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RewardApproversScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: const Text('Manage Reward Approvers'),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildCreateForm(familyId: familyId, userId: userId),
                      const SizedBox(height: 30),
                      _buildExistingRewards(familyId, userId),
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

  Widget _buildIntroCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Build your family reward catalogue',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create family experiences, privileges, or digital unlocks '
            'that members can spend Tokens on.',
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm({required String familyId, required String userId}) {
    final isDigital = _type == FamilyRewardType.digital;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Reward',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reward name',
                  hintText: 'Example: Choose Dinner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reward name is required.';
                  }

                  if (value.trim().length < 3) {
                    return 'Use at least 3 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Explain what this reward gives the member.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tokenCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Token cost',
                  hintText: '300',
                  prefixIcon: Icon(Icons.stars_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');

                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid Token cost.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<FamilyRewardType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Reward type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: FamilyRewardType.family,
                    child: Text('Family Reward'),
                  ),
                  DropdownMenuItem(
                    value: FamilyRewardType.digital,
                    child: Text('Digital Reward'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _type = value;

                    if (_type == FamilyRewardType.digital) {
                      _approvalRequired = false;
                      _availability = RewardAvailability.oneTime;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RewardAvailability>(
                initialValue: _availability,
                decoration: const InputDecoration(
                  labelText: 'Redemption limit',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: RewardAvailability.unlimited,
                    child: Text('Unlimited'),
                  ),
                  DropdownMenuItem(
                    value: RewardAvailability.daily,
                    child: Text('Once per day'),
                  ),
                  DropdownMenuItem(
                    value: RewardAvailability.weekly,
                    child: Text('Once per week'),
                  ),
                  DropdownMenuItem(
                    value: RewardAvailability.monthly,
                    child: Text('Once per month'),
                  ),
                  DropdownMenuItem(
                    value: RewardAvailability.oneTime,
                    child: Text('One time'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _availability = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isDigital ? false : _approvalRequired,
                onChanged: isDigital
                    ? null
                    : (value) {
                        setState(() {
                          _approvalRequired = value;
                        });
                      },
                title: const Text('Approval required'),
                subtitle: Text(
                  isDigital
                      ? 'Digital rewards unlock instantly after purchase.'
                      : 'If enabled, Tokens are deducted only after an approver accepts the request.',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => _createReward(familyId: familyId, userId: userId),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(_isSaving ? 'Creating...' : 'Create Reward'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingRewards(String familyId, String userId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('rewards')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Text(
            'Could not load existing rewards.',
            textAlign: TextAlign.center,
          );
        }

        final rewards =
            snapshot.data?.docs.map(FamilyReward.fromDocument).toList() ?? [];

        rewards.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing Rewards',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (rewards.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text(
                    'No rewards have been created yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...rewards.map(
                (reward) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        reward.type == FamilyRewardType.digital
                            ? Icons.workspace_premium_rounded
                            : Icons.family_restroom_rounded,
                      ),
                    ),
                    title: Text(reward.title),
                    subtitle: Text(
                      '${reward.tokenCost} Tokens • '
                      '${reward.type == FamilyRewardType.digital ? 'Digital' : 'Family'} • '
                      '${reward.active ? 'Active' : 'Paused'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editReward(
                            familyId: familyId,
                            userId: userId,
                            reward: reward,
                          );
                        }

                        if (value == 'toggle') {
                          _toggleRewardActive(
                            familyId: familyId,
                            userId: userId,
                            reward: reward,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: ListTile(
                            leading: Icon(
                              reward.active
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                            ),
                            title: Text(
                              reward.active ? 'Pause Reward' : 'Resume Reward',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
