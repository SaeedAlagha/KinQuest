import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sila_celebration_card.dart';
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

enum _MonthlyLoadError { signIn, family, load }

class MonthlyCupScreen extends StatefulWidget {
  const MonthlyCupScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<MonthlyCupScreen> createState() => _MonthlyCupScreenState();
}

class _MonthlyCupScreenState extends State<MonthlyCupScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _started = false;
  bool _completed = false;

  String? _familyId;
  _MonthlyLoadError? _loadError;

  final List<_MonthlyPlayer> _familyMembers = [];
  final Set<String> _selectedIds = {};
  final List<_MonthlyMatch> _matches = [];

  String? _championId;
  String? _championName;
  String? _runnerUpName;
  final List<String> _semifinalistNames = [];

  DateTime get _today => DateTime.now();

  String get _monthKey => CompetitionPeriod.monthlyKey(_today);

  String get _competitionId => 'monthly_$_monthKey';

  bool get _tournamentStarted => _started;
  List<_MonthlyPlayer> get _selectedPlayers => _familyMembers
      .where((player) => _selectedIds.contains(player.id))
      .toList();

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadPreview();
    } else {
      _loadData();
    }
  }

  void _loadPreview() {
    const previewPlayers = [
      _MonthlyPlayer(id: 'preview-1', name: 'Alex'),
      _MonthlyPlayer(id: 'preview-2', name: 'Sam'),
      _MonthlyPlayer(id: 'preview-3', name: 'Jordan'),
      _MonthlyPlayer(id: 'preview-4', name: 'Taylor'),
    ];

    setState(() {
      _familyMembers
        ..clear()
        ..addAll(previewPlayers);

      _selectedIds
        ..clear()
        ..addAll(previewPlayers.map((player) => player.id));

      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _MonthlyLoadError.signIn;
      });

      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      final familyId = userDoc.data()?['familyId']?.toString();

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _loadError = _MonthlyLoadError.family;
        });

        return;
      }

      final membersSnapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) return;

      final strings = AppLocalizations.of(context)!;

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name']?.toString().trim();
        final email = data['email']?.toString().trim();

        return _MonthlyPlayer(
          id: document.id,
          name: name?.isNotEmpty == true
              ? name!
              : email?.isNotEmpty == true
              ? email!
              : strings.familyMemberFallback,
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      final competitionDoc = await firestore
          .collection('families')
          .doc(familyId)
          .collection('officialCompetitions')
          .doc(_competitionId)
          .get();

      final data = competitionDoc.data();

      final storedParticipantIds = <String>{};

      final rawParticipantIds = data?['participantIds'];

      if (rawParticipantIds is List) {
        storedParticipantIds.addAll(rawParticipantIds.whereType<String>());
      }

      final storedMatches = <_MonthlyMatch>[];

      final rawMatches = data?['matches'];

      if (rawMatches is List) {
        for (final rawMatch in rawMatches) {
          if (rawMatch is Map) {
            storedMatches.add(
              _MonthlyMatch.fromMap(Map<String, dynamic>.from(rawMatch)),
            );
          }
        }
      }

      final storedSemifinalistNames = <String>[];

      final rawSemifinalistNames = data?['semifinalistNames'];

      if (rawSemifinalistNames is List) {
        storedSemifinalistNames.addAll(
          rawSemifinalistNames.whereType<String>(),
        );
      }

      if (!mounted) return;

      setState(() {
        _familyId = familyId;

        _familyMembers
          ..clear()
          ..addAll(members);

        _selectedIds
          ..clear()
          ..addAll(storedParticipantIds);

        _matches
          ..clear()
          ..addAll(storedMatches);
        _started =
            storedParticipantIds.length >= 2 ||
            storedMatches.isNotEmpty ||
            data?['completed'] == true;

        _completed = data?['completed'] == true;
        _championId = data?['winnerId'] as String?;
        _championName = data?['winnerName'] as String?;
        _runnerUpName = data?['runnerUpName'] as String?;
        _semifinalistNames
          ..clear()
          ..addAll(storedSemifinalistNames);

        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _MonthlyLoadError.load;
      });
    }
  }

  void _togglePlayer(String id) {
    if (_tournamentStarted || _completed) return;

    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _startTournament() async {
    if (_selectedIds.length < 2) {
      _showMessage('Select at least 2 family members.');
      return;
    }

    if (widget.developerPreview) {
      setState(() {
        _started = true;
      });
      return;
    }

    final familyId = _familyId;

    if (familyId == null || familyId.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final competitionRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('officialCompetitions')
          .doc(_competitionId);

      final started = await firestore.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(competitionRef);
        final data = existing.data();

        if (data?['completed'] == true) {
          return false;
        }

        final existingParticipantIds = data?['participantIds'];
        final existingMatches = data?['matches'];

        final alreadyStarted =
            existingParticipantIds is List &&
                existingParticipantIds.isNotEmpty ||
            existingMatches is List && existingMatches.isNotEmpty;

        if (alreadyStarted) {
          return false;
        }

        transaction.set(competitionRef, {
          'id': _competitionId,
          'familyId': familyId,
          'type': 'monthly',
          'periodKey': _monthKey,
          'participantIds': _selectedIds.toList(),
          'completed': false,
          'rewardGranted': false,
          'matches': <Map<String, dynamic>>[],
          'updatedAt': FieldValue.serverTimestamp(),
          if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      });

      if (!started) {
        if (!mounted) return;

        setState(() {
          _started = true;
          _isSaving = false;
        });
        await _loadData();
        return;
      }

      if (!mounted) return;

      setState(() {
        _started = true;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(AppLocalizations.of(context)!.monthlyStartError);
    }
  }

  OfficialCompetitionGame _gameForMatch(int matchIndex) {
    final pool = OfficialCompetitionGames.monthlyPool;

    final offset = _today.month + _today.year;

    return pool[(offset + matchIndex) % pool.length];
  }

  Future<void> _playMatch({
    required int matchIndex,
    required _MonthlyPlayer player1,
    required _MonthlyPlayer player2,
  }) async {
    if (_isSaving || _completed) return;

    final game = _gameForMatch(matchIndex);

    final participantIds = {player1.id, player2.id};

    final result = await Navigator.of(context).push<CompetitionGameResult>(
      MaterialPageRoute(
        builder: (_) => game.build(
          GamePlayMode.monthlyCup,
          participantIds: widget.developerPreview ? null : participantIds,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (!result.hasPlayers) {
      _showMessage(AppLocalizations.of(context)!.gameNoValidResult);
      return;
    }

    if (result.gameId != game.gameId) {
      _showMessage(AppLocalizations.of(context)!.monthlyResultMismatch);
      return;
    }

    CompetitionPlayerResult winner;

    if (result.isTie) {
      final tieBreakWinner = await Navigator.of(context)
          .push<CompetitionPlayerResult>(
            MaterialPageRoute(
              builder: (_) =>
                  CompetitionTieBreakScreen(players: result.leaders),
            ),
          );

      if (!mounted || tieBreakWinner == null) {
        return;
      }

      winner = tieBreakWinner;
    } else {
      winner = result.leaders.first;
    }

    if (!participantIds.contains(winner.userId)) {
      _showMessage(AppLocalizations.of(context)!.monthlyInvalidWinner);
      return;
    }

    final loserId = winner.userId == player1.id ? player2.id : player1.id;

    final loserName = winner.userId == player1.id ? player2.name : player1.name;

    final match = _MonthlyMatch(
      matchIndex: matchIndex,
      gameId: game.gameId,
      gameName: game.name,
      player1Id: player1.id,
      player1Name: player1.name,
      player2Id: player2.id,
      player2Name: player2.name,
      winnerId: winner.userId,
      winnerName: winner.name,
      loserId: loserId,
      loserName: loserName,
    );

    await _saveMatch(match);
  }

  Future<void> _saveMatch(_MonthlyMatch match) async {
    if (_matches.any((existing) => existing.matchIndex == match.matchIndex)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    if (widget.developerPreview) {
      setState(() {
        _matches.add(match);
        _matches.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
        _isSaving = false;
      });

      if (_matches.length == _selectedPlayers.length - 1) {
        await _finishCup();
      }

      return;
    }

    final familyId = _familyId;

    if (familyId == null || familyId.isEmpty) {
      setState(() {
        _isSaving = false;
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
        final data = existing.data();

        if (data?['completed'] == true) {
          return false;
        }

        final matches = <dynamic>[];

        final rawMatches = data?['matches'];

        if (rawMatches is List) {
          matches.addAll(rawMatches);
        }

        final alreadySaved = matches.any((raw) {
          if (raw is! Map) return false;

          return raw['matchIndex'] == match.matchIndex;
        });

        if (alreadySaved) {
          return false;
        }

        matches.add(match.toMap());

        transaction.set(competitionRef, {
          'matches': matches,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      });

      if (!mounted) return;

      if (!saved) {
        setState(() {
          _isSaving = false;
        });

        await _loadData();
        return;
      }

      setState(() {
        _matches.add(match);
        _matches.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
        _isSaving = false;
      });

      if (_matches.length == _selectedPlayers.length - 1) {
        await _finishCup();
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(AppLocalizations.of(context)!.monthlyMatchSaveError);
    }
  }

  Future<void> _finishCup() async {
    final totalMatches = _selectedPlayers.length - 1;

    if (_matches.length < totalMatches || _completed || _isSaving) {
      return;
    }

    final sortedMatches = List<_MonthlyMatch>.from(_matches)
      ..sort((a, b) => a.matchIndex.compareTo(b.matchIndex));

    final finalMatch = sortedMatches.last;

    final championId = finalMatch.winnerId;
    final championName = finalMatch.winnerName;
    final runnerUpId = finalMatch.loserId;
    final runnerUpName = finalMatch.loserName;

    final rounds = _buildRounds();

    final semifinalMatches = rounds.length >= 2
        ? rounds[rounds.length - 2].matches
        : <_MonthlyRoundMatch>[];

    final semifinalLoserIds = semifinalMatches
        .map((roundMatch) => roundMatch.savedMatch?.loserId)
        .whereType<String>()
        .toList();

    final semifinalLoserNames = semifinalMatches
        .map((roundMatch) => roundMatch.savedMatch?.loserName)
        .whereType<String>()
        .toList();

    final gamesPlayedByUser = <String, int>{};

    for (final match in _matches) {
      gamesPlayedByUser.update(
        match.player1Id,
        (currentValue) => currentValue + 1,
        ifAbsent: () => 1,
      );

      gamesPlayedByUser.update(
        match.player2Id,
        (currentValue) => currentValue + 1,
        ifAbsent: () => 1,
      );
    }

    setState(() {
      _isSaving = true;
    });

    if (widget.developerPreview) {
      setState(() {
        _championId = championId;
        _championName = championName;
        _runnerUpName = runnerUpName;

        _semifinalistNames
          ..clear()
          ..addAll(semifinalLoserNames);

        _completed = true;
        _isSaving = false;
      });

      return;
    }

    final familyId = _familyId;

    if (familyId == null || familyId.isEmpty) {
      setState(() {
        _isSaving = false;
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

      final trophyRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('trophies')
          .doc(_competitionId);

      final settled = await firestore.runTransaction<bool>((transaction) async {
        final existing = await transaction.get(competitionRef);

        if (existing.data()?['completed'] == true) {
          return false;
        }

        transaction.set(competitionRef, {
          'completed': true,
          'rewardGranted': true,
          'winnerId': championId,
          'winnerName': championName,
          'runnerUpId': runnerUpId,
          'runnerUpName': runnerUpName,
          'semifinalistIds': semifinalLoserIds,
          'semifinalistNames': semifinalLoserNames,
          'tokenReward': CompetitionRewards.monthlyChampionTokens,
          'championRankingPointReward':
              CompetitionRewards.monthlyChampionRankingPoints,
          'runnerUpRankingPointReward':
              CompetitionRewards.monthlyRunnerUpRankingPoints,
          'semifinalistRankingPointReward':
              CompetitionRewards.monthlySemifinalistRankingPoints,
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final entry in gamesPlayedByUser.entries) {
          final userRef = firestore.collection('users').doc(entry.key);

          transaction.set(userRef, {
            'gamesPlayed': FieldValue.increment(entry.value),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        final championRef = firestore.collection('users').doc(championId);

        transaction.set(championRef, {
          'tokens': FieldValue.increment(
            CompetitionRewards.monthlyChampionTokens,
          ),
          'rankingPoints': FieldValue.increment(
            CompetitionRewards.monthlyChampionRankingPoints,
          ),
          'officialWins': FieldValue.increment(1),
          'monthlyWins': FieldValue.increment(1),
          'trophies': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final tokenTransactionRef = championRef
            .collection('tokenTransactions')
            .doc();

        transaction.set(tokenTransactionRef, {
          'userId': championId,
          'familyId': familyId,
          'amount': CompetitionRewards.monthlyChampionTokens,
          'type': 'earned',
          'reason': 'Monthly Cup Champion',
          'relatedRewardId': null,
          'relatedRequestId': null,
          'relatedCompetitionId': _competitionId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final runnerUpRef = firestore.collection('users').doc(runnerUpId);

        transaction.set(runnerUpRef, {
          'rankingPoints': FieldValue.increment(
            CompetitionRewards.monthlyRunnerUpRankingPoints,
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final semifinalistId in semifinalLoserIds) {
          final semifinalistRef = firestore
              .collection('users')
              .doc(semifinalistId);

          transaction.set(semifinalistRef, {
            'rankingPoints': FieldValue.increment(
              CompetitionRewards.monthlySemifinalistRankingPoints,
            ),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        transaction.set(trophyRef, {
          'id': _competitionId,
          'type': 'monthlyCup',
          'monthKey': _monthKey,
          'title': 'Monthly Cup Champion',
          'winnerId': championId,
          'winnerName': championName,
          'familyId': familyId,
          'earnedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (!mounted) return;

      if (!settled) {
        setState(() {
          _isSaving = false;
        });

        await _loadData();
        return;
      }

      setState(() {
        _championId = championId;
        _championName = championName;
        _runnerUpName = runnerUpName;

        _semifinalistNames
          ..clear()
          ..addAll(semifinalLoserNames);

        _completed = true;
        _isSaving = false;
      });

      _showMessage(
        AppLocalizations.of(context)!.monthlyWinnerAnnouncement(
          championName,
          CompetitionRewards.monthlyChampionTokens,
          CompetitionRewards.monthlyChampionRankingPoints,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(AppLocalizations.of(context)!.monthlyFinalizeError);
    }
  }

  _MonthlyPlayer _playerById(String id) {
    return _familyMembers.firstWhere((player) => player.id == id);
  }

  _MonthlyMatch? _matchByIndex(int index) {
    for (final match in _matches) {
      if (match.matchIndex == index) {
        return match;
      }
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.monthlyCup)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56),
            const SizedBox(height: 16),
            Text(_loadErrorMessage(strings), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: _loadData, child: Text(strings.tryAgain)),
          ],
        ),
      ),
    );
  }

  String _loadErrorMessage(AppLocalizations strings) => switch (_loadError!) {
    _MonthlyLoadError.signIn => strings.monthlySignInRequired,
    _MonthlyLoadError.family => strings.monthlyFamilyRequired,
    _MonthlyLoadError.load => strings.monthlyLoadError,
  };

  Widget _buildContent() {
    if (_completed) {
      return _buildCompletedCup();
    }

    if (!_tournamentStarted) {
      return _buildSetup();
    }

    return _buildBracket();
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradientFor(context),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 68,
                color: Colors.white,
              ),
              const SizedBox(height: 14),
              Text(
                strings.monthlyCup.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _monthKey,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.monthlyCompetitionDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
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
                  strings.monthlyRewards,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.monthlyChampionRewardSummary(
                    CompetitionRewards.monthlyChampionTokens,
                    CompetitionRewards.monthlyChampionRankingPoints,
                  ),
                ),
                Text(
                  strings.runnerUpRewardSummary(
                    CompetitionRewards.monthlyRunnerUpRankingPoints,
                  ),
                ),
                Text(
                  strings.semifinalistRewardSummary(
                    CompetitionRewards.monthlySemifinalistRankingPoints,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${_selectedIds.length} competitors selected',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 20),
        Text(
          'Choose competitors',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._familyMembers.map((player) {
          final selected = _selectedIds.contains(player.id);

          return Card(
            child: CheckboxListTile(
              value: selected,
              onChanged: (_) => _togglePlayer(player.id),
              secondary: CircleAvatar(
                child: Text(
                  player.name.isEmpty
                      ? '?'
                      : player.name.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(player.name),
            ),
          );
        }),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _selectedIds.length >= 2 && !_isSaving
              ? _startTournament
              : null,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.emoji_events_rounded),
          label: Text(
            _isSaving ? strings.startingMonthlyCup : strings.startMonthlyCup,
          ),
        ),
      ],
    );
  }

  List<_MonthlyRound> _buildRounds() {
    var currentPlayers = List<_MonthlyPlayer>.from(_selectedPlayers);
    final rounds = <_MonthlyRound>[];
    var nextMatchIndex = 0;
    var roundNumber = 1;

    while (currentPlayers.length > 1) {
      final roundMatches = <_MonthlyRoundMatch>[];
      final advancingPlayers = <_MonthlyPlayer>[];

      var index = 0;

      while (index + 1 < currentPlayers.length) {
        final player1 = currentPlayers[index];
        final player2 = currentPlayers[index + 1];

        final savedMatch = _matchByIndex(nextMatchIndex);

        roundMatches.add(
          _MonthlyRoundMatch(
            matchIndex: nextMatchIndex,
            player1: player1,
            player2: player2,
            savedMatch: savedMatch,
          ),
        );

        if (savedMatch != null) {
          advancingPlayers.add(_playerById(savedMatch.winnerId));
        }

        nextMatchIndex++;
        index += 2;
      }

      _MonthlyPlayer? byePlayer;

      if (index < currentPlayers.length) {
        byePlayer = currentPlayers[index];
        advancingPlayers.add(byePlayer);
      }

      rounds.add(
        _MonthlyRound(
          roundNumber: roundNumber,
          matches: roundMatches,
          byePlayer: byePlayer,
        ),
      );

      final roundComplete = roundMatches.every(
        (match) => match.savedMatch != null,
      );

      if (!roundComplete) {
        break;
      }

      currentPlayers = advancingPlayers;
      roundNumber++;
    }

    return rounds;
  }

  Widget _buildBracket() {
    final strings = AppLocalizations.of(context)!;
    final players = _selectedPlayers;

    if (players.length < 2) {
      return Center(child: Text(strings.monthlyParticipantIncomplete));
    }

    final rounds = _buildRounds();
    final totalMatches = players.length - 1;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          strings.monthlyCupBracket,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text('${_matches.length} / $totalMatches matches completed'),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: totalMatches == 0 ? 0 : _matches.length / totalMatches,
        ),

        const SizedBox(height: 24),

        ...rounds.expand((round) {
          final isFinalRound =
              round.matches.length == 1 &&
              round.byePlayer == null &&
              round.matches.first.player1.id != round.matches.first.player2.id;

          final title = isFinalRound
              ? strings.finalRound
              : 'Round ${round.roundNumber}';

          return [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...round.matches.map((roundMatch) {
              final match = roundMatch.savedMatch;

              final allPreviousMatchesDone =
                  _matches.length == roundMatch.matchIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildMatchCard(
                  matchIndex: roundMatch.matchIndex,
                  title: title,
                  player1: roundMatch.player1,
                  player2: roundMatch.player2,
                  match: match,
                  onPlay: () => _playMatch(
                    matchIndex: roundMatch.matchIndex,
                    player1: roundMatch.player1,
                    player2: roundMatch.player2,
                  ),
                  enabled: match == null && allPreviousMatchesDone,
                ),
              );
            }),

            if (round.byePlayer != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fast_forward_rounded),
                  title: Text(round.byePlayer!.name),
                  subtitle: const Text(
                    'Bye — automatically advances to the next round',
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ];
        }),

        if (_isSaving) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _buildMatchCard({
    required int matchIndex,
    required String title,
    required _MonthlyPlayer player1,
    required _MonthlyPlayer player2,
    required _MonthlyMatch? match,
    required VoidCallback onPlay,
    required bool enabled,
  }) {
    final strings = AppLocalizations.of(context)!;
    final game = _gameForMatch(matchIndex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(strings.gameNameLabel(game.localizedName(strings))),
            const SizedBox(height: 18),
            Text(
              strings.versusPlayers(player1.name, player2.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            if (match != null)
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppTheme.goldColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.winnerNameLabel(match.winnerName),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: enabled && !_isSaving ? onPlay : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(strings.playNamedRound(title)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCup() {
    final strings = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        DigitalRewardStyleBuilder(
          userId: widget.developerPreview ? null : _championId,
          preview: widget.developerPreview
              ? const EquippedDigitalRewards(celebrationEffect: 'stars')
              : null,
          builder: (context, digitalRewards) => SilaCelebrationCard(
            key: const ValueKey('monthly-cup-celebration'),
            eyebrow: strings.monthlyCupChampion,
            title: _championName ?? strings.champion,
            subtitle: strings.monthlyCompleteDescription,
            icon: Icons.workspace_premium_rounded,
            effect: digitalRewards.celebrationEffect,
            rewards: [
              SilaCelebrationReward(
                icon: Icons.stars_rounded,
                label: strings.tokenBonus(
                  CompetitionRewards.monthlyChampionTokens,
                ),
              ),
              SilaCelebrationReward(
                icon: Icons.trending_up_rounded,
                label: strings.rankingPointBonus(
                  CompetitionRewards.monthlyChampionRankingPoints,
                ),
              ),
              SilaCelebrationReward(
                icon: Icons.emoji_events_rounded,
                label: strings.cupTrophy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          strings.finalStandings,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        _CupPlacementCard(
          icon: Icons.workspace_premium_rounded,
          placement: strings.champion,
          name: _championName ?? strings.champion,
          reward: strings.monthlyChampionRewardSummary(
            CompetitionRewards.monthlyChampionTokens,
            CompetitionRewards.monthlyChampionRankingPoints,
          ),
          emphasized: true,
        ),
        if (_runnerUpName != null) ...[
          const SizedBox(height: 10),
          _CupPlacementCard(
            icon: Icons.military_tech_rounded,
            placement: strings.runnerUp,
            name: _runnerUpName!,
            reward: strings.runnerUpRewardSummary(
              CompetitionRewards.monthlyRunnerUpRankingPoints,
            ),
          ),
        ],
        ..._semifinalistNames.map(
          (name) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _CupPlacementCard(
              icon: Icons.shield_outlined,
              placement: strings.semifinalist,
              name: name,
              reward: strings.semifinalistRewardSummary(
                CompetitionRewards.monthlySemifinalistRankingPoints,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          strings.matchHistory,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ..._matches.map(
          (match) => ListTile(
            leading: const Icon(Icons.sports_esports_rounded),
            title: Text(
              OfficialCompetitionGames.byId(
                    match.gameId,
                  )?.localizedName(strings) ??
                  match.gameName,
            ),
            subtitle: Text(
              strings.versusPlayers(match.player1Name, match.player2Name),
            ),
            trailing: Text(
              match.winnerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(strings.backToCompetitions),
        ),
      ],
    );
  }
}

class _CupPlacementCard extends StatelessWidget {
  const _CupPlacementCard({
    required this.icon,
    required this.placement,
    required this.name,
    required this.reward,
    this.emphasized = false,
  });

  final IconData icon;
  final String placement;
  final String name;
  final String reward;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: emphasized ? colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(reward),
        trailing: Text(
          placement,
          style: TextStyle(
            color: emphasized ? colorScheme.primary : null,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MonthlyPlayer {
  const _MonthlyPlayer({required this.id, required this.name});

  final String id;
  final String name;
}

class _MonthlyRound {
  const _MonthlyRound({
    required this.roundNumber,
    required this.matches,
    required this.byePlayer,
  });

  final int roundNumber;
  final List<_MonthlyRoundMatch> matches;
  final _MonthlyPlayer? byePlayer;
}

class _MonthlyRoundMatch {
  const _MonthlyRoundMatch({
    required this.matchIndex,
    required this.player1,
    required this.player2,
    required this.savedMatch,
  });

  final int matchIndex;
  final _MonthlyPlayer player1;
  final _MonthlyPlayer player2;
  final _MonthlyMatch? savedMatch;
}

class _MonthlyMatch {
  const _MonthlyMatch({
    required this.matchIndex,
    required this.gameId,
    required this.gameName,
    required this.player1Id,
    required this.player1Name,
    required this.player2Id,
    required this.player2Name,
    required this.winnerId,
    required this.winnerName,
    required this.loserId,
    required this.loserName,
  });

  final int matchIndex;

  final String gameId;
  final String gameName;

  final String player1Id;
  final String player1Name;

  final String player2Id;
  final String player2Name;

  final String winnerId;
  final String winnerName;

  final String loserId;
  final String loserName;

  Map<String, dynamic> toMap() {
    return {
      'matchIndex': matchIndex,
      'gameId': gameId,
      'gameName': gameName,
      'player1Id': player1Id,
      'player1Name': player1Name,
      'player2Id': player2Id,
      'player2Name': player2Name,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'loserId': loserId,
      'loserName': loserName,
    };
  }

  factory _MonthlyMatch.fromMap(Map<String, dynamic> map) {
    return _MonthlyMatch(
      matchIndex: (map['matchIndex'] as num?)?.toInt() ?? 0,
      gameId: map['gameId'] as String? ?? '',
      gameName: map['gameName'] as String? ?? 'Monthly Cup Game',
      player1Id: map['player1Id'] as String? ?? '',
      player1Name: map['player1Name'] as String? ?? 'Player 1',
      player2Id: map['player2Id'] as String? ?? '',
      player2Name: map['player2Name'] as String? ?? 'Player 2',
      winnerId: map['winnerId'] as String? ?? '',
      winnerName: map['winnerName'] as String? ?? 'Winner',
      loserId: map['loserId'] as String? ?? '',
      loserName: map['loserName'] as String? ?? 'Runner-up',
    );
  }
}
