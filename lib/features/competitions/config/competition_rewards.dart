class CompetitionRewards {
  const CompetitionRewards._();

  // ============================================================
  // TOKENS
  //
  // Spendable KinQuest currency.
  // These can later be used for Family Wishes.
  // ============================================================

  static const int dailyWinnerTokens = 10;
  static const int weeklyChampionTokens = 50;
  static const int monthlyChampionTokens = 100;

  // ============================================================
  // PERMANENT RANKING POINTS
  //
  // These are never spent.
  // They represent official competitive performance.
  // ============================================================

  static const int dailyWinnerRankingPoints = 10;
  static const int dailyRunnerUpRankingPoints = 4;

  static const int weeklyChampionRankingPoints = 40;
  static const int weeklyRunnerUpRankingPoints = 20;
  static const int weeklyThirdPlaceRankingPoints = 10;

  static const int monthlyChampionRankingPoints = 100;
  static const int monthlyRunnerUpRankingPoints = 50;
  static const int monthlySemifinalistRankingPoints = 20;

  // ============================================================
  // WEEKLY CHAMPIONSHIP ROUND POINTS
  //
  // These exist only inside one Weekly Championship.
  // They are NOT Tokens.
  // They are NOT permanent Ranking Points.
  // ============================================================

  static const int weeklyRoundFirst = 10;
  static const int weeklyRoundSecond = 7;
  static const int weeklyRoundThird = 5;
  static const int weeklyRoundFourth = 3;
  static const int weeklyRoundParticipation = 1;
}