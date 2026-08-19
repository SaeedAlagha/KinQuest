import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/reward_request.dart';
import '../services/rewards_service.dart';

class MyRewardRequestsScreen extends StatefulWidget {
  const MyRewardRequestsScreen({super.key});

  @override
  State<MyRewardRequestsScreen> createState() => _MyRewardRequestsScreenState();
}

class _MyRewardRequestsScreenState extends State<MyRewardRequestsScreen> {
  final RewardsService _rewardsService = RewardsService();

  String? _processingRequestId;

  String _messageFromError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _cancelRequest({
    required String familyId,
    required String userId,
    required RewardRequest request,
  }) async {
    if (_processingRequestId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel request?'),
          content: Text('Cancel your request for "${request.rewardTitle}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Request'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingRequestId = request.id;
    });

    try {
      await _rewardsService.cancelRewardRequest(
        familyId: familyId,
        requestId: request.id,
        userId: userId,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _processingRequestId = null;
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

        if (userSnapshot.hasError) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: Text('Could not load your account.')),
            ),
          );
        }

        final userData = userSnapshot.data?.data();
        final familyId = userData?['familyId']?.toString().trim();

        if (familyId == null || familyId.isEmpty) {
          return const Scaffold(
            body: SafeArea(child: Center(child: Text('Join a family first.'))),
          );
        }

        return _buildRequests(familyId: familyId, userId: user.uid);
      },
    );
  }

  Widget _buildRequests({required String familyId, required String userId}) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reward Requests')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('rewardRequests')
              .where('userId', isEqualTo: userId)
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
                    'Could not load your reward requests.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final requests =
                snapshot.data?.docs.map(RewardRequest.fromDocument).toList() ??
                [];

            requests.sort((a, b) {
              final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
              final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;

              return bTime.compareTo(aTime);
            });

            if (requests.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_giftcard_outlined, size: 56),
                      SizedBox(height: 16),
                      Text(
                        'No reward requests yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Family rewards you request will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];

                return _MyRewardRequestCard(
                  request: request,
                  isProcessing: _processingRequestId == request.id,
                  onCancel: request.status == RewardRequestStatus.pending
                      ? () => _cancelRequest(
                          familyId: familyId,
                          userId: userId,
                          request: request,
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MyRewardRequestCard extends StatelessWidget {
  const _MyRewardRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onCancel,
  });

  final RewardRequest request;
  final bool isProcessing;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.rewardTitle.isEmpty
                        ? 'Family Reward'
                        : request.rewardTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${request.tokenCost} Tokens',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (request.createdAt != null) ...[
              const SizedBox(height: 8),
              Text('Requested ${_formatDate(request.createdAt!)}'),
            ],
            if (request.requesterNote != null &&
                request.requesterNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _NoteSection(title: 'Your note', note: request.requesterNote!),
            ],
            if (request.approverNote != null &&
                request.approverNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _NoteSection(title: 'Approver note', note: request.approverNote!),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: isProcessing ? null : onCancel,
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(isProcessing ? 'Cancelling...' : 'Cancel Request'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RewardRequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(_icon, size: 18), label: Text(_label));
  }

  String get _label {
    switch (status) {
      case RewardRequestStatus.pending:
        return 'Pending';
      case RewardRequestStatus.approved:
        return 'Approved';
      case RewardRequestStatus.declined:
        return 'Declined';
      case RewardRequestStatus.cancelled:
        return 'Cancelled';
      case RewardRequestStatus.completed:
        return 'Completed';
      case RewardRequestStatus.expired:
        return 'Expired';
    }
  }

  IconData get _icon {
    switch (status) {
      case RewardRequestStatus.pending:
        return Icons.schedule_rounded;
      case RewardRequestStatus.approved:
        return Icons.check_circle_outline_rounded;
      case RewardRequestStatus.declined:
        return Icons.highlight_off_rounded;
      case RewardRequestStatus.cancelled:
        return Icons.cancel_outlined;
      case RewardRequestStatus.completed:
        return Icons.task_alt_rounded;
      case RewardRequestStatus.expired:
        return Icons.timer_off_outlined;
    }
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(note),
        ],
      ),
    );
  }
}
