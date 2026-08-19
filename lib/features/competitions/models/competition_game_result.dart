import 'competition_player_result.dart';

class CompetitionGameResult {
  const CompetitionGameResult({
    required this.gameId,
    required this.gameName,
    required this.players,
    this.sharedWin = false,
  });

  final String gameId;
  final String gameName;
  final List<CompetitionPlayerResult> players;

  /// True when multiple first-place players are intentional winners
  /// because they won together as one team.
  ///
  /// Example:
  /// Team A wins Trivia:
  /// Sara  -> gameScore 1
  /// Dad   -> gameScore 1
  /// Ahmed -> gameScore 1
  ///
  /// These players are co-winners, NOT an unresolved tie.
  final bool sharedWin;

  bool get hasPlayers => players.isNotEmpty;

  int get highestScore {
    if (players.isEmpty) {
      return 0;
    }

    return players
        .map((player) => player.gameScore)
        .reduce((a, b) => a > b ? a : b);
  }

  List<CompetitionPlayerResult> get leaders {
    if (players.isEmpty) {
      return const [];
    }

    final topScore = highestScore;

    return players
        .where((player) => player.gameScore == topScore)
        .toList();
  }

  /// An intentional team victory is not an unresolved tie.
  bool get isTie => !sharedWin && leaders.length > 1;

  /// Individual results have one winner.
  ///
  /// A shared team victory deliberately has several winners, so callers
  /// that support team games should use [leaders] instead.
  CompetitionPlayerResult? get winner {
    if (isTie || leaders.length != 1) {
      return null;
    }

    return leaders.first;
  }
}
