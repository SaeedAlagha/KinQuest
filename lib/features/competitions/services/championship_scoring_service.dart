import '../config/competition_rewards.dart';

class ChampionshipScoringService {
  const ChampionshipScoringService._();

  static int pointsForPlacement(int placement) {
    switch (placement) {
      case 1:
        return CompetitionRewards.weeklyRoundFirst;

      case 2:
        return CompetitionRewards.weeklyRoundSecond;

      case 3:
        return CompetitionRewards.weeklyRoundThird;

      case 4:
        return CompetitionRewards.weeklyRoundFourth;

      default:
        return CompetitionRewards.weeklyRoundParticipation;
    }
  }
}