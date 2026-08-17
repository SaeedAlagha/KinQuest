import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../config/competition_rewards.dart';
import '../config/official_competition_games.dart';
import '../models/competition_game_result.dart';
import '../models/competition_player_result.dart';
import '../models/game_play_mode.dart';
import '../services/championship_scoring_service.dart';
import 'competition_tie_break_screen.dart';

class WeeklyChampionshipScreen extends StatefulWidget {
  const WeeklyChampionshipScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<WeeklyChampionshipScreen> createState() =>
      _WeeklyChampionshipScreenState();
}

class _WeeklyChampionshipScreenState extends State<WeeklyChampionshipScreen> {
  static const int _totalGames = 4;

  bool _isLoading = true;
  bool _isSavingRound = false;
  bool _isSettling = false;
  bool _completed = false;

  String? _familyId;
  String? _championName;
  String? _errorMessage;

  final List<_WeeklyRoundRecord> _rounds = [];

  late final List<OfficialCompetitionGame> _weeklyGames = _gamesForWeek();

  DateTime get _today => DateTime.now();

  DateTime get _weekMonday {
    final date = DateTime(_today.year, _today.month, _today.day);

    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  int get _isoWeekYear {
    final thursday = _weekMonday.add(const Duration(days: 3));
    return thursday.year;
  }

  int get _isoWeekNumber {
    final thursday = _weekMonday.add(const Duration(days: 3));

    final firstThursday = DateTime(thursday.year, 1, 4);

    final firstWeekThursday = firstThursday.add(
      Duration(days: DateTime.thursday - firstThursday.weekday),
    );

    return 1 + thursday.difference(firstWeekThursday).inDays ~/ 7;
  }

  String get _weekKey =>
      '$_isoWeekYear-W${_isoWeekNumber.toString().padLeft(2, '0')}';

  String get _competitionId => 'weekly_$_weekKey';

  int get _nextGameIndex => _rounds.length;

  bool get _allGamesFinished => _rounds.length >= _totalGames;

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _isLoading = false;
      return;
    }

    _loadStatus();
  }

  List<OfficialCompetitionGame> _gamesForWeek() {
    final pool = OfficialCompetitionGames.dailyPool;

    if (pool.length <= _totalGames) {
      return List<OfficialCompetitionGame>.from(pool);
    }

    final monday = _weekMonday;

    final weekNumber =
        monday.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay ~/ 7;

    final startIndex = weekNumber % pool.length;

    return List.generate(
      _totalGames,
      (index) => pool[(startIndex + index) % pool.length],
    );
  }

  Future<void> _loadStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be signed in to use Weekly Championship.';
      });

      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage =
              'Join or create a family before playing Weekly Championship.';
        });

        return;
      }

      final competitionDoc = await firestore
          .collection('families')
          .doc(familyId)
          .collection('officialCompetitions')
          .doc(_competitionId)
          .get();

      final data = competitionDoc.data();

      final loadedRounds = <_WeeklyRoundRecord>[];

      final rawRounds = data?['rounds'];

      if (rawRounds is List) {
        for (final rawRound in rawRounds) {
          if (rawRound is Map) {
            loadedRounds.add(
              _WeeklyRoundRecord.fromMap(Map<String, dynamic>.from(rawRound)),
            );
          }
        }
      }

      loadedRounds.sort((a, b) => a.roundIndex.compareTo(b.roundIndex));

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _rounds
          ..clear()
          ..addAll(loadedRounds);

        _completed = competitionDoc.exists && data?['completed'] == true;

        _championName = data?['winnerName'] as String?;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load this week\'s championship. Please try again.';
      });
    }
  }

  Future<void> _playNextGame() async {
    if (_completed || _isSavingRound || _isSettling || _allGamesFinished) {
      return;
    }

    final roundIndex = _nextGameIndex;
    final game = _weeklyGames[roundIndex];

    final result = await Navigator.of(context).push<CompetitionGameResult>(
      MaterialPageRoute(
        builder: (_) => game.build(GamePlayMode.weeklyChampionship),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (!result.hasPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The game finished without a valid player result.'),
        ),
      );
      return;
    }

    if (result.gameId != game.gameId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The returned result does not match this championship round.',
          ),
        ),
      );
      return;
    }

    final scoredResult = _scoreRound(roundIndex: roundIndex, result: result);

    await _saveRound(scoredResult);
  }

  _WeeklyRoundRecord _scoreRound({
    required int roundIndex,
    required CompetitionGameResult result,
  }) {
    final players = List<CompetitionPlayerResult>.from(result.players);

    players.sort((a, b) => b.gameScore.compareTo(a.gameScore));

    final scoredPlayers = <CompetitionPlayerResult>[];

    var previousScore = 0;
    var placement = 0;

    for (var index = 0; index < players.length; index++) {
      final player = players[index];

      if (index == 0 || player.gameScore != previousScore) {
        placement = index + 1;
      }

      previousScore = player.gameScore;

      scoredPlayers.add(
        CompetitionPlayerResult(
          userId: player.userId,
          name: player.name,
          gameScore: player.gameScore,
          placement: placement,
          championshipPoints: ChampionshipScoringService.pointsForPlacement(
            placement,
          ),
        ),
      );
    }

    return _WeeklyRoundRecord(
      roundIndex: roundIndex,
      gameId: result.gameId,
      gameName: result.gameName,
      players: scoredPlayers,
    );
  }

  Future<void> _saveRound(_WeeklyRoundRecord round) async {
    if (_isSavingRound || _completed) {
      return;
    }

    setState(() {
      _isSavingRound = true;
    });

    if (widget.developerPreview) {
      if (!mounted) return;

      setState(() {
        _rounds.add(round);
        _isSavingRound = false;
      });

      if (_allGamesFinished) {
        await _finishChampionship();
      }

      return;
    }

    final familyId = _familyId;

    if (familyId == null || familyId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isSavingRound = false;
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final competitionRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('officialCompetitions')
          .doc(_competitionId);

      final saved = await firestore.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(competitionRef);
        final existingData = existing.data();

        if (existingData?['completed'] == true) {
          return false;
        }

        final existingRounds = <dynamic>[];

        final rawExistingRounds = existingData?['rounds'];

        if (rawExistingRounds is List) {
          existingRounds.addAll(rawExistingRounds);
        }

        final alreadySaved = existingRounds.any((raw) {
          if (raw is! Map) {
            return false;
          }

          return raw['roundIndex'] == round.roundIndex;
        });

        if (alreadySaved) {
          return false;
        }

        existingRounds.add(round.toMap());

        transaction.set(competitionRef, {
          'id': _competitionId,
          'familyId': familyId,
          'type': 'weekly',
          'periodKey': _weekKey,
          'completed': false,
          'rewardGranted': false,
          'gameIds': _weeklyGames.map((game) => game.gameId).toList(),
          'rounds': existingRounds,
          'updatedAt': FieldValue.serverTimestamp(),
          if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      });

      if (!mounted) return;

      if (!saved) {
        setState(() {
          _isSavingRound = false;
        });

        await _loadStatus();
        return;
      }

      setState(() {
        _rounds.add(round);
        _isSavingRound = false;
      });

      if (_allGamesFinished) {
        await _finishChampionship();
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSavingRound = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save this championship round. Please try again.',
          ),
        ),
      );
    }
  }

  List<_WeeklyStanding> _buildStandings() {
    final standings = <String, _WeeklyStanding>{};

    for (final round in _rounds) {
      for (final player in round.players) {
        final existing = standings[player.userId];

        if (existing == null) {
          standings[player.userId] = _WeeklyStanding(
            userId: player.userId,
            name: player.name,
            championshipPoints: player.championshipPoints,
            roundsPlayed: 1,
          );
        } else {
          standings[player.userId] = existing.copyWith(
            championshipPoints:
                existing.championshipPoints + player.championshipPoints,
            roundsPlayed: existing.roundsPlayed + 1,
          );
        }
      }
    }

    final ranked = standings.values.toList();

    ranked.sort((a, b) {
      final pointsCompare = b.championshipPoints.compareTo(
        a.championshipPoints,
      );

      if (pointsCompare != 0) {
        return pointsCompare;
      }

      return a.name.compareTo(b.name);
    });

    return ranked;
  }

  Future<void> _finishChampionship() async {
    if (!_allGamesFinished || _completed || _isSettling) {
      return;
    }

    final standings = _buildStandings();

    if (standings.isEmpty) {
      return;
    }

    final highestPoints = standings.first.championshipPoints;

    final leaders = standings
        .where((standing) => standing.championshipPoints == highestPoints)
        .toList();

    CompetitionPlayerResult? tieBreakWinner;

    if (leaders.length > 1) {
      tieBreakWinner = await Navigator.of(context)
          .push<CompetitionPlayerResult>(
            MaterialPageRoute(
              builder: (_) => CompetitionTieBreakScreen(
                players: leaders
                    .map(
                      (standing) => CompetitionPlayerResult(
                        userId: standing.userId,
                        name: standing.name,
                        gameScore: standing.championshipPoints,
                        placement: 1,
                        championshipPoints: standing.championshipPoints,
                      ),
                    )
                    .toList(),
              ),
            ),
          );

      if (!mounted || tieBreakWinner == null) {
        return;
      }
    }

    final championId = tieBreakWinner?.userId ?? standings.first.userId;

    await _settleChampionship(
      standings: standings,
      championId: championId,
      tieBreakUsed: tieBreakWinner != null,
    );
  }

  Future<void> _settleChampionship({
    required List<_WeeklyStanding> standings,
    required String championId,
    required bool tieBreakUsed,
  }) async {
    if (_completed || _isSettling) {
      return;
    }

    final champion = standings.firstWhere(
      (standing) => standing.userId == championId,
    );

    final orderedStandings = List<_WeeklyStanding>.from(standings);

    orderedStandings.removeWhere((standing) => standing.userId == championId);

    orderedStandings.insert(0, champion);

    setState(() {
      _isSettling = true;
    });

    if (widget.developerPreview) {
      if (!mounted) return;

      setState(() {
        _championName = champion.name;
        _completed = true;
        _isSettling = false;
      });

      return;
    }

    final familyId = _familyId;

    if (familyId == null || familyId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isSettling = false;
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final competitionRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('officialCompetitions')
          .doc(_competitionId);

      final settled = await firestore.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(competitionRef);

        if (existing.data()?['completed'] == true) {
          return false;
        }

        final placements = _finalPlacements(orderedStandings);

        transaction.set(competitionRef, {
          'completed': true,
          'rewardGranted': true,
          'winnerId': champion.userId,
          'winnerName': champion.name,
          'tieBreakUsed': tieBreakUsed,
          if (tieBreakUsed) 'tieBreakWinnerId': champion.userId,
          'standings': placements.map((standing) => standing.toMap()).toList(),
          'tokenReward': CompetitionRewards.weeklyChampionTokens,
          'rankingPointReward': CompetitionRewards.weeklyChampionRankingPoints,
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final placement in placements) {
          final userRef = firestore.collection('users').doc(placement.userId);

          final rankingReward = _rankingRewardForPlacement(placement.placement);

          transaction.set(userRef, {
            'gamesPlayed': FieldValue.increment(placement.roundsPlayed),
            'rankingPoints': FieldValue.increment(rankingReward),
            'updatedAt': FieldValue.serverTimestamp(),
            if (placement.userId == champion.userId) ...{
              'tokens': FieldValue.increment(
                CompetitionRewards.weeklyChampionTokens,
              ),
              'officialWins': FieldValue.increment(1),
              'weeklyWins': FieldValue.increment(1),
            },
          }, SetOptions(merge: true));
        }

        return true;
      });

      if (!mounted) return;

      if (!settled) {
        setState(() {
          _isSettling = false;
        });

        await _loadStatus();
        return;
      }

      setState(() {
        _championName = champion.name;
        _completed = true;
        _isSettling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${champion.name} is this week\'s Family Champion! '
            '+${CompetitionRewards.weeklyChampionTokens} Tokens and '
            '+${CompetitionRewards.weeklyChampionRankingPoints} Ranking Points.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSettling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not finalize the Weekly Championship. Please try again.',
          ),
        ),
      );
    }
  }

  List<_FinalWeeklyStanding> _finalPlacements(List<_WeeklyStanding> ordered) {
    final result = <_FinalWeeklyStanding>[];

    var previousPoints = -1;
    var placement = 0;

    for (var index = 0; index < ordered.length; index++) {
      final standing = ordered[index];

      if (index == 0) {
        placement = 1;
      } else if (standing.championshipPoints != previousPoints) {
        placement = index + 1;
      }

      previousPoints = standing.championshipPoints;

      result.add(
        _FinalWeeklyStanding(
          userId: standing.userId,
          name: standing.name,
          championshipPoints: standing.championshipPoints,
          roundsPlayed: standing.roundsPlayed,
          placement: placement,
        ),
      );
    }

    return result;
  }

  int _rankingRewardForPlacement(int placement) {
    switch (placement) {
      case 1:
        return CompetitionRewards.weeklyChampionRankingPoints;
      case 2:
        return CompetitionRewards.weeklyRunnerUpRankingPoints;
      case 3:
        return CompetitionRewards.weeklyThirdPlaceRankingPoints;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Championship')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_errorMessage!, textAlign: TextAlign.center),
                ),
              )
            : _buildChampionship(),
      ),
    );
  }

  Widget _buildChampionship() {
    final standings = _buildStandings();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 14),
              const Text(
                'WEEKLY CHAMPIONSHIP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _weekKey,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Four official games. Championship Points accumulate across every round.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.88)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Championship rewards',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Champion: +${CompetitionRewards.weeklyChampionTokens} Tokens '
                  '+ ${CompetitionRewards.weeklyChampionRankingPoints} RP',
                ),
                Text(
                  'Runner-up: +${CompetitionRewards.weeklyRunnerUpRankingPoints} RP',
                ),
                Text(
                  'Third place: +${CompetitionRewards.weeklyThirdPlaceRankingPoints} RP',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Round points: 1st 10 • 2nd 7 • 3rd 5 • 4th 3 • participation 1',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'This week\'s games',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...List.generate(_weeklyGames.length, (index) {
          final game = _weeklyGames[index];
          final completed = index < _rounds.length;
          final current = !_completed && index == _nextGameIndex;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: completed
                    ? const Icon(Icons.check_rounded)
                    : Text('${index + 1}'),
              ),
              title: Text(game.name),
              subtitle: Text(
                completed
                    ? 'Round complete'
                    : current
                    ? 'Up next'
                    : 'Locked until previous round is complete',
              ),
              trailing: completed
                  ? const Icon(Icons.check_circle_rounded)
                  : current
                  ? const Icon(Icons.play_arrow_rounded)
                  : const Icon(Icons.lock_outline_rounded),
            ),
          );
        }),
        const SizedBox(height: 20),
        if (_completed)
          _buildCompletedCard()
        else if (!_allGamesFinished)
          FilledButton.icon(
            onPressed: _isSavingRound || _isSettling ? null : _playNextGame,
            icon: _isSavingRound
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(
              _isSavingRound
                  ? 'Saving round...'
                  : 'Play Game ${_nextGameIndex + 1}: '
                        '${_weeklyGames[_nextGameIndex].name}',
            ),
          )
        else
          FilledButton.icon(
            onPressed: _isSettling ? null : _finishChampionship,
            icon: const Icon(Icons.emoji_events_rounded),
            label: Text(
              _isSettling
                  ? 'Finalizing championship...'
                  : 'Finalize Weekly Championship',
            ),
          ),
        if (standings.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildStandingsCard(standings),
        ],
      ],
    );
  }

  Widget _buildStandingsCard(List<_WeeklyStanding> standings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Championship Standings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...List.generate(standings.length, (index) {
              final standing = standings[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(standing.name),
                subtitle: Text(
                  '${standing.roundsPlayed} round'
                  '${standing.roundsPlayed == 1 ? '' : 's'} played',
                ),
                trailing: Text(
                  '${standing.championshipPoints} pts',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.tealColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppTheme.tealColor,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _championName == null
                  ? 'This week\'s championship is complete.'
                  : '${_championName!} is this week\'s Family Champion!',
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRoundRecord {
  const _WeeklyRoundRecord({
    required this.roundIndex,
    required this.gameId,
    required this.gameName,
    required this.players,
  });

  final int roundIndex;
  final String gameId;
  final String gameName;
  final List<CompetitionPlayerResult> players;

  Map<String, dynamic> toMap() {
    return {
      'roundIndex': roundIndex,
      'gameId': gameId,
      'gameName': gameName,
      'players': players.map((player) => player.toMap()).toList(),
    };
  }

  factory _WeeklyRoundRecord.fromMap(Map<String, dynamic> map) {
    final players = <CompetitionPlayerResult>[];

    final rawPlayers = map['players'];

    if (rawPlayers is List) {
      for (final rawPlayer in rawPlayers) {
        if (rawPlayer is Map) {
          players.add(
            CompetitionPlayerResult.fromMap(
              Map<String, dynamic>.from(rawPlayer),
            ),
          );
        }
      }
    }

    return _WeeklyRoundRecord(
      roundIndex: (map['roundIndex'] as num?)?.toInt() ?? 0,
      gameId: map['gameId'] as String? ?? '',
      gameName: map['gameName'] as String? ?? 'Official Game',
      players: players,
    );
  }
}

class _WeeklyStanding {
  const _WeeklyStanding({
    required this.userId,
    required this.name,
    required this.championshipPoints,
    required this.roundsPlayed,
  });

  final String userId;
  final String name;
  final int championshipPoints;
  final int roundsPlayed;

  _WeeklyStanding copyWith({int? championshipPoints, int? roundsPlayed}) {
    return _WeeklyStanding(
      userId: userId,
      name: name,
      championshipPoints: championshipPoints ?? this.championshipPoints,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
    );
  }
}

class _FinalWeeklyStanding {
  const _FinalWeeklyStanding({
    required this.userId,
    required this.name,
    required this.championshipPoints,
    required this.roundsPlayed,
    required this.placement,
  });

  final String userId;
  final String name;
  final int championshipPoints;
  final int roundsPlayed;
  final int placement;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'championshipPoints': championshipPoints,
      'roundsPlayed': roundsPlayed,
      'placement': placement,
    };
  }
}
