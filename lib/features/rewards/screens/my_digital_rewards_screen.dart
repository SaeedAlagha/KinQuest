import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/rewards_service.dart';

class MyDigitalRewardsScreen extends StatefulWidget {
  const MyDigitalRewardsScreen({super.key});

  @override
  State<MyDigitalRewardsScreen> createState() => _MyDigitalRewardsScreenState();
}

class _MyDigitalRewardsScreenState extends State<MyDigitalRewardsScreen> {
  final RewardsService _rewardsService = RewardsService();

  String? _processingRewardId;

  String _messageFromError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _equip({
    required String userId,
    required String rewardId,
  }) async {
    if (_processingRewardId != null) return;

    setState(() {
      _processingRewardId = rewardId;
    });

    try {
      await _rewardsService.equipDigitalReward(
        userId: userId,
        rewardId: rewardId,
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

  Future<void> _unequip({
    required String userId,
    required String rewardId,
  }) async {
    if (_processingRewardId != null) return;

    setState(() {
      _processingRewardId = rewardId;
    });

    try {
      await _rewardsService.unequipDigitalReward(
        userId: userId,
        rewardId: rewardId,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No user is signed in.'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Digital Rewards')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('ownedRewards')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Could not load your digital rewards.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final rewards = snapshot.data?.docs ?? [];

            rewards.sort((a, b) {
              final aTime = a.data()['purchasedAt'] as Timestamp?;
              final bTime = b.data()['purchasedAt'] as Timestamp?;

              return (bTime?.millisecondsSinceEpoch ?? 0).compareTo(
                aTime?.millisecondsSinceEpoch ?? 0,
              );
            });

            if (rewards.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium_outlined, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'No digital rewards yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Digital rewards you unlock will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: rewards.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final document = rewards[index];

                final data = document.data();

                final title = data['title']?.toString() ?? 'Digital Reward';

                final equipped = data['equipped'] as bool? ?? false;

                final processing = _processingRewardId == document.id;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            equipped
                                ? Icons.check_circle_rounded
                                : Icons.workspace_premium_rounded,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 4),

                              Text(equipped ? 'Currently equipped' : 'Owned'),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        FilledButton.tonal(
                          onPressed: processing
                              ? null
                              : () {
                                  if (equipped) {
                                    _unequip(
                                      userId: user.uid,
                                      rewardId: document.id,
                                    );
                                  } else {
                                    _equip(
                                      userId: user.uid,
                                      rewardId: document.id,
                                    );
                                  }
                                },
                          child: processing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(equipped ? 'Unequip' : 'Equip'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
