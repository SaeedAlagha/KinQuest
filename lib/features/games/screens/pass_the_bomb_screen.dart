import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/pass_the_bomb_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

enum _BombPhase { setup, playing, roundResult, finalLeaderboard }

enum _BombLoadError { signedOut, noFamily, loadFailed }

class PassTheBombScreen extends StatefulWidget {
  const PassTheBombScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<PassTheBombScreen> createState() => _PassTheBombScreenState();
}

class _PassTheBombScreenState extends State<PassTheBombScreen> {
  int _selectedRounds = 3;

  final _aiService = const PassTheBombAiService();
  final _answerController = TextEditingController();
  final _random = Random.secure();

  final List<_BombPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_BombPlayer> _players = [];
  List<String> _categories = [];

  final Map<String, int> _scores = {};
  final Set<String> _usedAnswers = {};

  bool _isLoading = true;
  bool _isStartingGame = false;
  bool _isValidatingAnswer = false;
  _BombLoadError? _loadError;

  int _currentRoundIndex = 0;
  int _currentPlayerIndex = 0;

  String? _roundLoserId;

  Timer? _bombTimer;

  _BombPhase _phase = _BombPhase.setup;

  @override
  void initState() {
    super.initState();
    if (widget.developerPreview) {
      _loadPreviewMembers();
    } else {
      _loadFamilyMembers();
    }
  }

  void _loadPreviewMembers() {
    const members = [
      _BombPlayer(id: 'preview-1', name: 'Alex'),
      _BombPlayer(id: 'preview-2', name: 'Sam'),
      _BombPlayer(id: 'preview-3', name: 'Jordan'),
      _BombPlayer(id: 'preview-4', name: 'Taylor'),
    ];
    final availableMembers = widget.participantIds == null
        ? members
        : members
              .where((member) => widget.participantIds!.contains(member.id))
              .toList();
    _familyMembers.addAll(availableMembers);
    _selectedPlayerIds.addAll(availableMembers.map((member) => member.id));
    _isLoading = false;
  }

  @override
  void dispose() {
    _bombTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _BombLoadError.signedOut;
      });

      return;
    }

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDocument.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _loadError = _BombLoadError.noFamily;
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) {
        return;
      }
      final strings = AppLocalizations.of(context)!;
      final members = membersSnapshot.docs
          .where(
            (document) =>
                widget.participantIds == null ||
                widget.participantIds!.contains(document.id),
          )
          .map((document) {
            final data = document.data();

            final name = data['name'] as String?;
            final email = data['email'] as String?;

            return _BombPlayer(
              id: document.id,
              name: name?.trim().isNotEmpty == true
                  ? name!
                  : email ?? strings.familyMemberFallback,
            );
          })
          .toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(members);

        _selectedPlayerIds
          ..clear()
          ..addAll(widget.participantIds ?? members.map((member) => member.id));

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _BombLoadError.loadFailed;
      });
    }
  }

  void _togglePlayer(_BombPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  Future<void> _startGame() async {
    final strings = AppLocalizations.of(context)!;
    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.minimumPlayersForGame(strings.passTheBomb, 2)),
        ),
      );

      return;
    }

    setState(() {
      _isStartingGame = true;
    });

    try {
      final selectedPlayers = _familyMembers
          .where((player) => _selectedPlayerIds.contains(player.id))
          .toList();
      final languageCode = Localizations.localeOf(context).languageCode;
      List<String> categories;

      if (widget.developerPreview) {
        categories = PassTheBombAiService.offlineCategories(
          count: _selectedRounds,
          languageCode: languageCode,
        );
      } else {
        try {
          categories = await _aiService.generateCategories(
            count: _selectedRounds,
            languageCode: languageCode,
          );
        } catch (_) {
          categories = PassTheBombAiService.offlineCategories(
            count: _selectedRounds,
            languageCode: languageCode,
          );
        }
      }

      if (categories.length < _selectedRounds) {
        categories = PassTheBombAiService.offlineCategories(
          count: _selectedRounds,
          languageCode: languageCode,
        );
      }

      final shuffledPlayers = List<_BombPlayer>.from(selectedPlayers)
        ..shuffle(_random);

      final scores = <String, int>{};

      for (final player in shuffledPlayers) {
        scores[player.id] = 0;
      }

      if (!mounted) return;

      setState(() {
        _players = shuffledPlayers;
        _categories = categories;

        _scores
          ..clear()
          ..addAll(scores);

        _currentRoundIndex = 0;
        _currentPlayerIndex = 0;
        _phase = _BombPhase.playing;
        _isStartingGame = false;
      });

      _startBomb();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isStartingGame = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotStartGame(strings.passTheBomb))),
      );
    }
  }

  void _startBomb() {
    _bombTimer?.cancel();

    _usedAnswers.clear();
    _answerController.clear();

    final seconds = 20 + _random.nextInt(16);

    _bombTimer = Timer(Duration(seconds: seconds), _explodeBomb);
  }

  void _explodeBomb() {
    if (!mounted || _phase != _BombPhase.playing || _players.isEmpty) {
      return;
    }

    final loser = _players[_currentPlayerIndex];

    _bombTimer?.cancel();

    for (final player in _players) {
      if (player.id != loser.id) {
        _scores[player.id] = (_scores[player.id] ?? 0) + 1;
      }
    }

    setState(() {
      _roundLoserId = loser.id;
      _phase = _BombPhase.roundResult;
    });
  }

  Future<void> _submitAnswer() async {
    final strings = AppLocalizations.of(context)!;
    if (_isValidatingAnswer ||
        _phase != _BombPhase.playing ||
        _players.isEmpty ||
        _categories.isEmpty) {
      return;
    }

    final answer = _answerController.text.trim();

    if (answer.isEmpty) {
      return;
    }

    final normalizedAnswer = answer.toLowerCase();

    if (_usedAnswers.contains(normalizedAnswer)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.answerAlreadyUsed)));

      return;
    }

    final playerIndexWhenSubmitted = _currentPlayerIndex;
    final roundIndexWhenSubmitted = _currentRoundIndex;
    final category = _categories[_currentRoundIndex];

    setState(() {
      _isValidatingAnswer = true;
    });

    try {
      PassTheBombValidationResult result;
      if (widget.developerPreview) {
        result = const PassTheBombValidationResult(valid: true, reason: '');
      } else {
        try {
          result = await _aiService.validateAnswer(
            category: category,
            answer: answer,
            languageCode: Localizations.localeOf(context).languageCode,
          );
        } catch (_) {
          result = const PassTheBombValidationResult(valid: true, reason: '');
        }
      }

      if (!mounted) {
        return;
      }

      // The bomb may have exploded while Gemini was checking.
      if (_phase != _BombPhase.playing ||
          _currentRoundIndex != roundIndexWhenSubmitted ||
          _currentPlayerIndex != playerIndexWhenSubmitted) {
        return;
      }

      if (!result.valid) {
        setState(() {
          _isValidatingAnswer = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.reason.isEmpty
                  ? strings.answerDoesNotFitCategory
                  : strings.reasonTryAgain(result.reason),
            ),
          ),
        );

        // Same player keeps their turn.
        _answerController.clear();

        return;
      }

      _usedAnswers.add(normalizedAnswer);

      setState(() {
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;

        _answerController.clear();
        _isValidatingAnswer = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (_phase == _BombPhase.playing) {
        setState(() {
          _isValidatingAnswer = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.couldNotCheckAnswer)));
      }
    }
  }

  void _nextRound() {
    if (_currentRoundIndex + 1 >= _selectedRounds) {
      _bombTimer?.cancel();

      setState(() {
        _phase = _BombPhase.finalLeaderboard;
      });

      return;
    }

    setState(() {
      _currentRoundIndex++;
      _roundLoserId = null;

      _currentPlayerIndex = _random.nextInt(_players.length);

      _phase = _BombPhase.playing;
    });

    _startBomb();
  }

  void _playAgain() {
    _bombTimer?.cancel();

    setState(() {
      _phase = _BombPhase.setup;

      _players = [];
      _categories = [];

      _scores.clear();
      _usedAnswers.clear();

      _selectedPlayerIds.clear();

      _currentRoundIndex = 0;
      _currentPlayerIndex = 0;

      _roundLoserId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final gameInProgress =
        _phase != _BombPhase.setup && _phase != _BombPhase.finalLeaderboard;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: gameInProgress
            ? SilaGameCoachButton(
                tone: _phase == _BombPhase.roundResult
                    ? SilaGameCoachTone.celebrating
                    : SilaGameCoachTone.play,
              )
            : null,
        appBar: AppBar(title: Text(strings.passTheBomb)),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _BombPhase.playing:
        return _buildPlayingScreen();

      case _BombPhase.roundResult:
        return _buildRoundResultScreen();

      case _BombPhase.finalLeaderboard:
        return _buildLeaderboardScreen();

      case _BombPhase.setup:
        return _buildSetupScreen();
    }
  }

  Widget _buildSetupScreen() {
    final strings = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      final errorMessage = switch (_loadError!) {
        _BombLoadError.signedOut => strings.mustBeLoggedInToPlay,
        _BombLoadError.noFamily => strings.joinOrCreateFamilyBeforeGame(
          strings.passTheBomb,
        ),
        _BombLoadError.loadFailed => strings.couldNotLoadFamilyMembers,
      };
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });

                  _loadFamilyMembers();
                },
                child: Text(strings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_familyMembers.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.minimumFamilyMembersForGame(strings.passTheBomb, 2),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.whoIsPlaying,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(strings.chooseTogetherPlayers),
          const SizedBox(height: 10),
          Text(strings.bombSetupInstructions),
          const SizedBox(height: 18),
          GameRoundSelector(
            value: _selectedRounds,
            onChanged: (rounds) {
              setState(() {
                _selectedRounds = rounds;
              });
            },
            keyPrefix: 'bomb-round-option',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _familyMembers.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SilaGameCoachBanner(
                    message: strings.mascotGameSetupMessage,
                  );
                }

                final player = _familyMembers[index - 1];

                final selected = _selectedPlayerIds.contains(player.id);

                return Card(
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: widget.participantIds == null
                        ? (_) => _togglePlayer(player)
                        : null,
                    title: Text(player.name),
                    secondary: CircleAvatar(
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isStartingGame ? null : _startGame,
            icon: _isStartingGame
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.timer_rounded),
            label: Text(
              _isStartingGame
                  ? strings.generatingCategories
                  : strings.startNamedGame(strings.passTheBomb),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingScreen() {
    final currentPlayer = _players[_currentPlayerIndex];
    final category = _categories[_currentRoundIndex];
    final strings = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.roundProgress(_currentRoundIndex + 1, _selectedRounds),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    children: [
                      const Icon(Icons.timer_rounded, size: 70),
                      const SizedBox(height: 18),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.playerTurn(currentPlayer.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(strings.sayTypePass, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              TextField(
                controller: _answerController,
                textInputAction: TextInputAction.done,
                enabled: !_isValidatingAnswer,
                decoration: InputDecoration(
                  labelText: strings.yourAnswer,
                  hintText: _isValidatingAnswer
                      ? strings.checkingAnswer
                      : strings.typeSpokenAnswer,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submitAnswer(),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _isValidatingAnswer ? null : _submitAnswer,
                icon: _isValidatingAnswer
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _isValidatingAnswer
                      ? strings.checkingAnswer
                      : strings.submitAndPassPhone,
                ),
              ),
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          strings.bombHiddenTimer,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.answersUsedThisRound(_usedAnswers.length),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundResultScreen() {
    final loser = _players.firstWhere((player) => player.id == _roundLoserId);
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const Text('💥', style: TextStyle(fontSize: 90)),
              const SizedBox(height: 16),
              Text(
                strings.boom,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                strings.playerHeldBomb(loser.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(strings.bombSurvivorPoint, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _nextRound,
                child: Text(
                  _currentRoundIndex + 1 >= _selectedRounds
                      ? strings.viewFinalLeaderboard
                      : strings.nextRound,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CompetitionGameResult _buildCompetitionResult() {
    final rankedPlayers = List<_BombPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final results = <CompetitionPlayerResult>[];

    for (var index = 0; index < rankedPlayers.length; index++) {
      final player = rankedPlayers[index];

      results.add(
        CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: _scores[player.id] ?? 0,
          placement: index + 1,
        ),
      );
    }

    return CompetitionGameResult(
      gameId: CompetitionGameIds.passTheBomb,
      gameName: 'Pass the Bomb',
      players: results,
    );
  }

  Widget _buildLeaderboardScreen() {
    final strings = AppLocalizations.of(context)!;
    final rankedPlayers = List<_BombPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final isOfficial = widget.playMode.isOfficial;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          isOfficial
              ? strings.officialResultsTitle(
                  widget.playMode.localizedName(strings),
                )
              : strings.quickPlayLeaderboard,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          isOfficial
              ? strings.officialGameResultsReady
              : strings.quickPlayResultsOnly,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(rankedPlayers.length, (index) {
          final player = rankedPlayers[index];
          final score = _scores[player.id] ?? 0;

          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(player.name),
              trailing: Text(
                strings.pointsAbbreviation(score),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),

        if (!isOfficial) ...[
          FilledButton.icon(
            onPressed: _playAgain,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(strings.playAgain),
          ),
          const SizedBox(height: 10),
        ],

        OutlinedButton(
          onPressed: () {
            if (isOfficial) {
              Navigator.of(context).pop(_buildCompetitionResult());
              return;
            }

            Navigator.of(context).pop();
          },
          child: Text(
            isOfficial
                ? strings.returnToCompetition(
                    widget.playMode.localizedName(strings),
                  )
                : strings.backToQuickPlay,
          ),
        ),
      ],
    );
  }
}

class _BombPlayer {
  const _BombPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
