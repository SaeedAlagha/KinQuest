import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_theme_catalog.dart';

class ThemeUnlockResult {
  const ThemeUnlockResult({
    required this.remainingTokens,
    required this.wasAlreadyUnlocked,
  });

  final int remainingTokens;
  final bool wasAlreadyUnlocked;
}

class ThemeUnlockException implements Exception {
  const ThemeUnlockException(this.message);

  final String message;

  @override
  String toString() => 'ThemeUnlockException: $message';
}

class ThemeUnlockService {
  ThemeUnlockService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ThemeUnlockResult> unlockWithTokens({
    required String userId,
    required AppThemeOffer offer,
  }) async {
    final cost = offer.tokenCost;
    if (offer.isIncluded || cost == null || cost <= 0) {
      throw const ThemeUnlockException('A premium Token theme is required.');
    }

    final userRef = _firestore.collection('users').doc(userId);
    final tokenTransactionRef = userRef.collection('tokenTransactions').doc();

    return _firestore.runTransaction<ThemeUnlockResult>((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw const ThemeUnlockException('User profile not found.');
      }

      final balance = (data['tokens'] as num?)?.toInt() ?? 0;
      final familyId = data['familyId']?.toString() ?? '';
      final unlocked =
          (data['unlockedAppearances'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toSet() ??
          <String>{};

      if (unlocked.contains(offer.appearance.name)) {
        return ThemeUnlockResult(
          remainingTokens: balance,
          wasAlreadyUnlocked: true,
        );
      }

      if (familyId.isEmpty) {
        throw const ThemeUnlockException('Family membership is required.');
      }
      if (balance < cost) {
        throw const ThemeUnlockException('Not enough Family Tokens.');
      }

      final remaining = balance - cost;
      transaction.update(userRef, {
        'tokens': remaining,
        'unlockedAppearances': FieldValue.arrayUnion([offer.appearance.name]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(tokenTransactionRef, {
        'userId': userId,
        'familyId': familyId,
        'amount': -cost,
        'type': 'spent',
        'reason': 'Theme: ${offer.appearance.name}',
        'relatedRewardId': null,
        'relatedRequestId': null,
        'relatedCompetitionId': null,
        'themeId': offer.appearance.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return ThemeUnlockResult(
        remainingTokens: remaining,
        wasAlreadyUnlocked: false,
      );
    });
  }
}
