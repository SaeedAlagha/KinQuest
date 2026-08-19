import '../../../l10n/app_localizations.dart';

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

  String localizedName(AppLocalizations strings) {
    return switch (this) {
      GamePlayMode.quickPlay => strings.quickPlay,
      GamePlayMode.dailyChallenge => strings.dailyChallenge,
      GamePlayMode.weeklyChampionship => strings.weeklyChampionship,
      GamePlayMode.monthlyCup => strings.monthlyCup,
    };
  }
}
