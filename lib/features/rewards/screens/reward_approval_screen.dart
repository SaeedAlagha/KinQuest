import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/reward_request.dart';
import '../services/rewards_service.dart';

class RewardApprovalScreen extends StatefulWidget {
  const RewardApprovalScreen({super.key});

  @override
  State<RewardApprovalScreen> createState() => _RewardApprovalScreenState();
}

class _RewardApprovalScreenState extends State<RewardApprovalScreen> {
  final RewardsService _rewardsService = RewardsService();

  String? _processingRequestId;

  String _messageFromError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  Future<void> _approveRequest({
    required String familyId,
    required String requestId,
    required String approverId,
  }) async {
    if (_processingRequestId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve reward?'),
          content: const Text(
            'The required Tokens will be deducted from the requester immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingRequestId = requestId;
    });

    try {
      await _rewardsService.approveRewardRequest(
        familyId: familyId,
        requestId: requestId,
        approverId: approverId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reward request approved.')));
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

  Future<void> _declineRequest({
    required String familyId,
    required String requestId,
    required String approverId,
  }) async {
    if (_processingRequestId != null) return;

    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Decline reward?'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Optional note',
              hintText: 'Explain why the request was declined.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      noteController.dispose();
      return;
    }

    final note = noteController.text;
    noteController.dispose();

    setState(() {
      _processingRequestId = requestId;
    });

    try {
      await _rewardsService.declineRewardRequest(
        familyId: familyId,
        requestId: requestId,
        approverId: approverId,
        approverNote: note,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reward request declined.')));
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

            if (familySnapshot.hasError || !familySnapshot.hasData) {
              return const Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Text('Could not load family permissions.'),
                  ),
                ),
              );
            }

            final familyData = familySnapshot.data?.data();
            final ownerId = familyData?['ownerId']?.toString();

            final approverIds = List<String>.from(
              familyData?['rewardApproverIds'] ?? const <String>[],
            );

            final canApprove =
                user.uid == ownerId || approverIds.contains(user.uid);

            if (!canApprove) {
              return const Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'You do not have permission to approve reward requests.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }

            return _buildApprovalInbox(
              familyId: familyId,
              approverId: user.uid,
            );
          },
        );
      },
    );
  }

  Widget _buildApprovalInbox({
    required String familyId,
    required String approverId,
  }) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Approvals')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .collection('rewardRequests')
              .where('status', isEqualTo: RewardRequestStatus.pending.name)
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
                    'Could not load pending reward requests.',
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
                      Icon(Icons.inbox_outlined, size: 52),
                      SizedBox(height: 14),
                      Text(
                        'No pending requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'New family reward requests will appear here.',
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
                final isProcessing = _processingRequestId == request.id;

                return _RewardRequestCard(
                  request: request,
                  isProcessing: isProcessing,
                  onApprove: () => _approveRequest(
                    familyId: familyId,
                    requestId: request.id,
                    approverId: approverId,
                  ),
                  onDecline: () => _declineRequest(
                    familyId: familyId,
                    requestId: request.id,
                    approverId: approverId,
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

class _RewardRequestCard extends StatelessWidget {
  const _RewardRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onDecline,
  });

  final RewardRequest request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.redeem_rounded)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.rewardTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${request.tokenCost} Tokens'),
                    ],
                  ),
                ),
              ],
            ),
            if (request.requesterNote != null &&
                request.requesterNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Requester note',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(request.requesterNote!),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onDecline,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isProcessing ? null : onApprove,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(isProcessing ? 'Processing...' : 'Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
