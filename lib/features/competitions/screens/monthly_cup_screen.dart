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
  String? _errorMessage;

  final List<_MonthlyPlayer> _familyMembers = [];
  final Set<String> _selectedIds = {};
  final List<_MonthlyMatch> _matches = [];

  String? _championName;

  DateTime get _today => DateTime.now();

  String get _monthKey =>
      '${_today.year}-${_today.month.toString().padLeft(2, '0')}';

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
        _errorMessage = 'You must be signed in to use Monthly Cup.';
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
          _errorMessage =
              'Join or create a family before starting Monthly Cup.';
        });

        return;
      }

      final membersSnapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

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
              : 'Family Member',
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
            storedParticipantIds.length == 4 ||
            storedMatches.isNotEmpty ||
            data?['completed'] == true;

        _completed = data?['completed'] == true;
        _championName = data?['winnerName'] as String?;

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load this month\'s cup.';
      });
    }
  }

  void _togglePlayer(String id) {
    if (_tournamentStarted || _completed) return;

    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < 4) {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _startTournament() async {
    if (_selectedIds.length != 4) {
      _showMessage('Select exactly 4 family members.');
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
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Could not start Monthly Cup. Please try again.');
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
      _showMessage('The game finished without a valid result.');
      return;
    }

    if (result.gameId != game.gameId) {
      _showMessage(
        'The returned result does not match this Monthly Cup match.',
      );
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

      if (_matches.length == 3) {
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

      if (_matches.length == 3) {
        await _finishCup();
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Could not save this Monthly Cup match.');
    }
  }

  Future<void> _finishCup() async {
    if (_matches.length < 3 || _completed || _isSaving) {
      return;
    }

    final finalMatch = _matches.firstWhere((match) => match.matchIndex == 2);

    final championId = finalMatch.winnerId;
    final championName = finalMatch.winnerName;
    final runnerUpId = finalMatch.loserId;
    final runnerUpName = finalMatch.loserName;

    final semifinalLoserIds = _matches
        .where((match) => match.matchIndex < 2)
        .map((match) => match.loserId)
        .toList();

    setState(() {
      _isSaving = true;
    });

    if (widget.developerPreview) {
      setState(() {
        _championName = championName;
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
          'gamesPlayed': FieldValue.increment(2),
          'trophies': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final runnerUpRef = firestore.collection('users').doc(runnerUpId);

        transaction.set(runnerUpRef, {
          'rankingPoints': FieldValue.increment(
            CompetitionRewards.monthlyRunnerUpRankingPoints,
          ),
          'gamesPlayed': FieldValue.increment(2),
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
            'gamesPlayed': FieldValue.increment(1),
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
        _championName = championName;
        _completed = true;
        _isSaving = false;
      });

      _showMessage(
        '$championName won the Monthly Cup! '
        '+${CompetitionRewards.monthlyChampionTokens} Tokens and '
        '+${CompetitionRewards.monthlyChampionRankingPoints} Ranking Points.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Could not finalize Monthly Cup.');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Cup')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: _loadData, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
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
              const Text(
                'MONTHLY CUP',
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
              const Text(
                'Four family members. Two semifinals. One final. One champion.',
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
                  'Monthly rewards',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Champion: +${CompetitionRewards.monthlyChampionTokens} Tokens '
                  '+ ${CompetitionRewards.monthlyChampionRankingPoints} RP + Trophy',
                ),
                Text(
                  'Runner-up: +${CompetitionRewards.monthlyRunnerUpRankingPoints} RP',
                ),
                Text(
                  'Semifinalists: +${CompetitionRewards.monthlySemifinalistRankingPoints} RP',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Choose exactly 4 competitors',
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
          onPressed: _selectedIds.length == 4 && !_isSaving
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
            _isSaving ? 'Starting Monthly Cup...' : 'Start Monthly Cup',
          ),
        ),
      ],
    );
  }

  Widget _buildBracket() {
    final players = _selectedPlayers;

    if (players.length != 4) {
      return const Center(
        child: Text('Monthly Cup participant data is incomplete.'),
      );
    }

    final semifinal1 = _matchByIndex(0);
    final semifinal2 = _matchByIndex(1);
    final finalMatch = _matchByIndex(2);

    final finalist1 = semifinal1 == null
        ? null
        : _playerById(semifinal1.winnerId);

    final finalist2 = semifinal2 == null
        ? null
        : _playerById(semifinal2.winnerId);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Monthly Cup Bracket',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        _buildMatchCard(
          title: 'Semifinal 1',
          player1: players[0],
          player2: players[1],
          match: semifinal1,
          onPlay: () => _playMatch(
            matchIndex: 0,
            player1: players[0],
            player2: players[1],
          ),
          enabled: semifinal1 == null,
        ),

        const SizedBox(height: 14),

        _buildMatchCard(
          title: 'Semifinal 2',
          player1: players[2],
          player2: players[3],
          match: semifinal2,
          onPlay: () => _playMatch(
            matchIndex: 1,
            player1: players[2],
            player2: players[3],
          ),
          enabled: semifinal1 != null && semifinal2 == null,
        ),

        const SizedBox(height: 24),

        if (finalist1 != null && finalist2 != null)
          _buildMatchCard(
            title: 'FINAL',
            player1: finalist1,
            player2: finalist2,
            match: finalMatch,
            onPlay: () => _playMatch(
              matchIndex: 2,
              player1: finalist1,
              player2: finalist2,
            ),
            enabled: finalMatch == null,
          ),

        if (_isSaving) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _buildMatchCard({
    required String title,
    required _MonthlyPlayer player1,
    required _MonthlyPlayer player2,
    required _MonthlyMatch? match,
    required VoidCallback onPlay,
    required bool enabled,
  }) {
    final game = _gameForMatch(
      title == 'Semifinal 1'
          ? 0
          : title == 'Semifinal 2'
          ? 1
          : 2,
    );

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
            Text('Game: ${game.name}'),
            const SizedBox(height: 18),
            Text(
              '${player1.name}  VS  ${player2.name}',
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
                      'Winner: ${match.winnerName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: enabled && !_isSaving ? onPlay : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Play $title'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCup() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 84,
                color: AppTheme.goldColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'MONTHLY CUP CHAMPION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _championName ?? 'Champion',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '+${CompetitionRewards.monthlyChampionTokens} Tokens • '
                '+${CompetitionRewards.monthlyChampionRankingPoints} RP • Trophy',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ..._matches.map(
          (match) => ListTile(
            leading: const Icon(Icons.sports_esports_rounded),
            title: Text(match.gameName),
            subtitle: Text('${match.player1Name} vs ${match.player2Name}'),
            trailing: Text(
              match.winnerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyPlayer {
  const _MonthlyPlayer({required this.id, required this.name});

  final String id;
  final String name;
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
