class CompetitionPlayerResult {
  const CompetitionPlayerResult({
    required this.userId,
    required this.name,
    required this.gameScore,
    required this.placement,
    this.championshipPoints = 0,
  });

  final String userId;
  final String name;

  /// The score produced by the actual game.
  final int gameScore;

  /// 1 = first place
  /// 2 = second place
  /// 3 = third place
  /// etc.
  final int placement;

  /// Only used during Weekly Championship rounds.
  ///
  /// This is deliberately separate from:
  /// - gameScore
  /// - Tokens
  /// - permanent Ranking Points
  final int championshipPoints;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'gameScore': gameScore,
      'placement': placement,
      'championshipPoints': championshipPoints,
    };
  }

  factory CompetitionPlayerResult.fromMap(Map<String, dynamic> map) {
    return CompetitionPlayerResult(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? 'Family Member',
      gameScore: (map['gameScore'] as num?)?.toInt() ?? 0,
      placement: (map['placement'] as num?)?.toInt() ?? 0,
      championshipPoints:
          (map['championshipPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
