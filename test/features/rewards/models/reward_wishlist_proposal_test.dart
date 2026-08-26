import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/models/reward_wishlist_proposal.dart';

void main() {
  const proposal = RewardWishlistProposal(
    id: 'proposal-1',
    familyId: 'family-1',
    requesterId: 'requester-1',
    requesterName: 'Requester',
    recipientId: 'recipient-1',
    recipientName: 'Recipient',
    title: 'Family outing',
    description: '',
    status: RewardWishlistStatus.accepted,
    tokenRequirement: 20,
    dailyWinsRequired: 2,
    weeklyWinsRequired: 1,
    monthlyWinsRequired: 1,
    missionsRequired: 3,
    dailyWinsBaseline: 10,
    weeklyWinsBaseline: 4,
    monthlyWinsBaseline: 2,
    missionsBaseline: 8,
  );

  test('counts achievement progress only after an offer is accepted', () {
    expect(proposal.dailyProgress(10), 0);
    expect(proposal.dailyProgress(12), 2);
    expect(proposal.weeklyProgress(5), 1);
    expect(proposal.monthlyProgress(3), 1);
    expect(proposal.missionProgress(11), 3);
  });

  test('never exposes negative progress if a counter is corrected', () {
    expect(proposal.dailyProgress(7), 0);
    expect(proposal.missionProgress(5), 0);
  });

  test('requires every agreed milestone before redemption', () {
    expect(
      proposal.requirementsMet(
        tokens: 20,
        dailyWins: 12,
        weeklyWins: 5,
        monthlyWins: 3,
        missionsCompleted: 11,
      ),
      isTrue,
    );

    expect(
      proposal.requirementsMet(
        tokens: 20,
        dailyWins: 11,
        weeklyWins: 5,
        monthlyWins: 3,
        missionsCompleted: 11,
      ),
      isFalse,
    );
  });

  test('presents an accepted goal as ready when every milestone is met', () {
    expect(
      proposal.effectiveStatus(
        tokens: 20,
        dailyWins: 12,
        weeklyWins: 5,
        monthlyWins: 3,
        missionsCompleted: 11,
      ),
      RewardWishlistStatus.readyToRedeem,
    );

    expect(
      proposal.effectiveStatus(
        tokens: 20,
        dailyWins: 11,
        weeklyWins: 5,
        monthlyWins: 3,
        missionsCompleted: 11,
      ),
      RewardWishlistStatus.accepted,
    );
  });

  test('never rewrites terminal workflow states for display', () {
    final completedProposal = RewardWishlistProposal(
      id: proposal.id,
      familyId: proposal.familyId,
      requesterId: proposal.requesterId,
      requesterName: proposal.requesterName,
      recipientId: proposal.recipientId,
      recipientName: proposal.recipientName,
      title: proposal.title,
      description: proposal.description,
      status: RewardWishlistStatus.completed,
      tokenRequirement: proposal.tokenRequirement,
      dailyWinsRequired: proposal.dailyWinsRequired,
      weeklyWinsRequired: proposal.weeklyWinsRequired,
      monthlyWinsRequired: proposal.monthlyWinsRequired,
      missionsRequired: proposal.missionsRequired,
    );

    expect(
      completedProposal.effectiveStatus(
        tokens: 100,
        dailyWins: 100,
        weeklyWins: 100,
        monthlyWins: 100,
        missionsCompleted: 100,
      ),
      RewardWishlistStatus.completed,
    );
  });
}
