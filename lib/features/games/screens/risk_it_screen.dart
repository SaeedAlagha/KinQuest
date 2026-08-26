import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/risk_it_ai_service.dart';
import '../widgets/game_setup_widgets.dart';

enum _RiskItPhase {
  setup,
  loading,
  passPhone,
  question,
  decision,
  turnResult,
  roundResult,
  finalResults,
}

enum _RiskItDifficulty { easy, medium, hard }

class RiskItScreen extends StatefulWidget {
  const RiskItScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<RiskItScreen> createState() => _RiskItScreenState();
}

class _RiskItScreenState extends State<RiskItScreen> {
  final RiskItAiService _aiService = RiskItAiService();

  final List<_RiskPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  final List<String> _categories = [
    'Mixed',
    'General Knowledge',
    'Science',
    'Geography',
    'Sports',
    'Entertainment',
  ];

  bool _isLoadingFamily = true;
  String? _loadError;

  int _selectedRounds = 3;
  String _selectedCategory = 'Mixed';

  _RiskItDifficulty _difficulty = _RiskItDifficulty.medium;

  _RiskItPhase _phase = _RiskItPhase.setup;

  late List<_RiskPlayer> _players;

  List<RiskItQuestion> _questions = [];
  int _questionIndex = 0;

  int _currentRound = 1;
  int _currentPlayerIndex = 0;

  final Map<String, int> _totalScores = {};
  final Map<String, int> _roundScores = {};

  int _unbankedPot = 0;
  int _riskLevel = 0;

  bool _turnBusted = false;

  static const int _maximumRiskLevel = 5;

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
      _RiskPlayer(id: 'preview-1', name: 'Alex'),
      _RiskPlayer(id: 'preview-2', name: 'Sam'),
      _RiskPlayer(id: 'preview-3', name: 'Jordan'),
      _RiskPlayer(id: 'preview-4', name: 'Taylor'),
    ];

    final available = widget.participantIds == null
        ? previewPlayers
        : previewPlayers
              .where((player) => widget.participantIds!.contains(player.id))
              .toList();

    setState(() {
      _familyMembers
        ..clear()
        ..addAll(available);

      if (widget.participantIds != null) {
        _selectedPlayerIds
          ..clear()
          ..addAll(available.take(2).map((player) => player.id));
      }

      _isLoadingFamily = false;
    });
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoadingFamily = false;
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
          _isLoadingFamily = false;
          _loadError = 'Join a family before playing Risk It.';
        });

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = snapshot.docs.map((document) {
        final data = document.data();

        final name = data['name']?.toString().trim();
        final email = data['email']?.toString().trim();

        return _RiskPlayer(
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

      final available = widget.participantIds == null
          ? members
          : members
                .where((player) => widget.participantIds!.contains(player.id))
                .toList();

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(available);

        if (widget.participantIds != null) {
          _selectedPlayerIds
            ..clear()
            ..addAll(available.take(2).map((player) => player.id));
        }

        _isLoadingFamily = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingFamily = false;
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

  String get _difficultyApiValue => switch (_difficulty) {
    _RiskItDifficulty.easy => 'easy',
    _RiskItDifficulty.medium => 'medium',
    _RiskItDifficulty.hard => 'hard',
  };

  String get _difficultyName => switch (_difficulty) {
    _RiskItDifficulty.easy => 'Easy',
    _RiskItDifficulty.medium => 'Medium',
    _RiskItDifficulty.hard => 'Hard',
  };

  _RiskPlayer get _currentPlayer => _players[_currentPlayerIndex];

  int get _currentQuestionValue {
    const values = [200, 400, 800, 1600, 3200];

    return values[_riskLevel.clamp(0, values.length - 1)];
  }

  RiskItQuestion get _nextQuestion {
    if (_questions.isEmpty) {
      throw StateError('No Risk It questions loaded.');
    }

    final question = _questions[_questionIndex % _questions.length];

    _questionIndex++;

    return question;
  }

  RiskItQuestion? _activeQuestion;

  Future<void> _startGame() async {
    if (_selectedPlayerIds.length != 2) {
      return;
    }

    final selected = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    if (selected.length != 2) {
      return;
    }

    setState(() {
      _players = selected;
      _phase = _RiskItPhase.loading;
    });

    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final questionCount = min(40, max(20, _selectedRounds * 10));

      final generated = await _aiService.generateQuestions(
        category: _selectedCategory,
        difficulty: _difficultyApiValue,
        count: questionCount,
        languageCode: languageCode,
      );

      if (!mounted) return;

      setState(() {
        _questions = generated;
        _questionIndex = 0;

        _totalScores
          ..clear()
          ..addAll({selected[0].id: 0, selected[1].id: 0});

        _roundScores
          ..clear()
          ..addAll({selected[0].id: 0, selected[1].id: 0});

        _currentRound = 1;
        _currentPlayerIndex = 0;

        _resetTurn();

        _phase = _RiskItPhase.passPhone;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _phase = _RiskItPhase.setup;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not prepare the AI questions. Please try again.',
          ),
        ),
      );
    }
  }

  void _resetTurn() {
    _unbankedPot = 0;
    _riskLevel = 0;
    _turnBusted = false;
    _activeQuestion = null;
  }

  void _beginTurn() {
    setState(() {
      _activeQuestion = _nextQuestion;
      _phase = _RiskItPhase.question;
    });
  }

  void _answerQuestion(int selectedIndex) {
    final question = _activeQuestion;

    if (question == null) {
      return;
    }

    final correct = selectedIndex == question.correctIndex;

    if (!correct) {
      setState(() {
        _unbankedPot = 0;
        _turnBusted = true;
        _phase = _RiskItPhase.turnResult;
      });

      return;
    }

    setState(() {
      _unbankedPot += _currentQuestionValue;

      if (_riskLevel >= _maximumRiskLevel - 1) {
        _bankPoints();
        return;
      }

      _phase = _RiskItPhase.decision;
    });
  }

  void _riskAgain() {
    setState(() {
      _riskLevel++;
      _activeQuestion = _nextQuestion;
      _phase = _RiskItPhase.question;
    });
  }

  void _bankPoints() {
    final player = _currentPlayer;

    _roundScores.update(
      player.id,
      (value) => value + _unbankedPot,
      ifAbsent: () => _unbankedPot,
    );

    setState(() {
      _phase = _RiskItPhase.turnResult;
    });
  }

  void _finishTurn() {
    if (_currentPlayerIndex == 0) {
      setState(() {
        _currentPlayerIndex = 1;
        _resetTurn();
        _phase = _RiskItPhase.passPhone;
      });

      return;
    }

    setState(() {
      _phase = _RiskItPhase.roundResult;
    });
  }

  void _finishRound() {
    for (final player in _players) {
      final roundScore = _roundScores[player.id] ?? 0;

      _totalScores.update(
        player.id,
        (value) => value + roundScore,
        ifAbsent: () => roundScore,
      );
    }

    if (_currentRound >= _selectedRounds) {
      setState(() {
        _phase = _RiskItPhase.finalResults;
      });

      return;
    }

    setState(() {
      _currentRound++;
      _currentPlayerIndex = (_currentRound - 1) % 2;

      _roundScores
        ..clear()
        ..addAll({_players[0].id: 0, _players[1].id: 0});

      _resetTurn();

      _phase = _RiskItPhase.passPhone;
    });
  }

  bool get _isTie {
    return (_totalScores[_players[0].id] ?? 0) ==
        (_totalScores[_players[1].id] ?? 0);
  }

  _RiskPlayer get _winner {
    final first = _players[0];
    final second = _players[1];

    return (_totalScores[first.id] ?? 0) > (_totalScores[second.id] ?? 0)
        ? first
        : second;
  }

  CompetitionGameResult _buildCompetitionResult() {
    final first = _players[0];
    final second = _players[1];

    if (_isTie) {
      return CompetitionGameResult(
        gameId: 'risk_it',
        gameName: 'Risk It',
        players: [
          CompetitionPlayerResult(
            userId: first.id,
            name: first.name,
            gameScore: _totalScores[first.id] ?? 0,
            placement: 1,
          ),
          CompetitionPlayerResult(
            userId: second.id,
            name: second.name,
            gameScore: _totalScores[second.id] ?? 0,
            placement: 1,
          ),
        ],
      );
    }

    final winner = _winner;

    final loser = _players.firstWhere((player) => player.id != winner.id);

    return CompetitionGameResult(
      gameId: 'risk_it',
      gameName: 'Risk It',
      players: [
        CompetitionPlayerResult(
          userId: winner.id,
          name: winner.name,
          gameScore: _totalScores[winner.id] ?? 0,
          placement: 1,
        ),
        CompetitionPlayerResult(
          userId: loser.id,
          name: loser.name,
          gameScore: _totalScores[loser.id] ?? 0,
          placement: 2,
        ),
      ],
    );
  }

  void _playAgain() {
    setState(() {
      _phase = _RiskItPhase.setup;

      _questions = [];
      _questionIndex = 0;
      _activeQuestion = null;

      _totalScores.clear();
      _roundScores.clear();

      _currentRound = 1;
      _currentPlayerIndex = 0;

      _resetTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SilaGameCoachButton(),
      appBar: AppBar(title: const Text('Risk It')),
      body: SafeArea(
        child: switch (_phase) {
          _RiskItPhase.setup => _buildSetup(),
          _RiskItPhase.loading => _buildLoading(),
          _RiskItPhase.passPhone => _buildPassPhone(),
          _RiskItPhase.question => _buildQuestion(),
          _RiskItPhase.decision => _buildDecision(),
          _RiskItPhase.turnResult => _buildTurnResult(),
          _RiskItPhase.roundResult => _buildRoundResult(),
          _RiskItPhase.finalResults => _buildFinalResults(),
        },
      ),
    );
  }

  Widget _buildSetup() {
    if (_isLoadingFamily) {
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
      icon: Icons.casino_rounded,
      title: 'Risk It',
      description:
          'Build a points pot, bank it safely, or risk everything for a bigger score.',
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
          description: 'Both players get one private turn per round.',
        ),
        const SizedBox(height: 16),
        _buildDifficultySelector(),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _selectedPlayerIds.length == 2 ? _startGame : null,
          icon: const Icon(Icons.local_fire_department_rounded),
          label: const Text('Start Risk It'),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _RiskItDifficulty.values.map((difficulty) {
              final label = switch (difficulty) {
                _RiskItDifficulty.easy => 'Easy',
                _RiskItDifficulty.medium => 'Medium',
                _RiskItDifficulty.hard => 'Hard',
              };

              return ChoiceChip(
                label: Text(label),
                selected: _difficulty == difficulty,
                onSelected: (_) {
                  setState(() {
                    _difficulty = difficulty;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('AI is preparing your questions...'),
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
              const Icon(Icons.phone_android_rounded, size: 76),
              const SizedBox(height: 20),
              Text(
                'Round $_currentRound of $_selectedRounds',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Pass the phone to ${_currentPlayer.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The other player should look away during this turn.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _beginTurn,
                child: Text('I\'m ${_currentPlayer.name}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _activeQuestion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _currentPlayer.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Round $_currentRound • $_difficultyName',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'CURRENT POT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_unbankedPot',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('This question is worth +$_currentQuestionValue'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                question.question,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < question.options.length; index++) ...[
                FilledButton.tonal(
                  onPressed: () => _answerQuestion(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(question.options[index]),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecision() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 78),
              const SizedBox(height: 18),
              const Text(
                'Correct!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Unbanked Pot',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '$_unbankedPot',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Next correct answer: +${_riskLevel < _maximumRiskLevel - 1 ? _currentQuestionValue * 2 : _currentQuestionValue}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _bankPoints,
                  icon: const Icon(Icons.savings_rounded),
                  label: Text('Bank $_unbankedPot Points'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _riskAgain,
                  icon: const Icon(Icons.local_fire_department_rounded),
                  label: const Text('RISK IT'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'One wrong answer and your entire unbanked pot is lost.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnResult() {
    final earned = _roundScores[_currentPlayer.id] ?? 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _turnBusted ? Icons.heart_broken_rounded : Icons.savings_rounded,
              size: 82,
            ),
            const SizedBox(height: 20),
            Text(
              _turnBusted ? 'BUST!' : 'Points Banked!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _turnBusted
                  ? '${_currentPlayer.name} lost the unbanked pot.'
                  : '${_currentPlayer.name} banked $earned points.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _finishTurn,
              child: Text(
                _currentPlayerIndex == 0
                    ? 'Pass to ${_players[1].name}'
                    : 'See Round Results',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundResult() {
    final first = _players[0];
    final second = _players[1];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.leaderboard_rounded, size: 76),
            const SizedBox(height: 20),
            Text(
              'Round $_currentRound Complete',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(
              '${first.name}: ${_roundScores[first.id] ?? 0}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '${second.name}: ${_roundScores[second.id] ?? 0}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _finishRound,
              child: Text(
                _currentRound >= _selectedRounds
                    ? 'See Final Results'
                    : 'Next Round',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalResults() {
    final first = _players[0];
    final second = _players[1];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 88),
              const SizedBox(height: 20),
              Text(
                _isTie ? 'It\'s a tie!' : '${_winner.name} wins!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$_selectedRounds rounds • $_difficultyName • $_selectedCategory',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _scoreCard(first),
              const SizedBox(height: 10),
              _scoreCard(second),
              const SizedBox(height: 28),
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

  Widget _scoreCard(_RiskPlayer player) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(player.name.isEmpty ? '?' : player.name[0].toUpperCase()),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${_totalScores[player.id] ?? 0}',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _RiskPlayer {
  const _RiskPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
