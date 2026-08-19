import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_reward.dart';
import '../models/reward_wishlist_proposal.dart';

class RewardsService {
  RewardsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Future<String> createWishlistProposal({
    required String familyId,
    required String requesterId,
    required String requesterName,
    required String recipientId,
    required String recipientName,
    required String title,
    String description = '',
  }) async {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Reward title is required.');
    }

    if (requesterId == recipientId) {
      throw Exception('You cannot request a reward from yourself.');
    }

    final familyRef = _firestore.collection('families').doc(familyId);
    final requesterRef = _firestore.collection('users').doc(requesterId);
    final recipientRef = _firestore.collection('users').doc(recipientId);

    final proposalRef = familyRef.collection('rewardWishlistProposals').doc();

    final notificationRef = recipientRef.collection('notifications').doc();

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);
      final requesterSnapshot = await transaction.get(requesterRef);
      final recipientSnapshot = await transaction.get(recipientRef);

      if (!familySnapshot.exists) {
        throw Exception('Family not found.');
      }

      if (!requesterSnapshot.exists || !recipientSnapshot.exists) {
        throw Exception('Family member not found.');
      }

      final familyData = familySnapshot.data()!;

      final members = List<String>.from(
        familyData['members'] ?? const <String>[],
      );

      if (!members.contains(requesterId) || !members.contains(recipientId)) {
        throw Exception('Both users must belong to this family.');
      }

      transaction.set(proposalRef, {
        'familyId': familyId,
        'requesterId': requesterId,
        'requesterName': requesterName.trim(),
        'recipientId': recipientId,
        'recipientName': recipientName.trim(),
        'title': trimmedTitle,
        'description': description.trim(),
        'status': RewardWishlistStatus.requested.name,
        'tokenRequirement': 0,
        'dailyWinsRequired': 0,
        'weeklyWinsRequired': 0,
        'monthlyWinsRequired': 0,
        'missionsRequired': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'offeredAt': null,
        'acceptedAt': null,
        'completedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'userId': recipientId,
        'type': 'wishlistRequest',
        'title': 'New Wishlist Request',
        'message': '${requesterName.trim()} requested "$trimmedTitle".',
        'familyId': familyId,
        'proposalId': proposalRef.id,
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return proposalRef.id;
  }

  Future<void> requestWishlistRedemption({
    required String familyId,
    required String proposalId,
    required String requesterId,
  }) async {
    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    final requesterRef = _firestore.collection('users').doc(requesterId);

    await _firestore.runTransaction((transaction) async {
      final proposalSnapshot = await transaction.get(proposalRef);
      final requesterSnapshot = await transaction.get(requesterRef);

      if (!proposalSnapshot.exists) {
        throw Exception('Wishlist goal not found.');
      }

      if (!requesterSnapshot.exists) {
        throw Exception('Requester not found.');
      }

      final proposalData = proposalSnapshot.data()!;
      final requesterData = requesterSnapshot.data()!;

      if (proposalData['requesterId']?.toString() != requesterId) {
        throw Exception('You cannot redeem another member\'s goal.');
      }

      final status = proposalData['status']?.toString();

      if (status != RewardWishlistStatus.accepted.name &&
          status != RewardWishlistStatus.readyToRedeem.name) {
        throw Exception('This goal is not ready for redemption.');
      }

      final tokenRequirement =
          (proposalData['tokenRequirement'] as num?)?.toInt() ?? 0;

      final dailyWinsRequired =
          (proposalData['dailyWinsRequired'] as num?)?.toInt() ?? 0;

      final weeklyWinsRequired =
          (proposalData['weeklyWinsRequired'] as num?)?.toInt() ?? 0;

      final monthlyWinsRequired =
          (proposalData['monthlyWinsRequired'] as num?)?.toInt() ?? 0;

      final missionsRequired =
          (proposalData['missionsRequired'] as num?)?.toInt() ?? 0;

      final currentTokens = (requesterData['tokens'] as num?)?.toInt() ?? 0;

      final dailyWins = (requesterData['dailyWins'] as num?)?.toInt() ?? 0;

      final weeklyWins = (requesterData['weeklyWins'] as num?)?.toInt() ?? 0;

      final monthlyWins = (requesterData['monthlyWins'] as num?)?.toInt() ?? 0;

      final missionsCompleted =
          (requesterData['missionsCompleted'] as num?)?.toInt() ?? 0;

      if (currentTokens < tokenRequirement) {
        throw Exception('You have not reached the Token requirement yet.');
      }

      if (dailyWins < dailyWinsRequired) {
        throw Exception(
          'You have not completed enough Daily Challenge wins yet.',
        );
      }

      if (weeklyWins < weeklyWinsRequired) {
        throw Exception(
          'You have not completed enough Weekly Championship wins yet.',
        );
      }

      if (monthlyWins < monthlyWinsRequired) {
        throw Exception('You have not completed enough Monthly Cup wins yet.');
      }

      if (missionsCompleted < missionsRequired) {
        throw Exception('You have not completed enough missions yet.');
      }

      final recipientId = proposalData['recipientId']?.toString() ?? '';

      final title = proposalData['title']?.toString() ?? 'Reward';

      if (recipientId.isEmpty) {
        throw Exception('Invalid wishlist goal.');
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.redemptionRequested.name,
        'redemptionRequestedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'userId': recipientId,
        'type': 'wishlistRedemptionRequested',
        'title': 'Reward Ready to Fulfill',
        'message':
            'The requirements for "$title" are complete. Please confirm fulfillment.',
        'familyId': familyId,
        'proposalId': proposalId,
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> fulfillWishlistRedemption({
    required String familyId,
    required String proposalId,
    required String recipientId,
  }) async {
    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    await _firestore.runTransaction((transaction) async {
      final proposalSnapshot = await transaction.get(proposalRef);

      if (!proposalSnapshot.exists) {
        throw Exception('Wishlist goal not found.');
      }

      final proposalData = proposalSnapshot.data()!;

      if (proposalData['recipientId']?.toString() != recipientId) {
        throw Exception(
          'Only the person who made the offer can fulfill this reward.',
        );
      }

      if (proposalData['status']?.toString() !=
          RewardWishlistStatus.redemptionRequested.name) {
        throw Exception('This reward is not waiting for fulfillment.');
      }

      final requesterId = proposalData['requesterId']?.toString() ?? '';

      final title = proposalData['title']?.toString() ?? 'Reward';

      final tokenRequirement =
          (proposalData['tokenRequirement'] as num?)?.toInt() ?? 0;

      if (requesterId.isEmpty) {
        throw Exception('Invalid wishlist goal.');
      }

      final requesterRef = _firestore.collection('users').doc(requesterId);

      final requesterSnapshot = await transaction.get(requesterRef);

      if (!requesterSnapshot.exists) {
        throw Exception('Requester not found.');
      }

      final requesterData = requesterSnapshot.data()!;

      final currentTokens = (requesterData['tokens'] as num?)?.toInt() ?? 0;

      if (currentTokens < tokenRequirement) {
        throw Exception('The requester no longer has enough Tokens.');
      }

      if (tokenRequirement > 0) {
        final tokenTransactionRef = requesterRef
            .collection('tokenTransactions')
            .doc();

        transaction.update(requesterRef, {
          'tokens': FieldValue.increment(-tokenRequirement),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(tokenTransactionRef, {
          'userId': requesterId,
          'familyId': familyId,
          'amount': -tokenRequirement,
          'type': 'spent',
          'reason': 'Wishlist reward: $title',
          'relatedRewardId': null,
          'relatedRequestId': proposalId,
          'relatedCompetitionId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.completed.name,
        'fulfilledBy': recipientId,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final notificationRef = requesterRef.collection('notifications').doc();

      transaction.set(notificationRef, {
        'userId': requesterId,
        'type': 'wishlistCompleted',
        'title': 'Wishlist Reward Completed',
        'message': '"$title" has been fulfilled.',
        'familyId': familyId,
        'proposalId': proposalId,
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> makeWishlistOffer({
    required String familyId,
    required String proposalId,
    required String recipientId,
    required int tokenRequirement,
    int dailyWinsRequired = 0,
    int weeklyWinsRequired = 0,
    int monthlyWinsRequired = 0,
    int missionsRequired = 0,
  }) async {
    if (tokenRequirement < 0 ||
        dailyWinsRequired < 0 ||
        weeklyWinsRequired < 0 ||
        monthlyWinsRequired < 0 ||
        missionsRequired < 0) {
      throw Exception('Reward requirements cannot be negative.');
    }

    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    await _firestore.runTransaction((transaction) async {
      final proposalSnapshot = await transaction.get(proposalRef);

      if (!proposalSnapshot.exists) {
        throw Exception('Wishlist request not found.');
      }

      final data = proposalSnapshot.data()!;

      if (data['recipientId']?.toString() != recipientId) {
        throw Exception('Only the selected family member can make an offer.');
      }

      if (data['status']?.toString() != RewardWishlistStatus.requested.name) {
        throw Exception('This wishlist request can no longer be offered.');
      }

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.offered.name,
        'tokenRequirement': tokenRequirement,
        'dailyWinsRequired': dailyWinsRequired,
        'weeklyWinsRequired': weeklyWinsRequired,
        'monthlyWinsRequired': monthlyWinsRequired,
        'missionsRequired': missionsRequired,
        'offeredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> declineWishlistProposal({
    required String familyId,
    required String proposalId,
    required String recipientId,
  }) async {
    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(proposalRef);

      if (!snapshot.exists) {
        throw Exception('Wishlist request not found.');
      }

      final data = snapshot.data()!;

      if (data['recipientId']?.toString() != recipientId) {
        throw Exception('You cannot decline this wishlist request.');
      }

      if (data['status']?.toString() != RewardWishlistStatus.requested.name) {
        throw Exception('This wishlist request can no longer be declined.');
      }

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.declined.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> acceptWishlistOffer({
    required String familyId,
    required String proposalId,
    required String requesterId,
  }) async {
    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(proposalRef);

      if (!snapshot.exists) {
        throw Exception('Wishlist offer not found.');
      }

      final data = snapshot.data()!;

      if (data['requesterId']?.toString() != requesterId) {
        throw Exception('Only the requester can accept this offer.');
      }

      if (data['status']?.toString() != RewardWishlistStatus.offered.name) {
        throw Exception('This wishlist offer is no longer available.');
      }

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.accepted.name,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectWishlistOffer({
    required String familyId,
    required String proposalId,
    required String requesterId,
  }) async {
    final proposalRef = _firestore
        .collection('families')
        .doc(familyId)
        .collection('rewardWishlistProposals')
        .doc(proposalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(proposalRef);

      if (!snapshot.exists) {
        throw Exception('Wishlist offer not found.');
      }

      final data = snapshot.data()!;

      if (data['requesterId']?.toString() != requesterId) {
        throw Exception('Only the requester can reject this offer.');
      }

      if (data['status']?.toString() != RewardWishlistStatus.offered.name) {
        throw Exception('This wishlist offer is no longer available.');
      }

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.rejected.name,
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
