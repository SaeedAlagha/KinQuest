import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../config/competition_rewards.dart';
import '../config/official_competition_games.dart';
import '../models/competition_game_result.dart';
import '../models/competition_player_result.dart';
import '../models/game_play_mode.dart';
import 'competition_tie_break_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _isLoading = true;
  bool _isSettling = false;
  bool _completedToday = false;
  bool _tieDetected = false;

  String? _familyId;
  String? _winnerName;
  String? _errorMessage;

  CompetitionGameResult? _latestResult;

  DateTime get _today => DateTime.now();

  String get _dateKey {
    final now = _today;

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String get _competitionId => 'daily_$_dateKey';

  late final OfficialCompetitionGame _game =
      OfficialCompetitionGames.dailyGameFor(_today);

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _isLoading = false;
      return;
    }

    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be signed in to use Daily Challenge.';
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
              'Join or create a family before playing Daily Challenge.';
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

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _completedToday = competitionDoc.exists && data?['completed'] == true;
        _winnerName = data?['winnerName'] as String?;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load today\'s Daily Challenge. Please try again.';
      });
    }
  }

  Future<void> _playChallenge() async {
    if (_completedToday || _isSettling) {
      return;
    }

    final result = await Navigator.of(context).push<CompetitionGameResult>(
      MaterialPageRoute(
        builder: (_) => _game.build(GamePlayMode.dailyChallenge),
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

    if (result.gameId != _game.gameId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The returned game result does not match today\'s challenge.',
          ),
        ),
      );

      return;
    }

    if (result.isTie) {
      setState(() {
        _latestResult = result;
        _tieDetected = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The top score is tied. No Daily reward has been granted yet.',
          ),
        ),
      );

      return;
    }

    await _settleResult(result);
  }

  Future<void> _runTieBreak() async {
    final result = _latestResult;

    if (result == null || !result.isTie || _isSettling) {
      return;
    }

    final winner = await Navigator.of(context).push<CompetitionPlayerResult>(
      MaterialPageRoute(
        builder: (_) => CompetitionTieBreakScreen(players: result.leaders),
      ),
    );

    if (!mounted || winner == null) {
      return;
    }

    await _settleResult(result, tieBreakWinner: winner);
  }

  Future<void> _settleResult(
    CompetitionGameResult result, {
    CompetitionPlayerResult? tieBreakWinner,
  }) async {
    if (_completedToday ||
        _isSettling ||
        (result.isTie && tieBreakWinner == null)) {
      return;
    }

    final familyId = _familyId;

    if (!widget.developerPreview && (familyId == null || familyId.isEmpty)) {
      return;
    }

    final rankedPlayers = List<CompetitionPlayerResult>.from(result.players);

    rankedPlayers.sort((a, b) => b.gameScore.compareTo(a.gameScore));

    if (rankedPlayers.isEmpty) {
      return;
    }

    final winner = tieBreakWinner ?? rankedPlayers.first;

    final runnersUp = <CompetitionPlayerResult>[];

    if (tieBreakWinner != null) {
      runnersUp.addAll(
        result.leaders.where((player) => player.userId != winner.userId),
      );
    } else if (rankedPlayers.length > 1) {
      final secondHighestScore = rankedPlayers[1].gameScore;

      runnersUp.addAll(
        rankedPlayers
            .skip(1)
            .where((player) => player.gameScore == secondHighestScore),
      );
    }

    setState(() {
      _isSettling = true;
      _tieDetected = false;
    });

    if (widget.developerPreview) {
      if (!mounted) return;

      setState(() {
        _latestResult = result;
        _winnerName = winner.name;
        _completedToday = true;
        _isSettling = false;
      });

      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final competitionRef = firestore
          .collection('families')
          .doc(familyId!)
          .collection('officialCompetitions')
          .doc(_competitionId);

      final settled = await firestore.runTransaction<bool>((transaction) async {
        final existingCompetition = await transaction.get(competitionRef);

        if (existingCompetition.exists) {
          return false;
        }

        transaction.set(competitionRef, {
          'id': _competitionId,
          'familyId': familyId,
          'type': 'daily',
          'periodKey': _dateKey,
          'gameId': result.gameId,
          'gameName': result.gameName,
          'players': rankedPlayers.map((player) => player.toMap()).toList(),
          'winnerId': winner.userId,
          'winnerName': winner.name,
          'tieBreakUsed': tieBreakWinner != null,
          if (tieBreakWinner != null) 'tieBreakWinnerId': tieBreakWinner.userId,
          'completed': true,
          'rewardGranted': true,
          'tokenReward': CompetitionRewards.dailyWinnerTokens,
          'rankingPointReward': CompetitionRewards.dailyWinnerRankingPoints,
          'completedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        for (final player in rankedPlayers) {
          final userRef = firestore.collection('users').doc(player.userId);

          final isWinner = player.userId == winner.userId;

          final isRunnerUp = runnersUp.any(
            (runnerUp) => runnerUp.userId == player.userId,
          );

          transaction.set(userRef, {
            'gamesPlayed': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
            if (isWinner) ...{
              'tokens': FieldValue.increment(
                CompetitionRewards.dailyWinnerTokens,
              ),
              'rankingPoints': FieldValue.increment(
                CompetitionRewards.dailyWinnerRankingPoints,
              ),
              'officialWins': FieldValue.increment(1),
              'dailyWins': FieldValue.increment(1),
              'dailyChallengesCompleted': FieldValue.increment(1),
            } else if (isRunnerUp) ...{
              'rankingPoints': FieldValue.increment(
                CompetitionRewards.dailyRunnerUpRankingPoints,
              ),
            },
          }, SetOptions(merge: true));
        }

        return true;
      });

      if (!mounted) return;

      if (!settled) {
        await _loadStatus();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Today\'s Daily Challenge has already been completed.',
            ),
          ),
        );

        return;
      }

      setState(() {
        _latestResult = result;
        _winnerName = winner.name;
        _completedToday = true;
        _isSettling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${winner.name} won today\'s Daily Challenge! '
            '+${CompetitionRewards.dailyWinnerTokens} Tokens and '
            '+${CompetitionRewards.dailyWinnerRankingPoints} Ranking Points.',
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
            'Could not save today\'s official result. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
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
            : _buildChallenge(),
      ),
    );
  }

  Widget _buildChallenge() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TODAY\'S OFFICIAL CHALLENGE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(_game.icon, size: 42, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _game.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _game.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: AppTheme.goldColor,
                            size: 34,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Official Daily rewards',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Winner: '
                                  '+${CompetitionRewards.dailyWinnerTokens} Tokens '
                                  '+ ${CompetitionRewards.dailyWinnerRankingPoints} Ranking Points',
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Runner-up: '
                                  '+${CompetitionRewards.dailyRunnerUpRankingPoints} Ranking Points',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        'One official result per family per day. '
                        'Quick Play results do not affect these rewards.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_completedToday)
                _buildCompletedCard()
              else if (_tieDetected)
                _buildTieCard()
              else
                FilledButton.icon(
                  onPressed: _isSettling ? null : _playChallenge,
                  icon: _isSettling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _isSettling
                        ? 'Saving official result...'
                        : 'Start Today\'s Challenge',
                  ),
                ),
              if (_latestResult != null) ...[
                const SizedBox(height: 24),
                _buildLatestResult(),
              ],
            ],
          ),
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
            Icons.check_circle_rounded,
            color: AppTheme.tealColor,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _winnerName == null
                  ? 'Your family completed today\'s official challenge.'
                  : '${_winnerName!} won today\'s official challenge. '
                        'Come back tomorrow for a new game.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTieCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.goldColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.balance_rounded,
            size: 36,
            color: AppTheme.goldColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Tie detected',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'No Tokens or Ranking Points have been awarded. '
            'Only the tied leaders advance to sudden death. '
            'No reward is granted until one winner remains.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSettling ? null : _runTieBreak,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Start Sudden-Death Tie-Break'),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestResult() {
    final result = _latestResult!;

    final rankedPlayers = List<CompetitionPlayerResult>.from(result.players);

    rankedPlayers.sort((a, b) => b.gameScore.compareTo(a.gameScore));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Latest Result',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ...List.generate(rankedPlayers.length, (index) {
              final player = rankedPlayers[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(player.name),
                trailing: Text(
                  '${player.gameScore} pts',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
