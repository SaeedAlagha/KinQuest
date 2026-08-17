import 'competition_player_result.dart';
import 'competition_type.dart';

class CompetitionRecord {
  const CompetitionRecord({
    required this.id,
    required this.familyId,
    required this.type,
    required this.periodKey,
    required this.gameId,
    required this.gameName,
    required this.players,
    this.winnerId,
    this.winnerName,
    this.completed = false,
    this.rewardGranted = false,
    this.tokenReward = 0,
    this.rankingPointReward = 0,
  });

  final String id;
  final String familyId;
  final CompetitionType type;

  /// Examples:
  ///
  /// Daily:
  /// 2026-08-17
  ///
  /// Weekly:
  /// 2026-W34
  ///
  /// Monthly:
  /// 2026-08
  final String periodKey;

  final String gameId;
  final String gameName;

  final List<CompetitionPlayerResult> players;

  final String? winnerId;
  final String? winnerName;

  final bool completed;

  /// Prevents an official reward from being granted twice.
  final bool rewardGranted;

  final int tokenReward;
  final int rankingPointReward;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'type': type.firestoreValue,
      'periodKey': periodKey,
      'gameId': gameId,
      'gameName': gameName,
      'players': players.map((player) => player.toMap()).toList(),
      'winnerId': winnerId,
      'winnerName': winnerName,
      'completed': completed,
      'rewardGranted': rewardGranted,
      'tokenReward': tokenReward,
      'rankingPointReward': rankingPointReward,
    };
  }
}