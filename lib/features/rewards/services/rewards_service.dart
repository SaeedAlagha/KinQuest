import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reward_wishlist_proposal.dart';

class RewardsService {
  RewardsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
        'dailyWinsBaseline': 0,
        'weeklyWinsBaseline': 0,
        'monthlyWinsBaseline': 0,
        'missionsBaseline': 0,
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
        'destination': 'wishlistReceived',
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

      final dailyWinsBaseline =
          (proposalData['dailyWinsBaseline'] as num?)?.toInt() ?? 0;
      final weeklyWinsBaseline =
          (proposalData['weeklyWinsBaseline'] as num?)?.toInt() ?? 0;
      final monthlyWinsBaseline =
          (proposalData['monthlyWinsBaseline'] as num?)?.toInt() ?? 0;
      final missionsBaseline =
          (proposalData['missionsBaseline'] as num?)?.toInt() ?? 0;

      if (dailyWins - dailyWinsBaseline < dailyWinsRequired) {
        throw Exception(
          'You have not completed enough Daily Challenge wins yet.',
        );
      }

      if (weeklyWins - weeklyWinsBaseline < weeklyWinsRequired) {
        throw Exception(
          'You have not completed enough Weekly Championship wins yet.',
        );
      }

      if (monthlyWins - monthlyWinsBaseline < monthlyWinsRequired) {
        throw Exception('You have not completed enough Monthly Cup wins yet.');
      }

      if (missionsCompleted - missionsBaseline < missionsRequired) {
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
        'destination': 'wishlistReceived',
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
        'destination': 'rewardsGoals',
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

      final requesterId = data['requesterId']?.toString() ?? '';
      final title = data['title']?.toString() ?? 'Reward';

      if (requesterId.isEmpty) {
        throw Exception('Invalid wishlist request.');
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(requesterId)
          .collection('notifications')
          .doc();

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

      transaction.set(notificationRef, {
        'userId': requesterId,
        'type': 'wishlistOffer',
        'title': 'Wishlist Offer Ready',
        'message': 'A family member made an offer for "$title".',
        'familyId': familyId,
        'proposalId': proposalId,
        'destination': 'wishlistSent',
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
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

      final requesterId = data['requesterId']?.toString() ?? '';
      final title = data['title']?.toString() ?? 'Reward';

      if (requesterId.isEmpty) {
        throw Exception('Invalid wishlist request.');
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(requesterId)
          .collection('notifications')
          .doc();

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.declined.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'userId': requesterId,
        'type': 'wishlistRequestDeclined',
        'title': 'Wishlist Request Updated',
        'message': 'Your request for "$title" was declined.',
        'familyId': familyId,
        'proposalId': proposalId,
        'destination': 'wishlistSent',
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
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
    final requesterRef = _firestore.collection('users').doc(requesterId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(proposalRef);
      final requesterSnapshot = await transaction.get(requesterRef);

      if (!snapshot.exists) {
        throw Exception('Wishlist offer not found.');
      }

      if (!requesterSnapshot.exists) {
        throw Exception('Requester not found.');
      }

      final data = snapshot.data()!;

      if (data['requesterId']?.toString() != requesterId) {
        throw Exception('Only the requester can accept this offer.');
      }

      if (data['status']?.toString() != RewardWishlistStatus.offered.name) {
        throw Exception('This wishlist offer is no longer available.');
      }

      final requesterData = requesterSnapshot.data()!;
      final recipientId = data['recipientId']?.toString() ?? '';
      final title = data['title']?.toString() ?? 'Reward';

      if (recipientId.isEmpty) {
        throw Exception('Invalid wishlist offer.');
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.accepted.name,
        'acceptedAt': FieldValue.serverTimestamp(),
        'dailyWinsBaseline': (requesterData['dailyWins'] as num?)?.toInt() ?? 0,
        'weeklyWinsBaseline':
            (requesterData['weeklyWins'] as num?)?.toInt() ?? 0,
        'monthlyWinsBaseline':
            (requesterData['monthlyWins'] as num?)?.toInt() ?? 0,
        'missionsBaseline':
            (requesterData['missionsCompleted'] as num?)?.toInt() ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'userId': recipientId,
        'type': 'wishlistOfferAccepted',
        'title': 'Wishlist Goal Started',
        'message': 'Your offer for "$title" was accepted.',
        'familyId': familyId,
        'proposalId': proposalId,
        'destination': 'wishlistReceived',
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
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

      final recipientId = data['recipientId']?.toString() ?? '';
      final title = data['title']?.toString() ?? 'Reward';

      if (recipientId.isEmpty) {
        throw Exception('Invalid wishlist offer.');
      }

      final notificationRef = _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();

      transaction.update(proposalRef, {
        'status': RewardWishlistStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'userId': recipientId,
        'type': 'wishlistOfferRejected',
        'title': 'Wishlist Offer Updated',
        'message': 'Your offer for "$title" was not accepted.',
        'familyId': familyId,
        'proposalId': proposalId,
        'destination': 'wishlistReceived',
        'read': false,
        'pushPending': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
