import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/notifications/wishlist_notification_route.dart';

void main() {
  const baseData = <String, dynamic>{
    'familyId': 'family-1',
    'proposalId': 'proposal-1',
  };

  test('routes each Wishlist notification to its intended experience', () {
    final expectations = <String, WishlistNotificationDestination>{
      'wishlistRequest': WishlistNotificationDestination.received,
      'wishlistOffer': WishlistNotificationDestination.sent,
      'wishlistRequestDeclined': WishlistNotificationDestination.sent,
      'wishlistOfferAccepted': WishlistNotificationDestination.received,
      'wishlistOfferRejected': WishlistNotificationDestination.received,
      'wishlistRedemptionRequested': WishlistNotificationDestination.received,
      'wishlistGoalReady': WishlistNotificationDestination.goals,
      'wishlistCompleted': WishlistNotificationDestination.goals,
    };

    for (final entry in expectations.entries) {
      final route = WishlistNotificationRoute.fromData({
        ...baseData,
        'type': entry.key,
      });

      expect(route, isNotNull, reason: entry.key);
      expect(route!.destination, entry.value, reason: entry.key);
      expect(route.familyId, 'family-1');
      expect(route.proposalId, 'proposal-1');
    }
  });

  test('explicit destinations override legacy type routing', () {
    final route = WishlistNotificationRoute.fromData({
      ...baseData,
      'type': 'wishlistRequest',
      'destination': 'rewardsGoals',
    });

    expect(route?.destination, WishlistNotificationDestination.goals);
  });

  test('ignores malformed and unrelated notifications', () {
    expect(
      WishlistNotificationRoute.fromData({
        ...baseData,
        'type': 'competitionStarted',
      }),
      isNull,
    );
    expect(
      WishlistNotificationRoute.fromData({
        'type': 'wishlistGoalReady',
        'familyId': 'family-1',
      }),
      isNull,
    );
  });
}
