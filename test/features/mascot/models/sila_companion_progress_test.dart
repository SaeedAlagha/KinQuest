import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/mascot/models/sila_companion_progress.dart';

void main() {
  group('SilaCompanionStats', () {
    test('combines family activity and ignores invalid negative values', () {
      final stats = SilaCompanionStats.fromMembers([
        {
          'gamesPlayed': 12,
          'missionsCompleted': 3,
          'officialWins': 2,
          'weeklyWins': 1,
          'monthlyWins': 1,
          'trophies': 1,
        },
        {
          'gamesPlayed': 8.9,
          'missionsCompleted': -4,
          'officialWins': 'invalid',
          'weeklyWins': 2,
        },
      ]);

      expect(stats.gamesPlayed, 20);
      expect(stats.missionsCompleted, 3);
      expect(stats.officialWins, 2);
      expect(stats.weeklyWins, 3);
      expect(stats.monthlyWins, 1);
      expect(stats.trophies, 1);
      expect(stats.bondPoints, 595);
    });
  });

  group('SilaCompanionProgress', () {
    test('starts as a new companion with an empty family history', () {
      const progress = SilaCompanionProgress(stats: SilaCompanionStats());

      expect(progress.currentLevel, SilaCompanionLevel.newCompanion);
      expect(progress.nextLevel, SilaCompanionLevel.familyFriend);
      expect(progress.pointsToNextLevel, 250);
      expect(progress.levelProgress, 0);
    });

    test('reports progress within the current relationship level', () {
      const progress = SilaCompanionProgress(
        stats: SilaCompanionStats(gamesPlayed: 50),
      );

      expect(progress.bondPoints, 300);
      expect(progress.currentLevel, SilaCompanionLevel.familyFriend);
      expect(progress.nextLevel, SilaCompanionLevel.memoryKeeper);
      expect(progress.pointsToNextLevel, 400);
      expect(progress.levelProgress, closeTo(50 / 450, 0.0001));
      expect(progress.hasReached(SilaCompanionLevel.familyFriend), isTrue);
      expect(progress.hasReached(SilaCompanionLevel.memoryKeeper), isFalse);
    });

    test('caps progress at the legacy companion level', () {
      const progress = SilaCompanionProgress(
        stats: SilaCompanionStats(gamesPlayed: 500),
      );

      expect(progress.currentLevel, SilaCompanionLevel.legacyCompanion);
      expect(progress.nextLevel, isNull);
      expect(progress.pointsToNextLevel, 0);
      expect(progress.levelProgress, 1);
    });
  });
}
