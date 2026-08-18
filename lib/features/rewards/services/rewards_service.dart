import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_reward.dart';
import '../models/reward_request.dart';

class RewardsService {
  RewardsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createFamilyReward({
    required String familyId,
    required String creatorId,
    required String title,
    required String description,
    required int tokenCost,
    required FamilyRewardType type,
    required bool approvalRequired,
    required RewardAvailability availability,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Reward title is required.');
    }

    if (tokenCost <= 0) {
      throw Exception('Reward cost must be greater than 0 Tokens.');
    }

    final familyRef = _firestore.collection('families').doc(familyId);
    final rewardRef = familyRef.collection('rewards').doc();

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      final familyData = familySnapshot.data()!;
      final ownerId = familyData['ownerId']?.toString();

      if (ownerId != creatorId) {
        throw Exception('Only the Family Admin can create rewards.');
      }

      transaction.set(rewardRef, {
        'title': trimmedTitle,
        'description': trimmedDescription,
        'tokenCost': tokenCost,
        'type': type.name,
        'approvalRequired': approvalRequired,
        'availability': availability.name,
        'active': true,
        'createdBy': creatorId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return rewardRef.id;
  }

  Future<String> createRewardRequest({
    required String familyId,
    required String userId,
    required FamilyReward reward,
    String? requesterNote,
  }) async {
    final familyRef = _firestore.collection('families').doc(familyId);
    final userRef = _firestore.collection('users').doc(userId);
    final rewardRef = familyRef.collection('rewards').doc(reward.id);
    final requestRef = familyRef.collection('rewardRequests').doc();

    final pendingLockRef = familyRef
        .collection('rewardRequestLocks')
        .doc('${userId}_${reward.id}');

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);
      final userSnapshot = await transaction.get(userRef);
      final rewardSnapshot = await transaction.get(rewardRef);
      final pendingLockSnapshot = await transaction.get(pendingLockRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      if (!userSnapshot.exists) {
        throw Exception('User not found.');
      }

      if (!rewardSnapshot.exists) {
        throw Exception('Reward not found.');
      }

      final familyData = familySnapshot.data()!;
      final userData = userSnapshot.data()!;
      final rewardData = rewardSnapshot.data()!;

      final userFamilyId = userData['familyId']?.toString();

      if (userFamilyId != familyId) {
        throw Exception('You are not part of this family.');
      }

      final familyMembers = List<String>.from(
        familyData['members'] ?? const <String>[],
      );

      if (!familyMembers.contains(userId)) {
        throw Exception('You are not a member of this family.');
      }

      final active = rewardData['active'] as bool? ?? true;

      if (!active) {
        throw Exception('This reward is not currently available.');
      }

      final type = rewardData['type']?.toString();

      if (type != FamilyRewardType.family.name) {
        throw Exception(
          'Only family rewards can use the approval request flow.',
        );
      }

      final approvalRequired = rewardData['approvalRequired'] as bool? ?? true;

      if (!approvalRequired) {
        throw Exception('This reward does not require approval.');
      }

      final rewardTitle = rewardData['title']?.toString().trim() ?? '';

      final tokenCost = (rewardData['tokenCost'] as num?)?.toInt() ?? 0;

      if (rewardTitle.isEmpty || tokenCost <= 0) {
        throw Exception('This reward is not configured correctly.');
      }

      final currentTokens = (userData['tokens'] as num?)?.toInt() ?? 0;

      if (currentTokens < tokenCost) {
        throw Exception('You do not have enough Tokens.');
      }

      if (pendingLockSnapshot.exists) {
        throw Exception('You already have a pending request for this reward.');
      }

      final availability =
          rewardData['availability']?.toString() ??
          RewardAvailability.unlimited.name;

      transaction.set(requestRef, {
        'familyId': familyId,
        'userId': userId,
        'rewardId': rewardRef.id,
        'rewardTitle': rewardTitle,
        'tokenCost': tokenCost,
        'availability': availability,
        'status': RewardRequestStatus.pending.name,
        'approverId': null,
        'requesterNote': requesterNote?.trim(),
        'approverNote': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'completedAt': null,
      });

      transaction.set(pendingLockRef, {
        'familyId': familyId,
        'userId': userId,
        'rewardId': rewardRef.id,
        'requestId': requestRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return requestRef.id;
  }

  Future<void> approveRewardRequest({
    required String familyId,
    required String requestId,
    required String approverId,
    String? approverNote,
  }) async {
    final familyRef = _firestore.collection('families').doc(familyId);
    final requestRef = familyRef.collection('rewardRequests').doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);
      final requestSnapshot = await transaction.get(requestRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      if (!requestSnapshot.exists) {
        throw Exception('Reward request not found.');
      }

      final familyData = familySnapshot.data()!;
      final requestData = requestSnapshot.data()!;

      final ownerId = familyData['ownerId']?.toString();

      final approverIds = List<String>.from(
        familyData['rewardApproverIds'] ?? const <String>[],
      );

      final canApprove =
          approverId == ownerId || approverIds.contains(approverId);

      if (!canApprove) {
        throw Exception('You are not allowed to approve this reward.');
      }

      final status = requestData['status']?.toString();

      if (status != RewardRequestStatus.pending.name) {
        throw Exception('This reward request is no longer pending.');
      }

      final userId = requestData['userId']?.toString() ?? '';
      final rewardId = requestData['rewardId']?.toString() ?? '';
      final requestedTitle = requestData['rewardTitle']?.toString() ?? '';
      final requestedTokenCost =
          (requestData['tokenCost'] as num?)?.toInt() ?? 0;

      if (userId == approverId) {
        throw Exception('You cannot approve your own reward request.');
      }

      if (userId.isEmpty || rewardId.isEmpty || requestedTokenCost <= 0) {
        throw Exception('Invalid reward request.');
      }

      final userRef = _firestore.collection('users').doc(userId);
      final rewardRef = familyRef.collection('rewards').doc(rewardId);

      final pendingLockRef = familyRef
          .collection('rewardRequestLocks')
          .doc('${userId}_$rewardId');

      final userSnapshot = await transaction.get(userRef);
      final rewardSnapshot = await transaction.get(rewardRef);

      if (!userSnapshot.exists) {
        throw Exception('Reward requester not found.');
      }

      if (!rewardSnapshot.exists) {
        throw Exception('This reward no longer exists.');
      }

      final userData = userSnapshot.data()!;
      final rewardData = rewardSnapshot.data()!;

      final userFamilyId = userData['familyId']?.toString();

      if (userFamilyId != familyId) {
        throw Exception('The requester is no longer in this family.');
      }

      final familyMembers = List<String>.from(
        familyData['members'] ?? const <String>[],
      );

      if (!familyMembers.contains(userId)) {
        throw Exception('The requester is no longer a family member.');
      }

      final active = rewardData['active'] as bool? ?? true;

      if (!active) {
        throw Exception('This reward is no longer available.');
      }

      final type = rewardData['type']?.toString();

      if (type != FamilyRewardType.family.name) {
        throw Exception('This is no longer a family reward.');
      }

      final approvalRequired = rewardData['approvalRequired'] as bool? ?? true;

      if (!approvalRequired) {
        throw Exception('This reward no longer requires approval.');
      }

      final rewardTitle = rewardData['title']?.toString().trim() ?? '';

      final tokenCost = (rewardData['tokenCost'] as num?)?.toInt() ?? 0;

      final availability =
          rewardData['availability']?.toString() ??
          RewardAvailability.unlimited.name;

      if (rewardTitle.isEmpty || tokenCost <= 0) {
        throw Exception('This reward is not configured correctly.');
      }

      if (rewardTitle != requestedTitle || tokenCost != requestedTokenCost) {
        throw Exception(
          'This reward changed after the request was submitted. '
          'Please decline or cancel it and submit a new request.',
        );
      }

      final currentTokens = (userData['tokens'] as num?)?.toInt() ?? 0;

      if (currentTokens < tokenCost) {
        throw Exception('The requester no longer has enough Tokens.');
      }

      final now = DateTime.now().toUtc();

      String twoDigits(int value) => value.toString().padLeft(2, '0');

      final dayKey = '${now.year}${twoDigits(now.month)}${twoDigits(now.day)}';

      final weekStart = now.subtract(
        Duration(days: now.weekday - DateTime.monday),
      );

      final weekKey =
          '${weekStart.year}'
          '${twoDigits(weekStart.month)}'
          '${twoDigits(weekStart.day)}';

      final monthKey = '${now.year}${twoDigits(now.month)}';

      DocumentReference<Map<String, dynamic>>? redemptionLockRef;

      switch (availability) {
        case 'unlimited':
          redemptionLockRef = null;
          break;

        case 'daily':
          redemptionLockRef = familyRef
              .collection('rewardRedemptionLocks')
              .doc('${userId}_${rewardId}_daily_$dayKey');
          break;

        case 'weekly':
          redemptionLockRef = familyRef
              .collection('rewardRedemptionLocks')
              .doc('${userId}_${rewardId}_weekly_$weekKey');
          break;

        case 'monthly':
          redemptionLockRef = familyRef
              .collection('rewardRedemptionLocks')
              .doc('${userId}_${rewardId}_monthly_$monthKey');
          break;

        case 'oneTime':
          redemptionLockRef = familyRef
              .collection('rewardRedemptionLocks')
              .doc('${userId}_${rewardId}_oneTime');
          break;

        default:
          throw Exception('Invalid reward availability setting.');
      }

      if (redemptionLockRef != null) {
        final redemptionSnapshot = await transaction.get(redemptionLockRef);

        if (redemptionSnapshot.exists) {
          switch (availability) {
            case 'daily':
              throw Exception('This reward has already been redeemed today.');

            case 'weekly':
              throw Exception(
                'This reward has already been redeemed this week.',
              );

            case 'monthly':
              throw Exception(
                'This reward has already been redeemed this month.',
              );

            case 'oneTime':
              throw Exception(
                'This one-time reward has already been redeemed.',
              );
          }
        }
      }

      final tokenTransactionRef = userRef.collection('tokenTransactions').doc();

      transaction.update(userRef, {
        'tokens': FieldValue.increment(-tokenCost),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(requestRef, {
        'status': RewardRequestStatus.declined.name,
        'approverId': approverId,
        'approverNote': approverNote?.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.delete(pendingLockRef);

      transaction.set(tokenTransactionRef, {
        'userId': userId,
        'familyId': familyId,
        'amount': -tokenCost,
        'type': 'spent',
        'reason': rewardTitle,
        'relatedRewardId': rewardId,
        'relatedRequestId': requestId,
        'relatedCompetitionId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (redemptionLockRef != null) {
        transaction.set(redemptionLockRef, {
          'familyId': familyId,
          'userId': userId,
          'rewardId': rewardId,
          'requestId': requestId,
          'availability': availability,
          'redeemedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.delete(pendingLockRef);
    });
  }

  Future<void> completeRewardRequest({
    required String familyId,
    required String requestId,
    required String approverId,
  }) async {
    final familyRef = FirebaseFirestore.instance
        .collection('families')
        .doc(familyId);

    final requestRef = familyRef.collection('rewardRequests').doc(requestId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      final familyData = familySnapshot.data()!;

      final ownerId = familyData['ownerId']?.toString();

      final approverIds = List<String>.from(
        familyData['rewardApproverIds'] ?? const <String>[],
      );

      final canApprove =
          approverId == ownerId || approverIds.contains(approverId);

      if (!canApprove) {
        throw Exception('You do not have permission to complete this reward.');
      }

      final requestSnapshot = await transaction.get(requestRef);

      if (!requestSnapshot.exists) {
        throw Exception('Reward request not found.');
      }

      final requestData = requestSnapshot.data()!;

      final status = requestData['status']?.toString();

      if (status != RewardRequestStatus.approved.name) {
        throw Exception('Only approved rewards can be marked completed.');
      }

      transaction.update(requestRef, {
        'status': RewardRequestStatus.completed.name,
        'completedBy': approverId,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> declineRewardRequest({
    required String familyId,
    required String requestId,
    required String approverId,
    String? approverNote,
  }) async {
    final familyRef = _firestore.collection('families').doc(familyId);
    final requestRef = familyRef.collection('rewardRequests').doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);
      final requestSnapshot = await transaction.get(requestRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      if (!requestSnapshot.exists) {
        throw Exception('Reward request not found.');
      }

      final familyData = familySnapshot.data()!;
      final requestData = requestSnapshot.data()!;
      final userId = requestData['userId']?.toString() ?? '';
      final rewardId = requestData['rewardId']?.toString() ?? '';

      if (userId.isEmpty || rewardId.isEmpty) {
        throw Exception('Invalid reward request.');
      }

      final pendingLockRef = familyRef
          .collection('rewardRequestLocks')
          .doc('${userId}_$rewardId');
      final ownerId = familyData['ownerId']?.toString();

      final approverIds = List<String>.from(
        familyData['rewardApproverIds'] ?? const <String>[],
      );

      final canApprove =
          approverId == ownerId || approverIds.contains(approverId);

      if (!canApprove) {
        throw Exception('You are not allowed to decline this reward.');
      }

      if (requestData['status']?.toString() !=
          RewardRequestStatus.pending.name) {
        throw Exception('This reward request is no longer pending.');
      }

      transaction.update(requestRef, {
        'status': RewardRequestStatus.declined.name,
        'approverId': approverId,
        'approverNote': approverNote?.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.delete(pendingLockRef);
    });
  }

  Future<void> cancelRewardRequest({
    required String familyId,
    required String requestId,
    required String userId,
  }) async {
    final requestRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardRequests')
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(requestRef);

      if (!snapshot.exists) {
        throw Exception('Reward request not found.');
      }

      final data = snapshot.data()!;
      final rewardId = data['rewardId']?.toString() ?? '';

      if (rewardId.isEmpty) {
        throw Exception('Invalid reward request.');
      }

      final pendingLockRef = _firestore
          .collection('families')
          .doc(familyId)
          .collection('rewardRequestLocks')
          .doc('${userId}_$rewardId');
      if (data['userId']?.toString() != userId) {
        throw Exception('You cannot cancel another member\'s request.');
      }

      if (data['status']?.toString() != RewardRequestStatus.pending.name) {
        throw Exception('Only pending requests can be cancelled.');
      }

      transaction.update(requestRef, {
        'status': RewardRequestStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.delete(pendingLockRef);
    });
  }

  Future<void> purchaseDigitalReward({
    required String familyId,
    required String userId,
    required FamilyReward reward,
  }) async {
    final familyRef = _firestore.collection('families').doc(familyId);
    final userRef = _firestore.collection('users').doc(userId);
    final rewardRef = familyRef.collection('rewards').doc(reward.id);
    final ownedRewardRef = userRef.collection('ownedRewards').doc(reward.id);
    final transactionRef = userRef.collection('tokenTransactions').doc();

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);
      final userSnapshot = await transaction.get(userRef);
      final rewardSnapshot = await transaction.get(rewardRef);
      final ownedRewardSnapshot = await transaction.get(ownedRewardRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      if (!userSnapshot.exists) {
        throw Exception('User not found.');
      }

      if (!rewardSnapshot.exists) {
        throw Exception('Reward not found.');
      }

      final familyData = familySnapshot.data()!;
      final userData = userSnapshot.data()!;
      final rewardData = rewardSnapshot.data()!;

      final userFamilyId = userData['familyId']?.toString();

      if (userFamilyId != familyId) {
        throw Exception('You are not part of this family.');
      }

      final familyMembers = List<String>.from(
        familyData['members'] ?? const <String>[],
      );

      if (!familyMembers.contains(userId)) {
        throw Exception('You are not a member of this family.');
      }

      final active = rewardData['active'] as bool? ?? true;

      if (!active) {
        throw Exception('This reward is not currently available.');
      }

      final type = rewardData['type']?.toString();

      if (type != FamilyRewardType.digital.name) {
        throw Exception('Only digital rewards can be purchased instantly.');
      }

      final approvalRequired = rewardData['approvalRequired'] as bool? ?? true;

      if (approvalRequired) {
        throw Exception('This digital reward requires approval.');
      }

      final rewardTitle = rewardData['title']?.toString().trim() ?? '';
      final tokenCost = (rewardData['tokenCost'] as num?)?.toInt() ?? 0;

      if (rewardTitle.isEmpty || tokenCost <= 0) {
        throw Exception('This reward is not configured correctly.');
      }

      if (ownedRewardSnapshot.exists) {
        throw Exception('You already own this digital reward.');
      }

      final currentTokens = (userData['tokens'] as num?)?.toInt() ?? 0;

      if (currentTokens < tokenCost) {
        throw Exception('You do not have enough Tokens.');
      }

      transaction.update(userRef, {
        'tokens': FieldValue.increment(-tokenCost),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(ownedRewardRef, {
        'rewardId': rewardRef.id,
        'title': rewardTitle,
        'type': FamilyRewardType.digital.name,
        'tokenCost': tokenCost,
        'purchasedAt': FieldValue.serverTimestamp(),
        'equipped': false,
      });

      transaction.set(transactionRef, {
        'userId': userId,
        'familyId': familyId,
        'amount': -tokenCost,
        'type': 'spent',
        'reason': rewardTitle,
        'relatedRewardId': rewardRef.id,
        'relatedRequestId': null,
        'relatedCompetitionId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateFamilyReward({
    required String familyId,
    required String rewardId,
    required String userId,
    required String title,
    required String description,
    required int tokenCost,
    required RewardAvailability availability,
    required bool approvalRequired,
  }) async {
    final familyRef = FirebaseFirestore.instance
        .collection('families')
        .doc(familyId);

    final rewardRef = familyRef.collection('rewards').doc(rewardId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      final familyData = familySnapshot.data()!;
      final ownerId = familyData['ownerId']?.toString();

      if (ownerId != userId) {
        throw Exception('Only the Family Admin can edit rewards.');
      }

      final rewardSnapshot = await transaction.get(rewardRef);

      if (!rewardSnapshot.exists) {
        throw Exception('Reward not found.');
      }

      if (title.trim().length < 3) {
        throw Exception('Reward name must be at least 3 characters.');
      }

      if (tokenCost <= 0) {
        throw Exception('Enter a valid Token cost.');
      }

      transaction.update(rewardRef, {
        'title': title.trim(),
        'description': description.trim(),
        'tokenCost': tokenCost,
        'availability': availability.name,
        'approvalRequired': approvalRequired,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> setRewardActive({
    required String familyId,
    required String rewardId,
    required String userId,
    required bool active,
  }) async {
    final familyRef = FirebaseFirestore.instance
        .collection('families')
        .doc(familyId);

    final rewardRef = familyRef.collection('rewards').doc(rewardId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      final ownerId = familySnapshot.data()?['ownerId']?.toString();

      if (ownerId != userId) {
        throw Exception('Only the Family Admin can manage rewards.');
      }

      final rewardSnapshot = await transaction.get(rewardRef);

      if (!rewardSnapshot.exists) {
        throw Exception('Reward not found.');
      }

      transaction.update(rewardRef, {
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> equipDigitalReward({
    required String userId,
    required String rewardId,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);

    final ownedRewardsRef = userRef.collection('ownedRewards');

    await _firestore.runTransaction((transaction) async {
      final selectedRewardRef = ownedRewardsRef.doc(rewardId);

      final selectedSnapshot = await transaction.get(selectedRewardRef);

      if (!selectedSnapshot.exists) {
        throw Exception('You do not own this digital reward.');
      }

      final allOwned = await ownedRewardsRef.get();

      for (final document in allOwned.docs) {
        transaction.update(document.reference, {
          'equipped': document.id == rewardId,
        });
      }

      transaction.update(userRef, {
        'equippedRewardId': rewardId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> unequipDigitalReward({
    required String userId,
    required String rewardId,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);

    final rewardRef = userRef.collection('ownedRewards').doc(rewardId);

    await _firestore.runTransaction((transaction) async {
      final rewardSnapshot = await transaction.get(rewardRef);

      if (!rewardSnapshot.exists) {
        throw Exception('You do not own this digital reward.');
      }

      transaction.update(rewardRef, {'equipped': false});

      transaction.update(userRef, {
        'equippedRewardId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
