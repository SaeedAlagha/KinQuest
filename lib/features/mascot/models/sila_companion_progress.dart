enum SilaCompanionLevel {
  newCompanion(requiredPoints: 0),
  familyFriend(requiredPoints: 250),
  memoryKeeper(requiredPoints: 700),
  familyGuardian(requiredPoints: 1500),
  legacyCompanion(requiredPoints: 2800);

  const SilaCompanionLevel({required this.requiredPoints});

  final int requiredPoints;
}

class SilaCompanionStats {
  const SilaCompanionStats({
    this.gamesPlayed = 0,
    this.missionsCompleted = 0,
    this.officialWins = 0,
    this.weeklyWins = 0,
    this.monthlyWins = 0,
    this.trophies = 0,
  });

  factory SilaCompanionStats.fromMembers(
    Iterable<Map<String, dynamic>> members,
  ) {
    var gamesPlayed = 0;
    var missionsCompleted = 0;
    var officialWins = 0;
    var weeklyWins = 0;
    var monthlyWins = 0;
    var trophies = 0;

    for (final member in members) {
      gamesPlayed += _nonNegativeInt(member['gamesPlayed']);
      missionsCompleted += _nonNegativeInt(member['missionsCompleted']);
      officialWins += _nonNegativeInt(member['officialWins']);
      weeklyWins += _nonNegativeInt(member['weeklyWins']);
      monthlyWins += _nonNegativeInt(member['monthlyWins']);
      trophies += _nonNegativeInt(member['trophies']);
    }

    return SilaCompanionStats(
      gamesPlayed: gamesPlayed,
      missionsCompleted: missionsCompleted,
      officialWins: officialWins,
      weeklyWins: weeklyWins,
      monthlyWins: monthlyWins,
      trophies: trophies,
    );
  }

  final int gamesPlayed;
  final int missionsCompleted;
  final int officialWins;
  final int weeklyWins;
  final int monthlyWins;
  final int trophies;

  /// Bond Points reward regular family participation while giving greater
  /// weight to shared missions and official competition milestones.
  int get bondPoints =>
      gamesPlayed * 6 +
      missionsCompleted * 25 +
      officialWins * 20 +
      weeklyWins * 50 +
      monthlyWins * 120 +
      trophies * 90;

  static int _nonNegativeInt(Object? value) {
    final number = value is num ? value.toInt() : 0;
    return number < 0 ? 0 : number;
  }
}

class SilaCompanionProgress {
  const SilaCompanionProgress({required this.stats});

  final SilaCompanionStats stats;

  int get bondPoints => stats.bondPoints;

  SilaCompanionLevel get currentLevel {
    var result = SilaCompanionLevel.newCompanion;
    for (final level in SilaCompanionLevel.values) {
      if (bondPoints < level.requiredPoints) break;
      result = level;
    }
    return result;
  }

  SilaCompanionLevel? get nextLevel {
    final nextIndex = currentLevel.index + 1;
    if (nextIndex >= SilaCompanionLevel.values.length) return null;
    return SilaCompanionLevel.values[nextIndex];
  }

  int get pointsToNextLevel {
    final next = nextLevel;
    if (next == null) return 0;
    return next.requiredPoints - bondPoints;
  }

  double get levelProgress {
    final next = nextLevel;
    if (next == null) return 1;
    final start = currentLevel.requiredPoints;
    final range = next.requiredPoints - start;
    return ((bondPoints - start) / range).clamp(0, 1).toDouble();
  }

  bool hasReached(SilaCompanionLevel level) =>
      bondPoints >= level.requiredPoints;
}
