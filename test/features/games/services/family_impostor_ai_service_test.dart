import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/services/family_impostor_ai_service.dart';

void main() {
  group('FamilyImpostorAiService offline rounds', () {
    test('keeps every round in the selected category', () {
      final rounds = FamilyImpostorAiService.offlineRounds(
        count: 5,
        category: 'UAE & Heritage',
        random: Random(7),
      );

      expect(rounds, hasLength(5));
      expect(rounds.map((round) => round.category).toSet(), {'UAE & Heritage'});
      expect(rounds.map((round) => round.word).toSet(), hasLength(5));
    });

    test('random mix uses multiple categories and unique words', () {
      final rounds = FamilyImpostorAiService.offlineRounds(
        count: 10,
        random: Random(11),
      );

      expect(rounds, hasLength(10));
      expect(
        rounds.map((round) => round.category).toSet().length,
        greaterThan(1),
      );
      expect(
        rounds.map((round) => round.word.toLowerCase()).toSet(),
        hasLength(10),
      );
    });

    test('includes the three new variety categories', () {
      expect(
        FamilyImpostorAiService.categories,
        containsAll(['Music', 'Technology', 'UAE & Heritage']),
      );
    });
  });
}
