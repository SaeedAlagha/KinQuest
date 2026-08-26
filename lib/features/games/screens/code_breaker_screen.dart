import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../widgets/game_setup_widgets.dart';

enum _CodeBreakerPhase { setup, passPhone, playing, turnResult, finalResults }

enum _CodeBreakerDifficulty { easy, medium, hard }

class CodeBreakerScreen extends StatefulWidget {
  const CodeBreakerScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<CodeBreakerScreen> createState() => _CodeBreakerScreenState();
}

class _CodeBreakerScreenState extends State<CodeBreakerScreen> {
  final Random _random = Random();

  final List<_CodeBreakerPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  bool _isLoading = true;
  String? _loadError;

  int _selectedRounds = 3;
  _CodeBreakerDifficulty _difficulty = _CodeBreakerDifficulty.medium;

  _CodeBreakerPhase _phase = _CodeBreakerPhase.setup;

  late List<_CodeBreakerPlayer> _players;

  int _currentRound = 1;
  int _currentPlayerIndex = 0;

  final Map<String, int> _scores = {};
  final Map<String, int> _totalAttempts = {};
  final Map<String, int> _totalSeconds = {};

  List<String> _secretCode = [];
  List<String?> _currentGuess = [];

  final List<_GuessResult> _guessHistory = [];
  final List<_TurnResult> _turnResults = [];

  DateTime? _turnStartedAt;
  int _attempts = 0;

  static const List<String> _symbolPool = [
    '🔴',
    '🔵',
    '🟢',
    '🟡',
    '🟣',
    '🟠',
    '⭐',
    '💎',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadPreview();
    } else {
      _loadFamilyMembers();
    }
  }

  void _loadPreview() {
    const previewPlayers = [
      _CodeBreakerPlayer(id: 'preview-1', name: 'Alex'),
      _CodeBreakerPlayer(id: 'preview-2', name: 'Sam'),
      _CodeBreakerPlayer(id: 'preview-3', name: 'Jordan'),
      _CodeBreakerPlayer(id: 'preview-4', name: 'Taylor'),
    ];

    final availablePlayers = widget.participantIds == null
        ? previewPlayers
        : previewPlayers
              .where((player) => widget.participantIds!.contains(player.id))
              .toList();

    setState(() {
      _familyMembers
        ..clear()
        ..addAll(availablePlayers);

      if (widget.participantIds != null) {
        _selectedPlayerIds
          ..clear()
          ..addAll(availablePlayers.take(2).map((player) => player.id));
      }

      _isLoading = false;
    });
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'You must be signed in to play.';
      });
      return;
    }

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDocument.data()?['familyId']?.toString();

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _loadError = 'Join a family before playing Code Breaker.';
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name']?.toString().trim();
        final email = data['email']?.toString().trim();

        return _CodeBreakerPlayer(
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

      final availablePlayers = widget.participantIds == null
          ? members
          : members
                .where((player) => widget.participantIds!.contains(player.id))
                .toList();

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(availablePlayers);

        if (widget.participantIds != null) {
          _selectedPlayerIds
            ..clear()
            ..addAll(availablePlayers.take(2).map((player) => player.id));
        }

        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Could not load family members.';
      });
    }
  }

  void _togglePlayer(String id) {
    if (widget.participantIds != null) {
      return;
    }

    setState(() {
      if (_selectedPlayerIds.contains(id)) {
        _selectedPlayerIds.remove(id);
        return;
      }

      if (_selectedPlayerIds.length >= 2) {
        return;
      }

      _selectedPlayerIds.add(id);
    });
  }

  int get _codeLength => switch (_difficulty) {
    _CodeBreakerDifficulty.easy => 3,
    _CodeBreakerDifficulty.medium => 4,
    _CodeBreakerDifficulty.hard => 5,
  };

  int get _availableSymbolCount => switch (_difficulty) {
    _CodeBreakerDifficulty.easy => 5,
    _CodeBreakerDifficulty.medium => 6,
    _CodeBreakerDifficulty.hard => 8,
  };

  bool get _allowDuplicates => _difficulty == _CodeBreakerDifficulty.hard;

  String get _difficultyName => switch (_difficulty) {
    _CodeBreakerDifficulty.easy => 'Easy',
    _CodeBreakerDifficulty.medium => 'Medium',
    _CodeBreakerDifficulty.hard => 'Hard',
  };

  String _difficultyDescription(_CodeBreakerDifficulty difficulty) {
    return switch (difficulty) {
      _CodeBreakerDifficulty.easy => '3-symbol codes with no repeated symbols.',
      _CodeBreakerDifficulty.medium =>
        '4-symbol codes with a larger symbol pool.',
      _CodeBreakerDifficulty.hard => '5-symbol codes where symbols may repeat.',
    };
  }

  void _startGame() {
    if (_selectedPlayerIds.length != 2) {
      return;
    }

    final selectedPlayers = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    if (selectedPlayers.length != 2) {
      return;
    }

    setState(() {
      _players = selectedPlayers;

      _scores
        ..clear()
        ..addAll({selectedPlayers[0].id: 0, selectedPlayers[1].id: 0});

      _totalAttempts
        ..clear()
        ..addAll({selectedPlayers[0].id: 0, selectedPlayers[1].id: 0});

      _totalSeconds
        ..clear()
        ..addAll({selectedPlayers[0].id: 0, selectedPlayers[1].id: 0});

      _turnResults.clear();
      _guessHistory.clear();

      _currentRound = 1;
      _currentPlayerIndex = 0;

      _phase = _CodeBreakerPhase.passPhone;
    });
  }

  void _prepareTurn() {
    setState(() {
      _secretCode = _generateSecretCode();

      _currentGuess = List<String?>.filled(_codeLength, null);

      _guessHistory.clear();

      _attempts = 0;
      _turnStartedAt = DateTime.now();

      _phase = _CodeBreakerPhase.playing;
    });
  }

  List<String> _generateSecretCode() {
    final availableSymbols = _symbolPool.take(_availableSymbolCount).toList();

    if (_allowDuplicates) {
      return List.generate(
        _codeLength,
        (_) => availableSymbols[_random.nextInt(availableSymbols.length)],
      );
    }

    availableSymbols.shuffle(_random);

    return availableSymbols.take(_codeLength).toList();
  }

  void _addSymbolToGuess(String symbol) {
    final emptyIndex = _currentGuess.indexOf(null);

    if (emptyIndex == -1) {
      return;
    }

    setState(() {
      _currentGuess[emptyIndex] = symbol;
    });
  }

  void _removeLastSymbol() {
    for (var index = _currentGuess.length - 1; index >= 0; index--) {
      if (_currentGuess[index] != null) {
        setState(() {
          _currentGuess[index] = null;
        });
        return;
      }
    }
  }

  void _clearGuess() {
    setState(() {
      _currentGuess = List<String?>.filled(_codeLength, null);
    });
  }

  void _submitGuess() {
    if (_currentGuess.any((symbol) => symbol == null)) {
      return;
    }

    final guess = _currentGuess.cast<String>();

    final feedback = _calculateFeedback(secret: _secretCode, guess: guess);

    _attempts++;

    if (feedback.exact == _codeLength) {
      _completeTurn();
      return;
    }

    setState(() {
      _guessHistory.insert(
        0,
        _GuessResult(
          guess: List<String>.from(guess),
          exact: feedback.exact,
          misplaced: feedback.misplaced,
        ),
      );

      _currentGuess = List<String?>.filled(_codeLength, null);
    });
  }

  _CodeFeedback _calculateFeedback({
    required List<String> secret,
    required List<String> guess,
  }) {
    var exact = 0;

    final remainingSecret = <String>[];
    final remainingGuess = <String>[];

    for (var index = 0; index < secret.length; index++) {
      if (secret[index] == guess[index]) {
        exact++;
      } else {
        remainingSecret.add(secret[index]);
        remainingGuess.add(guess[index]);
      }
    }

    var misplaced = 0;

    for (final symbol in remainingGuess) {
      final secretIndex = remainingSecret.indexOf(symbol);

      if (secretIndex != -1) {
        misplaced++;
        remainingSecret.removeAt(secretIndex);
      }
    }

    return _CodeFeedback(exact: exact, misplaced: misplaced);
  }

  void _completeTurn() {
    final player = _currentPlayer;

    final seconds = max(
      1,
      DateTime.now().difference(_turnStartedAt ?? DateTime.now()).inSeconds,
    );

    final score = _calculateScore(attempts: _attempts, seconds: seconds);

    _scores.update(
      player.id,
      (currentValue) => currentValue + score,
      ifAbsent: () => score,
    );

    _totalAttempts.update(
      player.id,
      (currentValue) => currentValue + _attempts,
      ifAbsent: () => _attempts,
    );

    _totalSeconds.update(
      player.id,
      (currentValue) => currentValue + seconds,
      ifAbsent: () => seconds,
    );

    _turnResults.add(
      _TurnResult(
        round: _currentRound,
        player: player,
        attempts: _attempts,
        seconds: seconds,
        score: score,
        code: List<String>.from(_secretCode),
      ),
    );

    setState(() {
      _phase = _CodeBreakerPhase.turnResult;
    });
  }

  int _calculateScore({required int attempts, required int seconds}) {
    final baseScore = switch (_difficulty) {
      _CodeBreakerDifficulty.easy => 1000,
      _CodeBreakerDifficulty.medium => 1500,
      _CodeBreakerDifficulty.hard => 2200,
    };

    final attemptPenalty = max(0, attempts - 1) * 90;

    final timePenalty = seconds * 3;

    return max(100, baseScore - attemptPenalty - timePenalty);
  }

  void _continueAfterTurn() {
    if (_currentPlayerIndex == 0) {
      setState(() {
        _currentPlayerIndex = 1;
        _phase = _CodeBreakerPhase.passPhone;
      });
      return;
    }

    if (_currentRound >= _selectedRounds) {
      setState(() {
        _phase = _CodeBreakerPhase.finalResults;
      });
      return;
    }

    setState(() {
      _currentRound++;
      _currentPlayerIndex = 0;
      _phase = _CodeBreakerPhase.passPhone;
    });
  }

  _CodeBreakerPlayer get _currentPlayer => _players[_currentPlayerIndex];

  bool get _isTie {
    if (_players.length != 2) {
      return false;
    }

    final player1 = _players[0];
    final player2 = _players[1];

    return (_scores[player1.id] ?? 0) == (_scores[player2.id] ?? 0) &&
        (_totalAttempts[player1.id] ?? 0) ==
            (_totalAttempts[player2.id] ?? 0) &&
        (_totalSeconds[player1.id] ?? 0) == (_totalSeconds[player2.id] ?? 0);
  }

  _CodeBreakerPlayer get _winner {
    final player1 = _players[0];
    final player2 = _players[1];

    final score1 = _scores[player1.id] ?? 0;
    final score2 = _scores[player2.id] ?? 0;

    if (score1 != score2) {
      return score1 > score2 ? player1 : player2;
    }

    final attempts1 = _totalAttempts[player1.id] ?? 0;
    final attempts2 = _totalAttempts[player2.id] ?? 0;

    if (attempts1 != attempts2) {
      return attempts1 < attempts2 ? player1 : player2;
    }

    final seconds1 = _totalSeconds[player1.id] ?? 0;
    final seconds2 = _totalSeconds[player2.id] ?? 0;

    if (seconds1 != seconds2) {
      return seconds1 < seconds2 ? player1 : player2;
    }

    return player1;
  }

  CompetitionGameResult _buildCompetitionResult() {
    final player1 = _players[0];
    final player2 = _players[1];

    if (_isTie) {
      return CompetitionGameResult(
        gameId: 'code_breaker',
        gameName: 'Code Breaker',
        players: [
          CompetitionPlayerResult(
            userId: player1.id,
            name: player1.name,
            gameScore: _scores[player1.id] ?? 0,
            placement: 1,
          ),
          CompetitionPlayerResult(
            userId: player2.id,
            name: player2.name,
            gameScore: _scores[player2.id] ?? 0,
            placement: 1,
          ),
        ],
      );
    }

    final winner = _winner;

    final loser = _players.firstWhere((player) => player.id != winner.id);

    return CompetitionGameResult(
      gameId: 'code_breaker',
      gameName: 'Code Breaker',
      players: [
        CompetitionPlayerResult(
          userId: winner.id,
          name: winner.name,
          gameScore: _scores[winner.id] ?? 0,
          placement: 1,
        ),
        CompetitionPlayerResult(
          userId: loser.id,
          name: loser.name,
          gameScore: _scores[loser.id] ?? 0,
          placement: 2,
        ),
      ],
    );
  }

  void _playAgain() {
    setState(() {
      _phase = _CodeBreakerPhase.setup;

      _currentRound = 1;
      _currentPlayerIndex = 0;

      _scores.clear();
      _totalAttempts.clear();
      _totalSeconds.clear();

      _turnResults.clear();
      _guessHistory.clear();

      _secretCode = [];
      _currentGuess = [];
      _attempts = 0;
      _turnStartedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SilaGameCoachButton(),
      appBar: AppBar(title: const Text('Code Breaker')),
      body: SafeArea(
        child: switch (_phase) {
          _CodeBreakerPhase.setup => _buildSetup(),
          _CodeBreakerPhase.passPhone => _buildPassPhone(),
          _CodeBreakerPhase.playing => _buildPlaying(),
          _CodeBreakerPhase.turnResult => _buildTurnResult(),
          _CodeBreakerPhase.finalResults => _buildFinalResults(),
        },
      ),
    );
  }

  Widget _buildSetup() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_loadError!, textAlign: TextAlign.center),
        ),
      );
    }

    return GameSetupView(
      icon: Icons.lock_open_rounded,
      title: 'Code Breaker',
      description:
          'Crack the hidden code using logic. Fewer attempts and faster solves earn more points.',
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who is playing?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('Choose exactly 2 players.'),
              const SizedBox(height: 12),
              for (final player in _familyMembers)
                CheckboxListTile(
                  value: _selectedPlayerIds.contains(player.id),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.person_rounded),
                  title: Text(player.name),
                  onChanged: widget.participantIds != null
                      ? null
                      : (_) => _togglePlayer(player.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GameRoundSelector(
          value: _selectedRounds,
          onChanged: (rounds) {
            setState(() {
              _selectedRounds = rounds;
            });
          },
          description: 'Both players crack a new code in every round.',
        ),
        const SizedBox(height: 16),
        _buildDifficultySelector(),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _selectedPlayerIds.length == 2 ? _startGame : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Code Breaker'),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Difficulty', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            _difficultyDescription(_difficulty),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                avatar: const Icon(Icons.sentiment_satisfied_rounded, size: 18),
                label: const Text('Easy'),
                selected: _difficulty == _CodeBreakerDifficulty.easy,
                onSelected: (_) {
                  setState(() {
                    _difficulty = _CodeBreakerDifficulty.easy;
                  });
                },
              ),
              ChoiceChip(
                avatar: const Icon(Icons.psychology_rounded, size: 18),
                label: const Text('Medium'),
                selected: _difficulty == _CodeBreakerDifficulty.medium,
                onSelected: (_) {
                  setState(() {
                    _difficulty = _CodeBreakerDifficulty.medium;
                  });
                },
              ),
              ChoiceChip(
                avatar: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                ),
                label: const Text('Hard'),
                selected: _difficulty == _CodeBreakerDifficulty.hard,
                onSelected: (_) {
                  setState(() {
                    _difficulty = _CodeBreakerDifficulty.hard;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassPhone() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                'Round $_currentRound of $_selectedRounds',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$_difficultyName Difficulty',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Pass the phone to ${_currentPlayer.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The other player should look away until this turn is finished.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: _prepareTurn,
                icon: const Icon(Icons.visibility_rounded),
                label: Text('I\'m ${_currentPlayer.name}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaying() {
    final availableSymbols = _symbolPool.take(_availableSymbolCount).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_currentPlayer.name} — Round $_currentRound',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_difficultyName • $_codeLength-symbol code',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildCurrentGuess(),
              const SizedBox(height: 26),
              Text(
                'Choose symbols',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: availableSymbols.map((symbol) {
                  return FilledButton.tonal(
                    onPressed: () => _addSymbolToGuess(symbol),
                    child: Text(symbol, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _removeLastSymbol,
                      icon: const Icon(Icons.backspace_outlined),
                      label: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearGuess,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _currentGuess.any((symbol) => symbol == null)
                    ? null
                    : _submitGuess,
                icon: const Icon(Icons.key_rounded),
                label: const Text('Try Code'),
              ),
              const SizedBox(height: 20),
              Text(
                'Attempts: $_attempts',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_guessHistory.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  'Previous Guesses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ..._guessHistory.map(_buildGuessHistoryCard),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGuess() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_codeLength, (index) {
        final symbol = _currentGuess[index];

        return Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child: Text(
            symbol ?? '?',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  Widget _buildGuessHistoryCard(_GuessResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: result.guess
                  .map(
                    (symbol) =>
                        Text(symbol, style: const TextStyle(fontSize: 25)),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Text('✅ ${result.exact} correct position'),
            const SizedBox(height: 4),
            Text('🔄 ${result.misplaced} correct symbol, wrong position'),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnResult() {
    final result = _turnResults.last;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open_rounded, size: 80),
              const SizedBox(height: 18),
              const Text(
                'Code Cracked!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: result.code
                    .map(
                      (symbol) =>
                          Text(symbol, style: const TextStyle(fontSize: 28)),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                result.player.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text('${result.attempts} attempts'),
              const SizedBox(height: 6),
              Text('${result.seconds} seconds'),
              const SizedBox(height: 14),
              Text(
                '+${result.score} points',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: _continueAfterTurn,
                child: Text(
                  _currentPlayerIndex == 0
                      ? 'Pass to ${_players[1].name}'
                      : _currentRound == _selectedRounds
                      ? 'See Final Results'
                      : 'Next Round',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalResults() {
    final player1 = _players[0];
    final player2 = _players[1];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 86),
              const SizedBox(height: 20),
              Text(
                _isTie ? 'It\'s a tie!' : '${_winner.name} wins!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('$_selectedRounds rounds • $_difficultyName'),
              const SizedBox(height: 28),
              _buildScoreCard(player1),
              const SizedBox(height: 12),
              _buildScoreCard(player2),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: () {
                  if (widget.playMode.isOfficial) {
                    Navigator.of(context).pop(_buildCompetitionResult());
                    return;
                  }

                  _playAgain();
                },
                icon: Icon(
                  widget.playMode.isOfficial
                      ? Icons.arrow_back_rounded
                      : Icons.refresh_rounded,
                ),
                label: Text(
                  widget.playMode.isOfficial
                      ? 'Return to Competition'
                      : 'Play Again',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Games'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(_CodeBreakerPlayer player) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(
              player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
            ),
          ),
          title: Text(
            player.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${_totalAttempts[player.id] ?? 0} attempts • '
            '${_totalSeconds[player.id] ?? 0}s',
          ),
          trailing: Text(
            '${_scores[player.id] ?? 0}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _CodeBreakerPlayer {
  const _CodeBreakerPlayer({required this.id, required this.name});

  final String id;
  final String name;
}

class _CodeFeedback {
  const _CodeFeedback({required this.exact, required this.misplaced});

  final int exact;
  final int misplaced;
}

class _GuessResult {
  const _GuessResult({
    required this.guess,
    required this.exact,
    required this.misplaced,
  });

  final List<String> guess;
  final int exact;
  final int misplaced;
}

class _TurnResult {
  const _TurnResult({
    required this.round,
    required this.player,
    required this.attempts,
    required this.seconds,
    required this.score,
    required this.code,
  });

  final int round;
  final _CodeBreakerPlayer player;
  final int attempts;
  final int seconds;
  final int score;
  final List<String> code;
}
