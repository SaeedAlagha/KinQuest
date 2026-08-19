import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/models/family_reward.dart';
import 'package:kinquest/features/rewards/models/reward_request.dart';
import 'package:kinquest/features/rewards/services/rewards_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late RewardsService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = RewardsService(firestore: firestore);
  });

  test('only the family owner can create a reward', () async {
    await _seedFamily(firestore);

    final rewardId = await service.createFamilyReward(
      familyId: 'family-1',
      creatorId: 'owner-1',
      title: '  Choose Dessert  ',
      description: '  Pick dessert after dinner.  ',
      tokenCost: 120,
      type: FamilyRewardType.family,
      approvalRequired: true,
      availability: RewardAvailability.weekly,
    );

    final reward = await firestore
        .collection('families')
        .doc('family-1')
        .collection('rewards')
        .doc(rewardId)
        .get();

    expect(reward.data()?['title'], 'Choose Dessert');
    expect(reward.data()?['description'], 'Pick dessert after dinner.');
    expect(reward.data()?['active'], isTrue);

    await expectLater(
      service.createFamilyReward(
        familyId: 'family-1',
        creatorId: 'member-1',
        title: 'Not allowed',
        description: '',
        tokenCost: 100,
        type: FamilyRewardType.family,
        approvalRequired: true,
        availability: RewardAvailability.unlimited,
      ),
      _throwsMessage('Only the Family Admin can create rewards.'),
    );
  });

  test(
    'request creation preserves Tokens and blocks a duplicate pending request',
    () async {
      final reward = await _seedRewardScenario(firestore);

      final requestId = await service.createRewardRequest(
        familyId: 'family-1',
        userId: 'member-1',
        reward: reward,
        requesterNote: '  Saturday please  ',
      );

      final request = await _requestRef(firestore, requestId).get();
      final user = await firestore.collection('users').doc('member-1').get();
      final pendingLock = await _pendingLockRef(firestore).get();

      expect(request.data()?['status'], RewardRequestStatus.pending.name);
      expect(request.data()?['requesterNote'], 'Saturday please');
      expect(user.data()?['tokens'], 800);
      expect(pendingLock.exists, isTrue);

      await expectLater(
        service.createRewardRequest(
          familyId: 'family-1',
          userId: 'member-1',
          reward: reward,
        ),
        _throwsMessage('You already have a pending request for this reward.'),
      );
    },
  );

  test('approval deducts Tokens once and enforces the weekly limit', () async {
    final reward = await _seedRewardScenario(firestore);
    final requestId = await service.createRewardRequest(
      familyId: 'family-1',
      userId: 'member-1',
      reward: reward,
    );

    await service.approveRewardRequest(
      familyId: 'family-1',
      requestId: requestId,
      approverId: 'owner-1',
      approverNote: '  Enjoy!  ',
    );

    final request = await _requestRef(firestore, requestId).get();
    final user = await firestore.collection('users').doc('member-1').get();
    final pendingLock = await _pendingLockRef(firestore).get();
    final tokenTransactions = await firestore
        .collection('users')
        .doc('member-1')
        .collection('tokenTransactions')
        .get();
    final redemptionLocks = await firestore
        .collection('families')
        .doc('family-1')
        .collection('rewardRedemptionLocks')
        .get();

    expect(request.data()?['status'], RewardRequestStatus.approved.name);
    expect(request.data()?['approverNote'], 'Enjoy!');
    expect(user.data()?['tokens'], 550);
    expect(pendingLock.exists, isFalse);
    expect(tokenTransactions.docs, hasLength(1));
    expect(tokenTransactions.docs.single.data()['amount'], -250);
    expect(redemptionLocks.docs, hasLength(1));

    await expectLater(
      service.createRewardRequest(
        familyId: 'family-1',
        userId: 'member-1',
        reward: reward,
      ),
      _throwsMessage('You have already redeemed this reward this week.'),
    );
  });

  test('an approver cannot approve their own request', () async {
    final reward = await _seedRewardScenario(
      firestore,
      rewardApproverIds: const ['member-1'],
    );
    final requestId = await service.createRewardRequest(
      familyId: 'family-1',
      userId: 'member-1',
      reward: reward,
    );

    await expectLater(
      service.approveRewardRequest(
        familyId: 'family-1',
        requestId: requestId,
        approverId: 'member-1',
      ),
      _throwsMessage('You cannot approve your own reward request.'),
    );

    final user = await firestore.collection('users').doc('member-1').get();
    expect(user.data()?['tokens'], 800);
  });

  test('a member can cancel only their own pending request', () async {
    final reward = await _seedRewardScenario(firestore);
    final requestId = await service.createRewardRequest(
      familyId: 'family-1',
      userId: 'member-1',
      reward: reward,
    );

    await expectLater(
      service.cancelRewardRequest(
        familyId: 'family-1',
        requestId: requestId,
        userId: 'member-2',
      ),
      _throwsMessage('You cannot cancel another member\'s request.'),
    );

    await service.cancelRewardRequest(
      familyId: 'family-1',
      requestId: requestId,
      userId: 'member-1',
    );

    final request = await _requestRef(firestore, requestId).get();
    expect(request.data()?['status'], RewardRequestStatus.cancelled.name);
    expect((await _pendingLockRef(firestore).get()).exists, isFalse);
  });

  test('digital purchase is permanent and cannot charge twice', () async {
    final reward = await _seedRewardScenario(
      firestore,
      type: FamilyRewardType.digital,
      approvalRequired: false,
      rewardId: 'frame-1',
      title: 'Champion Frame',
      tokenCost: 300,
      availability: RewardAvailability.oneTime,
    );

    await service.purchaseDigitalReward(
      familyId: 'family-1',
      userId: 'member-1',
      reward: reward,
    );

    final userRef = firestore.collection('users').doc('member-1');
    final user = await userRef.get();
    final ownedReward = await userRef
        .collection('ownedRewards')
        .doc('frame-1')
        .get();

    expect(user.data()?['tokens'], 500);
    expect(ownedReward.data()?['title'], 'Champion Frame');
    expect(ownedReward.data()?['equipped'], isFalse);

    await expectLater(
      service.purchaseDigitalReward(
        familyId: 'family-1',
        userId: 'member-1',
        reward: reward,
      ),
      _throwsMessage('You already own this digital reward.'),
    );

    expect((await userRef.get()).data()?['tokens'], 500);
  });

  test('equipping one digital reward unequips the previous reward', () async {
    final userRef = firestore.collection('users').doc('member-1');
    await userRef.set({'tokens': 800});
    await userRef.collection('ownedRewards').doc('frame-1').set({
      'equipped': true,
    });
    await userRef.collection('ownedRewards').doc('badge-1').set({
      'equipped': false,
    });

    await service.equipDigitalReward(userId: 'member-1', rewardId: 'badge-1');

    expect(
      (await userRef.collection('ownedRewards').doc('frame-1').get())
          .data()?['equipped'],
      isFalse,
    );
    expect(
      (await userRef.collection('ownedRewards').doc('badge-1').get())
          .data()?['equipped'],
      isTrue,
    );
    expect((await userRef.get()).data()?['equippedRewardId'], 'badge-1');

    await service.unequipDigitalReward(userId: 'member-1', rewardId: 'badge-1');

    expect(
      (await userRef.collection('ownedRewards').doc('badge-1').get())
          .data()?['equipped'],
      isFalse,
    );
    expect(
      (await userRef.get()).data()?.containsKey('equippedRewardId'),
      isFalse,
    );
  });

  test('owner management and fulfillment use the injected Firestore', () async {
    final reward = await _seedRewardScenario(firestore);
    final requestRef = _requestRef(firestore, 'approved-request');
    await requestRef.set({
      'familyId': 'family-1',
      'userId': 'member-1',
      'rewardId': reward.id,
      'rewardTitle': reward.title,
      'tokenCost': reward.tokenCost,
      'status': RewardRequestStatus.approved.name,
    });

    await service.updateFamilyReward(
      familyId: 'family-1',
      rewardId: reward.id,
      userId: 'owner-1',
      title: ' Updated Movie Night ',
      description: ' Updated details ',
      tokenCost: 275,
      availability: RewardAvailability.monthly,
      approvalRequired: true,
    );
    await service.setRewardActive(
      familyId: 'family-1',
      rewardId: reward.id,
      userId: 'owner-1',
      active: false,
    );
    await service.completeRewardRequest(
      familyId: 'family-1',
      requestId: requestRef.id,
      approverId: 'owner-1',
    );

    final updatedReward = await firestore
        .collection('families')
        .doc('family-1')
        .collection('rewards')
        .doc(reward.id)
        .get();
    final completedRequest = await requestRef.get();

    expect(updatedReward.data()?['title'], 'Updated Movie Night');
    expect(updatedReward.data()?['tokenCost'], 275);
    expect(updatedReward.data()?['availability'], 'monthly');
    expect(updatedReward.data()?['active'], isFalse);
    expect(
      completedRequest.data()?['status'],
      RewardRequestStatus.completed.name,
    );
    expect(completedRequest.data()?['completedBy'], 'owner-1');
  });
}

Future<FamilyReward> _seedRewardScenario(
  FakeFirebaseFirestore firestore, {
  List<String> rewardApproverIds = const <String>[],
  FamilyRewardType type = FamilyRewardType.family,
  bool approvalRequired = true,
  String rewardId = 'movie-night',
  String title = 'Movie Night',
  int tokenCost = 250,
  RewardAvailability availability = RewardAvailability.weekly,
}) async {
  await _seedFamily(firestore, rewardApproverIds: rewardApproverIds);
  await firestore.collection('users').doc('member-1').set({
    'familyId': 'family-1',
    'tokens': 800,
  });

  final rewardRef = firestore
      .collection('families')
      .doc('family-1')
      .collection('rewards')
      .doc(rewardId);
  await rewardRef.set({
    'title': title,
    'description': 'A test family reward.',
    'tokenCost': tokenCost,
    'type': type.name,
    'approvalRequired': approvalRequired,
    'availability': availability.name,
    'active': true,
    'createdBy': 'owner-1',
  });

  return FamilyReward.fromDocument(await rewardRef.get());
}

Future<void> _seedFamily(
  FakeFirebaseFirestore firestore, {
  List<String> rewardApproverIds = const <String>[],
}) {
  return firestore.collection('families').doc('family-1').set({
    'ownerId': 'owner-1',
    'members': ['owner-1', 'member-1', 'member-2'],
    'rewardApproverIds': rewardApproverIds,
  });
}

dynamic _throwsMessage(String message) {
  return throwsA(
    isA<Exception>().having(
      (error) => error.toString(),
      'message',
      contains(message),
    ),
  );
}

dynamic _requestRef(FakeFirebaseFirestore firestore, String requestId) {
  return firestore
      .collection('families')
      .doc('family-1')
      .collection('rewardRequests')
      .doc(requestId);
}

dynamic _pendingLockRef(FakeFirebaseFirestore firestore) {
  return firestore
      .collection('families')
      .doc('family-1')
      .collection('rewardRequestLocks')
      .doc('member-1_movie-night');
}
