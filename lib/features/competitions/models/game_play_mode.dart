enum GamePlayMode { quickPlay, dailyChallenge, weeklyChampionship, monthlyCup }

extension GamePlayModeX on GamePlayMode {
  bool get isOfficial => this != GamePlayMode.quickPlay;

  String get displayName {
    switch (this) {
      case GamePlayMode.quickPlay:
        return 'Quick Play';

      case GamePlayMode.dailyChallenge:
        return 'Daily Challenge';

      case GamePlayMode.weeklyChampionship:
        return 'Weekly Championship';

      case GamePlayMode.monthlyCup:
        return 'Monthly Cup';
    }
  }
}
