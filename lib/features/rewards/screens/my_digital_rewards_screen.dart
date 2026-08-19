import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../digital/digital_reward_catalog.dart';
import '../digital/digital_reward_definition.dart';
import '../digital/digital_reward_service.dart';
import '../digital/digital_reward_visuals.dart';

class MyDigitalRewardsScreen extends StatefulWidget {
  const MyDigitalRewardsScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<MyDigitalRewardsScreen> createState() => _MyDigitalRewardsScreenState();
}

class _MyDigitalRewardsScreenState extends State<MyDigitalRewardsScreen> {
  final DigitalRewardService _digitalRewardService = DigitalRewardService();
  final Future<List<DigitalRewardDefinition>> _catalog =
      DigitalRewardCatalog.load();

  String? _processingRewardId;

  String _messageFromError(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _updateReward(
    DigitalRewardDefinition reward, {
    required bool unequip,
  }) async {
    if (_processingRewardId != null) return;

    setState(() => _processingRewardId = reward.id);
    try {
      if (unequip) {
        await _digitalRewardService.unequip(reward.id);
      } else {
        await _digitalRewardService.equip(reward.id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unequip
                ? '${reward.name} unequipped.'
                : '${reward.name} equipped across Sila.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) setState(() => _processingRewardId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.developerPreview
        ? null
        : FirebaseAuth.instance.currentUser?.uid;

    if (!widget.developerPreview && userId == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No user is signed in.'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Digital Rewards')),
      body: SafeArea(
        child: FutureBuilder<List<DigitalRewardDefinition>>(
          future: _catalog,
          builder: (context, catalogSnapshot) {
            if (!catalogSnapshot.hasData && !catalogSnapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }

            if (catalogSnapshot.hasError) {
              return const _CollectionMessage(
                icon: Icons.error_outline_rounded,
                title: 'Your collection could not be loaded',
                message: 'Please restart the app and try again.',
              );
            }

            final catalog = catalogSnapshot.data ?? const [];
            if (widget.developerPreview) {
              final previewOwned = <String, Map<String, dynamic>>{
                for (final reward in catalog.take(5))
                  reward.id: {
                    'equipped': reward.id == 'frame_gold',
                    'purchasedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
                  },
              };

              return _OwnedRewardsCollection(
                catalog: catalog,
                owned: previewOwned,
                processingRewardId: _processingRewardId,
                onUpdate: (_, {required unequip}) async {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Developer Preview is read-only.'),
                    ),
                  );
                },
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (ownedSnapshot.hasError) {
                  return const _CollectionMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Your collection could not be loaded',
                    message: 'Check your connection and try again.',
                  );
                }

                final owned = <String, Map<String, dynamic>>{
                  for (final document in ownedSnapshot.data?.docs ?? const [])
                    document.id: document.data(),
                };

                return _OwnedRewardsCollection(
                  catalog: catalog,
                  owned: owned,
                  processingRewardId: _processingRewardId,
                  onUpdate: _updateReward,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

typedef _OwnedRewardAction =
    Future<void> Function(
      DigitalRewardDefinition reward, {
      required bool unequip,
    });

class _OwnedRewardsCollection extends StatelessWidget {
  const _OwnedRewardsCollection({
    required this.catalog,
    required this.owned,
    required this.processingRewardId,
    required this.onUpdate,
  });

  final List<DigitalRewardDefinition> catalog;
  final Map<String, Map<String, dynamic>> owned;
  final String? processingRewardId;
  final _OwnedRewardAction onUpdate;

  @override
  Widget build(BuildContext context) {
    final knownRewards = catalog
        .where((reward) => owned.containsKey(reward.id))
        .toList();
    final unknownRewardCount = owned.length - knownRewards.length;

    if (owned.isEmpty) {
      return const _CollectionMessage(
        icon: Icons.workspace_premium_outlined,
        title: 'No digital rewards yet',
        message: 'Unlock cosmetics from Rewards and they will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your Sila style',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Equip one reward from each category. Changes appear everywhere immediately.',
                ),
                const SizedBox(height: 24),
                for (final category in DigitalRewardCategory.values)
                  if (knownRewards.any(
                    (reward) => reward.category == category,
                  )) ...[
                    Text(
                      _categoryLabel(category),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final reward in knownRewards.where(
                      (reward) => reward.category == category,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OwnedRewardCard(
                          reward: reward,
                          equipped: owned[reward.id]?['equipped'] == true,
                          processing: processingRewardId == reward.id,
                          anotherRewardProcessing:
                              processingRewardId != null &&
                              processingRewardId != reward.id,
                          onUpdate: onUpdate,
                        ),
                      ),
                    const SizedBox(height: 14),
                  ],
                if (unknownRewardCount > 0)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(
                        '$unknownRewardCount legacy reward${unknownRewardCount == 1 ? '' : 's'} kept safe',
                      ),
                      subtitle: const Text(
                        'These purchases remain owned but are no longer in the active catalog.',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnedRewardCard extends StatelessWidget {
  const _OwnedRewardCard({
    required this.reward,
    required this.equipped,
    required this.processing,
    required this.anotherRewardProcessing,
    required this.onUpdate,
  });

  final DigitalRewardDefinition reward;
  final bool equipped;
  final bool processing;
  final bool anotherRewardProcessing;
  final _OwnedRewardAction onUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            DigitalRewardPreview(reward: reward),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(equipped ? 'Currently equipped' : 'Owned permanently'),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    key: ValueKey('owned-reward-action-${reward.id}'),
                    onPressed: processing || anotherRewardProcessing
                        ? null
                        : () => onUpdate(reward, unequip: equipped),
                    icon: processing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            equipped
                                ? Icons.remove_circle_outline_rounded
                                : Icons.auto_awesome_rounded,
                          ),
                    label: Text(
                      processing
                          ? 'Updating…'
                          : equipped
                          ? 'Unequip'
                          : 'Equip',
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

class _CollectionMessage extends StatelessWidget {
  const _CollectionMessage({
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
            Icon(icon, size: 60),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
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

String _categoryLabel(DigitalRewardCategory category) {
  return switch (category) {
    DigitalRewardCategory.profileFrame => 'Profile Frames',
    DigitalRewardCategory.profileBadge => 'Profile Badges',
    DigitalRewardCategory.profileTheme => 'Profile Themes',
    DigitalRewardCategory.celebrationEffect => 'Celebration Effects',
    DigitalRewardCategory.nameplate => 'Nameplates',
  };
}
