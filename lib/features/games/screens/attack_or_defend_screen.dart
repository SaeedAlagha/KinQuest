import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../widgets/sila_game_coach.dart';

import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/attack_or_defend_ai_service.dart';
import '../widgets/game_setup_widgets.dart';

enum _BattlePhase {
  setup,
  loading,
  passPhone,
  earnEnergyQuestion,
  actionChoice,
  defenseQuestion,
  battleResult,
  finalResults,
}

enum _BattleDifficulty { easy, medium, hard }

enum _BattleAction { attack, shield, powerAttack, superAttack }

class AttackOrDefendScreen extends StatefulWidget {
  const AttackOrDefendScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<AttackOrDefendScreen> createState() => _AttackOrDefendScreenState();
}

class _AttackOrDefendScreenState extends State<AttackOrDefendScreen> {
  final AttackOrDefendAiService _aiService = AttackOrDefendAiService();

  final List<_BattlePlayer> _familyMembers = [];
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

  String _selectedCategory = 'Mixed';
  int _selectedRounds = 3;
  _BattleDifficulty _difficulty = _BattleDifficulty.medium;

  late List<_BattlePlayer> _players;

  final Map<String, int> _battleWins = {};
  final Map<String, int> _health = {};
  final Map<String, int> _energy = {};
  final Map<String, bool> _shield = {};

  List<AttackOrDefendQuestion> _questions = [];
  int _questionIndex = 0;

  int _currentBattle = 1;
  int _attackerIndex = 0;

  _BattleAction? _pendingAttack;

  Timer? _timer;
  int _secondsRemaining = 0;

  _BattlePhase _phase = _BattlePhase.setup;

  static const int _startingHealth = 5;

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadPreview();
    } else {
      _loadFamilyMembers();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadPreview() {
    const previewPlayers = [
      _BattlePlayer(id: 'preview-1', name: 'Alex'),
      _BattlePlayer(id: 'preview-2', name: 'Sam'),
      _BattlePlayer(id: 'preview-3', name: 'Jordan'),
      _BattlePlayer(id: 'preview-4', name: 'Taylor'),
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
          _loadError = 'Join a family before playing Attack or Defend.';
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

        return _BattlePlayer(
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
    _BattleDifficulty.easy => 'easy',
    _BattleDifficulty.medium => 'medium',
    _BattleDifficulty.hard => 'hard',
  };

  String get _difficultyName {
    final strings = AppLocalizations.of(context)!;
    return switch (_difficulty) {
      _BattleDifficulty.easy => strings.difficultyEasy,
      _BattleDifficulty.medium => strings.difficultyMedium,
      _BattleDifficulty.hard => strings.difficultyHard,
    };
  }

  String _localizedCategory(String category) {
    final strings = AppLocalizations.of(context)!;
    return switch (category) {
      'Mixed' => strings.categoryMixed,
      'General Knowledge' => strings.categoryGeneralKnowledge,
      'Science' => strings.categoryScience,
      'Geography' => strings.categoryGeography,
      'Sports' => strings.categorySports,
      'Entertainment' => strings.categoryEntertainment,
      _ => category,
    };
  }

  String _localizedLoadError(String error) {
    final strings = AppLocalizations.of(context)!;
    return switch (error) {
      'You must be signed in to play.' => strings.noUserSignedIn,
      'Join a family before playing Attack or Defend.' =>
        strings.joinOrCreateFamilyBeforeGame(strings.attackOrDefendTitle),
      'Could not load family members.' => strings.couldNotLoadFamilyMembers,
      _ => error,
    };
  }

  int get _winsNeeded => (_selectedRounds ~/ 2) + 1;

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
      _phase = _BattlePhase.loading;
      _loadError = null;
    });

    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final questionCount = max(20, _selectedRounds * 18);

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

        _battleWins
          ..clear()
          ..addAll({selected[0].id: 0, selected[1].id: 0});

        _currentBattle = 1;
        _attackerIndex = 0;

        _resetBattleState();

        _phase = _BattlePhase.passPhone;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _phase = _BattlePhase.setup;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotPrepareAiBattle),
        ),
      );
    }
  }

  void _resetBattleState() {
    _health
      ..clear()
      ..addAll({
        _players[0].id: _startingHealth,
        _players[1].id: _startingHealth,
      });

    _energy
      ..clear()
      ..addAll({_players[0].id: 0, _players[1].id: 0});

    _shield
      ..clear()
      ..addAll({_players[0].id: false, _players[1].id: false});

    _pendingAttack = null;
  }

  _BattlePlayer get _attacker => _players[_attackerIndex];

  int get _defenderIndex => _attackerIndex == 0 ? 1 : 0;

  _BattlePlayer get _defender => _players[_defenderIndex];

  AttackOrDefendQuestion get _nextQuestion {
    if (_questions.isEmpty) {
      throw StateError('No questions loaded.');
    }

    final question = _questions[_questionIndex % _questions.length];

    _questionIndex++;

    return question;
  }

  AttackOrDefendQuestion? _activeQuestion;

  void _beginTurn() {
    setState(() {
      _activeQuestion = _nextQuestion;
      _phase = _BattlePhase.earnEnergyQuestion;
    });
  }

  void _answerEnergyQuestion(int selectedIndex) {
    final question = _activeQuestion;

    if (question == null) return;

    final correct = selectedIndex == question.correctIndex;

    if (correct) {
      final bonus = (_health[_attacker.id] ?? 0) == 1 ? 2 : 1;

      _energy.update(
        _attacker.id,
        (value) => value + bonus,
        ifAbsent: () => bonus,
      );
    }

    setState(() {
      _phase = _BattlePhase.actionChoice;
    });
  }

  void _chooseAction(_BattleAction action) {
    final currentEnergy = _energy[_attacker.id] ?? 0;

    final cost = switch (action) {
      _BattleAction.attack => 1,
      _BattleAction.shield => 1,
      _BattleAction.powerAttack => 2,
      _BattleAction.superAttack => 3,
    };

    if (currentEnergy < cost) {
      return;
    }

    _energy[_attacker.id] = currentEnergy - cost;

    if (action == _BattleAction.shield) {
      _shield[_attacker.id] = true;

      _finishTurn();
      return;
    }

    _pendingAttack = action;

    setState(() {
      _phase = _BattlePhase.passPhone;
    });
  }

  int get _defenseSeconds => switch (_pendingAttack) {
    _BattleAction.attack => 10,
    _BattleAction.powerAttack => 7,
    _BattleAction.superAttack => 5,
    _ => 10,
  };

  int get _attackDamage => switch (_pendingAttack) {
    _BattleAction.superAttack => 2,
    _BattleAction.attack || _BattleAction.powerAttack => 1,
    _ => 0,
  };

  void _beginDefense() {
    _timer?.cancel();

    setState(() {
      _activeQuestion = _nextQuestion;
      _secondsRemaining = _defenseSeconds;
      _phase = _BattlePhase.defenseQuestion;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
        });

        _resolveDefense(false);
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  void _answerDefenseQuestion(int selectedIndex) {
    final question = _activeQuestion;

    if (question == null) return;

    _timer?.cancel();

    _resolveDefense(selectedIndex == question.correctIndex);
  }

  void _resolveDefense(bool answeredCorrectly) {
    if (answeredCorrectly) {
      _pendingAttack = null;
      _finishTurn();
      return;
    }

    if (_shield[_defender.id] == true) {
      _shield[_defender.id] = false;
      _pendingAttack = null;
      _finishTurn();
      return;
    }

    final newHealth = max(0, (_health[_defender.id] ?? 0) - _attackDamage);

    _health[_defender.id] = newHealth;

    _pendingAttack = null;

    if (newHealth <= 0) {
      _completeBattle(_attacker);
      return;
    }

    _finishTurn();
  }

  void _finishTurn() {
    setState(() {
      _attackerIndex = _defenderIndex;
      _phase = _BattlePhase.passPhone;
    });
  }

  void _completeBattle(_BattlePlayer winner) {
    _battleWins.update(winner.id, (value) => value + 1, ifAbsent: () => 1);

    final wins = _battleWins[winner.id] ?? 0;

    if (wins >= _winsNeeded) {
      setState(() {
        _phase = _BattlePhase.finalResults;
      });
      return;
    }

    setState(() {
      _phase = _BattlePhase.battleResult;
    });
  }

  void _startNextBattle() {
    setState(() {
      _currentBattle++;
      _attackerIndex = (_currentBattle - 1) % 2;

      _resetBattleState();

      _phase = _BattlePhase.passPhone;
    });
  }

  _BattlePlayer get _matchWinner {
    final first = _players[0];
    final second = _players[1];

    return (_battleWins[first.id] ?? 0) > (_battleWins[second.id] ?? 0)
        ? first
        : second;
  }

  CompetitionGameResult _buildCompetitionResult() {
    final winner = _matchWinner;

    final loser = _players.firstWhere((player) => player.id != winner.id);

    return CompetitionGameResult(
      gameId: 'attack_or_defend',
      gameName: AppLocalizations.of(context)!.attackOrDefendTitle,
      players: [
        CompetitionPlayerResult(
          userId: winner.id,
          name: winner.name,
          gameScore: _battleWins[winner.id] ?? 0,
          placement: 1,
        ),
        CompetitionPlayerResult(
          userId: loser.id,
          name: loser.name,
          gameScore: _battleWins[loser.id] ?? 0,
          placement: 2,
        ),
      ],
    );
  }

  void _playAgain() {
    setState(() {
      _phase = _BattlePhase.setup;
      _questions = [];
      _questionIndex = 0;
      _activeQuestion = null;
      _battleWins.clear();
      _health.clear();
      _energy.clear();
      _shield.clear();
      _currentBattle = 1;
      _attackerIndex = 0;
      _pendingAttack = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: const SilaGameCoachButton(),
      appBar: AppBar(title: Text(strings.attackOrDefendTitle)),
      body: SafeArea(
        child: switch (_phase) {
          _BattlePhase.setup => _buildSetup(),
          _BattlePhase.loading => _buildLoading(),
          _BattlePhase.passPhone => _buildPassPhone(),
          _BattlePhase.earnEnergyQuestion => _buildQuestion(defending: false),
          _BattlePhase.actionChoice => _buildActionChoice(),
          _BattlePhase.defenseQuestion => _buildQuestion(defending: true),
          _BattlePhase.battleResult => _buildBattleResult(),
          _BattlePhase.finalResults => _buildFinalResults(),
        },
      ),
    );
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _localizedLoadError(_loadError!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GameSetupView(
      icon: Icons.sports_kabaddi_rounded,
      title: strings.attackOrDefendTitle,
      description: strings.attackOrDefendDescription,
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.whoIsBattling,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(strings.chooseExactlyTwoPlayers),
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
          title: strings.bestOf,
          description: strings.bestOfDescription,
        ),
        const SizedBox(height: 16),
        _buildDifficultySelector(),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _selectedPlayerIds.length == 2 ? _startGame : null,
          icon: const Icon(Icons.flash_on_rounded),
          label: Text(strings.startBattle),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    final strings = AppLocalizations.of(context)!;
    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.difficulty,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _BattleDifficulty.values.map((difficulty) {
              final label = switch (difficulty) {
                _BattleDifficulty.easy => strings.difficultyEasy,
                _BattleDifficulty.medium => strings.difficultyMedium,
                _BattleDifficulty.hard => strings.difficultyHard,
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
    final strings = AppLocalizations.of(context)!;
    return GameSetupSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.category, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: _categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(_localizedCategory(category)),
                  ),
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
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(strings.preparingAiBattle),
        ],
      ),
    );
  }

  Widget _buildPassPhone() {
    final strings = AppLocalizations.of(context)!;
    final defending = _pendingAttack != null;

    final player = defending ? _defender : _attacker;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              defending
                  ? Icons.warning_amber_rounded
                  : Icons.phone_android_rounded,
              size: 76,
            ),
            const SizedBox(height: 20),
            Text(
              strings.battleBestOf(_currentBattle, _selectedRounds),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            Text(
              defending
                  ? strings.playerIsAttacking(_attacker.name)
                  : strings.passPhoneTo(player.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (defending)
              Text(
                strings.playerMustBlock(player.name),
                textAlign: TextAlign.center,
              )
            else
              Text(
                strings.otherPlayerLookAwayShort,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: defending ? _beginDefense : _beginTurn,
              child: Text(strings.iAmPlayer(player.name)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion({required bool defending}) {
    final strings = AppLocalizations.of(context)!;
    final question = _activeQuestion!;

    final player = defending ? _defender : _attacker;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBattleStatus(),
              const SizedBox(height: 24),
              Text(
                defending ? strings.defendAction : strings.earnEnergyAction,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (defending) ...[
                const SizedBox(height: 8),
                Text(
                  strings.secondsCount(_secondsRemaining),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      for (
                        var index = 0;
                        index < question.options.length;
                        index++
                      ) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () {
                              if (defending) {
                                _answerDefenseQuestion(index);
                              } else {
                                _answerEnergyQuestion(index);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(question.options[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(player.name, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleStatus() {
    final first = _players[0];
    final second = _players[1];

    return Row(
      children: [
        Expanded(child: _playerStatus(first)),
        const SizedBox(width: 12),
        Expanded(child: _playerStatus(second)),
      ],
    );
  }

  Widget _playerStatus(_BattlePlayer player) {
    final strings = AppLocalizations.of(context)!;
    final health = _health[player.id] ?? 0;
    final energy = _energy[player.id] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('❤️' * health, maxLines: 1, overflow: TextOverflow.fade),
            const SizedBox(height: 6),
            Text('⚡ $energy'),
            if (_shield[player.id] == true) Text(strings.shieldActive),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChoice() {
    final strings = AppLocalizations.of(context)!;
    final energy = _energy[_attacker.id] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBattleStatus(),
              const SizedBox(height: 26),
              Text(
                strings.chooseYourMove(_attacker.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                strings.energyAvailable(energy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _actionButton(
                action: _BattleAction.attack,
                title: strings.attackMove,
                subtitle: strings.attackMoveDescription,
                cost: 1,
              ),
              const SizedBox(height: 12),
              _actionButton(
                action: _BattleAction.shield,
                title: strings.shieldMove,
                subtitle: strings.shieldMoveDescription,
                cost: 1,
              ),
              const SizedBox(height: 12),
              _actionButton(
                action: _BattleAction.powerAttack,
                title: strings.powerAttackMove,
                subtitle: strings.powerAttackMoveDescription,
                cost: 2,
              ),
              const SizedBox(height: 12),
              _actionButton(
                action: _BattleAction.superAttack,
                title: strings.superAttackMove,
                subtitle: strings.superAttackMoveDescription,
                cost: 3,
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _finishTurn,
                child: Text(strings.saveEnergyEndTurn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required _BattleAction action,
    required String title,
    required String subtitle,
    required int cost,
  }) {
    final available = (_energy[_attacker.id] ?? 0) >= cost;

    return FilledButton.tonal(
      onPressed: available ? () => _chooseAction(action) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleResult() {
    final strings = AppLocalizations.of(context)!;
    final first = _players[0];
    final second = _players[1];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_martial_arts_rounded, size: 80),
            const SizedBox(height: 20),
            Text(
              strings.battleNumberComplete(_currentBattle),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(
              strings.playerScore(first.name, _battleWins[first.id] ?? 0),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              strings.playerScore(second.name, _battleWins[second.id] ?? 0),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _startNextBattle,
              child: Text(strings.startBattleNumber(_currentBattle + 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalResults() {
    final strings = AppLocalizations.of(context)!;
    final winner = _matchWinner;
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
                strings.playerWinsBattle(winner.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.battleFinalSummary(
                  _selectedRounds,
                  _difficultyName,
                  _localizedCategory(_selectedCategory),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Card(
                child: ListTile(
                  title: Text(first.name),
                  trailing: Text(
                    '${_battleWins[first.id] ?? 0}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  title: Text(second.name),
                  trailing: Text(
                    '${_battleWins[second.id] ?? 0}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
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
                      ? strings.returnToCompetitionAction
                      : strings.playAgain,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.backToGames),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BattlePlayer {
  const _BattlePlayer({required this.id, required this.name});

  final String id;
  final String name;
}
