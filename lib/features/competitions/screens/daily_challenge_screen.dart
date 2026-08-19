import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sila_celebration_card.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';
import '../config/competition_rewards.dart';
import '../config/official_competition_games.dart';
import '../models/competition_game_result.dart';
import '../models/competition_player_result.dart';
import '../models/game_play_mode.dart';
import '../utils/competition_period.dart';
import 'competition_tie_break_screen.dart';

enum _DailyLoadError { signIn, family, load }

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
  String? _winnerId;
  String? _winnerName;
  _DailyLoadError? _loadError;

  CompetitionGameResult? _latestResult;

  DateTime get _today => DateTime.now();

  String get _dateKey => CompetitionPeriod.dailyKey(_today);

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
        _loadError = _DailyLoadError.signIn;
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
          _loadError = _DailyLoadError.family;
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

      final storedWinnerNames = data?['winnerNames'];

      final loadedWinnerName =
          storedWinnerNames is List && storedWinnerNames.isNotEmpty
          ? storedWinnerNames.whereType<String>().join(', ')
          : data?['winnerName'] as String?;
      final storedWinnerIds = data?['winnerIds'];
      final loadedWinnerId =
          storedWinnerIds is List && storedWinnerIds.isNotEmpty
          ? storedWinnerIds.whereType<String>().firstOrNull
          : data?['winnerId'] as String?;

      setState(() {
        _familyId = familyId;
        _completedToday = competitionDoc.exists && data?['completed'] == true;
        _winnerName = loadedWinnerName;
        _winnerId = loadedWinnerId;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _DailyLoadError.load;
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.gameNoValidResult),
        ),
      );

      return;
    }

    if (result.gameId != _game.gameId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyResultMismatch),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyTieRewardPending),
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

    final winners = result.sharedWin
        ? result.leaders
        : <CompetitionPlayerResult>[tieBreakWinner ?? rankedPlayers.first];

    final winner = winners.first;

    final runnersUp = <CompetitionPlayerResult>[];
    if (result.sharedWin) {
      // Team-result games deliberately have multiple winners.
      // Losing-team members are not Daily runners-up.
    } else if (tieBreakWinner != null) {
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
        _winnerId = winner.userId;
        _winnerName = result.sharedWin
            ? winners.map((player) => player.name).join(', ')
            : winner.name;
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
          'winnerIds': winners.map((player) => player.userId).toList(),
          'winnerNames': winners.map((player) => player.name).toList(),
          'sharedWin': result.sharedWin,
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

          final isWinner = winners.any(
            (winningPlayer) => winningPlayer.userId == player.userId,
          );

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
            } else if (isRunnerUp) ...{
              'rankingPoints': FieldValue.increment(
                CompetitionRewards.dailyRunnerUpRankingPoints,
              ),
            },
          }, SetOptions(merge: true));

          if (isWinner) {
            final tokenTransactionRef = userRef
                .collection('tokenTransactions')
                .doc();

            transaction.set(tokenTransactionRef, {
              'userId': player.userId,
              'familyId': familyId,
              'amount': CompetitionRewards.dailyWinnerTokens,
              'type': 'earned',
              'reason': 'Daily Challenge Winner',
              'relatedRewardId': null,
              'relatedRequestId': null,
              'relatedCompetitionId': _competitionId,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }

        return true;
      });

      if (!mounted) return;

      if (!settled) {
        await _loadStatus();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dailyAlreadyCompleted),
          ),
        );

        return;
      }

      setState(() {
        _latestResult = result;
        _winnerId = winner.userId;
        _winnerName = result.sharedWin
            ? winners.map((player) => player.name).join(', ')
            : winner.name;
        _completedToday = true;
        _isSettling = false;
      });

      final displayedWinnerNames = result.sharedWin
          ? winners.map((player) => player.name).join(', ')
          : winner.name;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.dailyWinnerAnnouncement(
              displayedWinnerNames,
              CompetitionRewards.dailyWinnerTokens,
              CompetitionRewards.dailyWinnerRankingPoints,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSettling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyOfficialSaveError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.dailyChallenge)),
      body: SilaPageBackdrop(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _loadErrorMessage(strings),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _buildChallenge(),
        ),
      ),
    );
  }

  String _loadErrorMessage(AppLocalizations strings) => switch (_loadError!) {
    _DailyLoadError.signIn => strings.dailyChallengeSignInRequired,
    _DailyLoadError.family => strings.dailyChallengeFamilyRequired,
    _DailyLoadError.load => strings.dailyChallengeLoadError,
  };

  Widget _buildChallenge() {
    final strings = AppLocalizations.of(context)!;

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
                    Text(
                      strings.todaysFamilyChallenge,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      _game.localizedName(strings),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _game.localizedDescription(strings),
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
                                  strings.dailyReward,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strings.dailyWinnerRewardSummary(
                                    CompetitionRewards.dailyWinnerTokens,
                                    CompetitionRewards.dailyWinnerRankingPoints,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.dailyRunnerUpRewardSummary(
                                    CompetitionRewards
                                        .dailyRunnerUpRankingPoints,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        strings.officialCompetitionRule,
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
                        ? strings.savingOfficialResult
                        : strings.playTodaysChallenge,
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
    final strings = AppLocalizations.of(context)!;
    final winner = _winnerName;

    return DigitalRewardStyleBuilder(
      userId: widget.developerPreview ? null : _winnerId,
      preview: widget.developerPreview
          ? const EquippedDigitalRewards(celebrationEffect: 'confetti')
          : null,
      builder: (context, digitalRewards) => SilaCelebrationCard(
        key: const ValueKey('daily-challenge-celebration'),
        eyebrow: strings.dailyOfficialCompleteEyebrow,
        title: winner ?? strings.familyChallengeCompleteTitle,
        subtitle: winner == null
            ? strings.dailyCompleteWithoutWinner
            : strings.dailyCompleteWithWinner(winner),
        effect: digitalRewards.celebrationEffect,
        rewards: [
          SilaCelebrationReward(
            icon: Icons.stars_rounded,
            label: strings.tokenBonus(CompetitionRewards.dailyWinnerTokens),
          ),
          SilaCelebrationReward(
            icon: Icons.trending_up_rounded,
            label: strings.rankingPointBonus(
              CompetitionRewards.dailyWinnerRankingPoints,
            ),
          ),
          SilaCelebrationReward(
            icon: Icons.favorite_rounded,
            label: strings.familyMoment,
          ),
        ],
      ),
    );
  }

  Widget _buildTieCard() {
    final strings = AppLocalizations.of(context)!;

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
            strings.tieDetected,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            strings.tieRewardPendingDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSettling ? null : _runTieBreak,
            icon: const Icon(Icons.bolt_rounded),
            label: Text(strings.startSuddenDeathTieBreak),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestResult() {
    final strings = AppLocalizations.of(context)!;
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
              strings.latestResult,
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
                  strings.pointsAbbreviation(player.gameScore),
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
