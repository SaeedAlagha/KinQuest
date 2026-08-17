import 'competition_player_result.dart';

class CompetitionGameResult {
  const CompetitionGameResult({
    required this.gameId,
    required this.gameName,
    required this.players,
  });

  final String gameId;
  final String gameName;
  final List<CompetitionPlayerResult> players;

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

    return players.where((player) => player.gameScore == topScore).toList();
  }

  bool get isTie => leaders.length > 1;

  CompetitionPlayerResult? get winner {
    if (isTie || leaders.isEmpty) {
      return null;
    }

    return leaders.first;
  }
}
