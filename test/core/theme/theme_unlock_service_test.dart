import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:kinquest/core/theme/app_theme_catalog.dart';
import 'package:kinquest/core/theme/theme_unlock_service.dart';

void main() {
  test(
    'atomically spends Tokens and records premium theme ownership',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('member-a').set({
        'familyId': 'family-a',
        'tokens': 1000,
        'unlockedAppearances': <String>[],
      });
      final service = ThemeUnlockService(firestore: firestore);
      final offer = AppThemeCatalog.offerFor(AppAppearance.space);

      final result = await service.unlockWithTokens(
        userId: 'member-a',
        offer: offer,
      );

      expect(result.remainingTokens, 350);
      expect(result.wasAlreadyUnlocked, isFalse);

      final user = await firestore.collection('users').doc('member-a').get();
      expect(user.data()!['tokens'], 350);
      expect(
        user.data()!['unlockedAppearances'],
        contains(AppAppearance.space.name),
      );

      final transactions = await firestore
          .collection('users')
          .doc('member-a')
          .collection('tokenTransactions')
          .get();
      expect(transactions.docs, hasLength(1));
      expect(transactions.docs.single.data()['amount'], -650);
      expect(transactions.docs.single.data()['type'], 'spent');
    },
  );

  test('never charges twice for the same theme', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('member-a').set({
      'familyId': 'family-a',
      'tokens': 1000,
      'unlockedAppearances': [AppAppearance.familyYear2026.name],
    });
    final service = ThemeUnlockService(firestore: firestore);

    final result = await service.unlockWithTokens(
      userId: 'member-a',
      offer: AppThemeCatalog.offerFor(AppAppearance.familyYear2026),
    );

    expect(result.remainingTokens, 1000);
    expect(result.wasAlreadyUnlocked, isTrue);
    final transactions = await firestore
        .collection('users')
        .doc('member-a')
        .collection('tokenTransactions')
        .get();
    expect(transactions.docs, isEmpty);
  });

  test('leaves the account unchanged when Tokens are insufficient', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('member-a').set({
      'familyId': 'family-a',
      'tokens': 300,
      'unlockedAppearances': <String>[],
    });
    final service = ThemeUnlockService(firestore: firestore);

    await expectLater(
      service.unlockWithTokens(
        userId: 'member-a',
        offer: AppThemeCatalog.offerFor(AppAppearance.pearlLagoon),
      ),
      throwsA(isA<ThemeUnlockException>()),
    );

    final user = await firestore.collection('users').doc('member-a').get();
    expect(user.data()!['tokens'], 300);
    expect(user.data()!['unlockedAppearances'], isEmpty);
  });
}
