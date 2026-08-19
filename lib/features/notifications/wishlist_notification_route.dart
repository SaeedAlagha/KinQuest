enum WishlistNotificationDestination { sent, received, goals }

class WishlistNotificationRoute {
  const WishlistNotificationRoute({
    required this.familyId,
    required this.proposalId,
    required this.destination,
  });

  final String familyId;
  final String proposalId;
  final WishlistNotificationDestination destination;

  static WishlistNotificationRoute? fromData(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim() ?? '';
    final familyId = data['familyId']?.toString().trim() ?? '';
    final proposalId = data['proposalId']?.toString().trim() ?? '';

    if (!type.startsWith('wishlist') ||
        familyId.isEmpty ||
        proposalId.isEmpty) {
      return null;
    }

    final explicitDestination = data['destination']?.toString().trim();
    final destination = switch (explicitDestination) {
      'wishlistSent' => WishlistNotificationDestination.sent,
      'wishlistReceived' => WishlistNotificationDestination.received,
      'rewardsGoals' => WishlistNotificationDestination.goals,
      _ => _legacyDestination(type),
    };

    return WishlistNotificationRoute(
      familyId: familyId,
      proposalId: proposalId,
      destination: destination,
    );
  }

  static WishlistNotificationDestination _legacyDestination(String type) {
    return switch (type) {
      'wishlistOffer' ||
      'wishlistRequestDeclined' => WishlistNotificationDestination.sent,
      'wishlistGoalReady' ||
      'wishlistCompleted' => WishlistNotificationDestination.goals,
      _ => WishlistNotificationDestination.received,
    };
  }
}
