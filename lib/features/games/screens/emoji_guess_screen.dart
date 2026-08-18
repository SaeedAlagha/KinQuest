import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/emoji_guess_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';

enum _EmojiGuessPhase {
  setup,
  puzzle,
  steal,
  puzzleResult,
  roundSummary,
  tieBreaker,
  finalResults,
}

class EmojiGuessScreen extends StatefulWidget {
  const EmojiGuessScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<EmojiGuessScreen> createState() => _EmojiGuessScreenState();
}

class _EmojiGuessScreenState extends State<EmojiGuessScreen> {
  final EmojiGuessAiService _aiService = EmojiGuessAiService();

  final List<String> _categories = [
    'Movies',
    'Animals',
    'Food',
    'Places',
    'Mixed',
  ];

  bool _isLoadingFamily = true;
  bool _isLoadingPuzzles = false;

  String? _familyError;

  final List<_EmojiPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  final List<_EmojiPlayer> _teamA = [];
  final List<_EmojiPlayer> _teamB = [];

  String _selectedCategory = 'Movies';

  int _selectedRounds = 3;
  int _puzzlesPerRound = 6;
  int _secondsPerPuzzle = 30;

  List<EmojiGuessPuzzle> _puzzles = [];

  int _currentRound = 1;
  int _puzzleInRound = 0;
  int _globalPuzzleIndex = 0;

  int _teamAScore = 0;
  int _teamBScore = 0;

  Timer? _timer;
  int _secondsRemaining = 0;

  String _resultMessage = '';

  bool _isTieBreaker = false;

  final TextEditingController _answerController = TextEditingController();

  bool _isCheckingAnswer = false;

  _EmojiGuessPhase _phase = _EmojiGuessPhase.setup;

  @override
  void initState() {
    super.initState();
    if (widget.developerPreview) {
      _loadPreviewFamilyMembers();
    } else {
      _loadFamilyMembers();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _loadPreviewFamilyMembers() {
    const members = [
      _EmojiPlayer(id: 'preview-1', name: 'Alex'),
      _EmojiPlayer(id: 'preview-2', name: 'Sam'),
      _EmojiPlayer(id: 'preview-3', name: 'Jordan'),
      _EmojiPlayer(id: 'preview-4', name: 'Taylor'),
    ];
    final availableMembers = widget.participantIds == null
        ? members
        : members
              .where((member) => widget.participantIds!.contains(member.id))
              .toList();

    _familyMembers
      ..clear()
      ..addAll(availableMembers);
    _selectedPlayerIds
      ..clear()
      ..addAll(availableMembers.map((member) => member.id));
    _isLoadingFamily = false;
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoadingFamily = false;
        _familyError = 'You must be logged in to play.';
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
          _isLoadingFamily = false;
          _familyError = 'Join or create a family before playing Emoji Guess.';
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name'] as String?;
        final email = data['email'] as String?;

        return _EmojiPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;
      final availableMembers = widget.participantIds == null
          ? members
          : members
                .where((member) => widget.participantIds!.contains(member.id))
                .toList();

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(availableMembers);

        if (widget.participantIds != null) {
          _selectedPlayerIds
            ..clear()
            ..addAll(availableMembers.map((member) => member.id));
        }

        _isLoadingFamily = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingFamily = false;
        _familyError = 'Could not load your family members.';
      });
    }
  }

  void _togglePlayer(_EmojiPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);

        _teamA.removeWhere((member) => member.id == player.id);

        _teamB.removeWhere((member) => member.id == player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  void _assignPlayerToTeam(_EmojiPlayer player, String team) {
    setState(() {
      _teamA.removeWhere((member) => member.id == player.id);

      _teamB.removeWhere((member) => member.id == player.id);

      if (team == 'A') {
        _teamA.add(player);
      } else {
        _teamB.add(player);
      }
    });
  }

  void _shuffleTeams() {
    final selectedPlayers =
        _familyMembers
            .where((player) => _selectedPlayerIds.contains(player.id))
            .toList()
          ..shuffle(Random());

    setState(() {
      _teamA.clear();
      _teamB.clear();

      for (int i = 0; i < selectedPlayers.length; i++) {
        if (i.isEven) {
          _teamA.add(selectedPlayers[i]);
        } else {
          _teamB.add(selectedPlayers[i]);
        }
      }
    });
  }

  Future<void> _startGame() async {
    if (_teamA.isEmpty || _teamB.isEmpty) {
      return;
    }

    if (_teamA.length + _teamB.length != _selectedPlayerIds.length) {
      return;
    }

    setState(() {
      _isLoadingPuzzles = true;
    });

    try {
      final totalPuzzles = (_selectedRounds * _puzzlesPerRound) + 1;

      final generated = await _aiService.generatePuzzles(
        category: _selectedCategory,
        count: totalPuzzles,
      );

      if (generated.length < totalPuzzles) {
        throw Exception('Not enough puzzles generated');
      }

      if (!mounted) return;

      setState(() {
        _puzzles = generated;

        _currentRound = 1;
        _puzzleInRound = 0;
        _globalPuzzleIndex = 0;

        _teamAScore = 0;
        _teamBScore = 0;

        _resultMessage = '';
        _isTieBreaker = false;

        _isLoadingPuzzles = false;
      });

      _startNormalPuzzle();
    } catch (error) {
      debugPrint('Emoji Guess start error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingPuzzles = false;
      });
    }
  }

  bool get _teamAStartsPuzzle => _globalPuzzleIndex.isEven;

  String get _startingTeamName => _teamAStartsPuzzle ? 'Team A' : 'Team B';

  String get _stealingTeamName => _teamAStartsPuzzle ? 'Team B' : 'Team A';

  void _startNormalPuzzle() {
    _timer?.cancel();

    setState(() {
      _answerController.clear();
      _secondsRemaining = _secondsPerPuzzle;
      _phase = _EmojiGuessPhase.puzzle;
    });

    _startTimer(seconds: _secondsPerPuzzle, onFinished: _startSteal);
  }

  void _startSteal() {
    _timer?.cancel();

    setState(() {
      _answerController.clear();
      _secondsRemaining = 10;
      _phase = _EmojiGuessPhase.steal;
    });

    _startTimer(
      seconds: 10,
      onFinished: () {
        final puzzle = _puzzles[_globalPuzzleIndex];

        if (_isTieBreaker) {
          setState(() {
            if (_teamAStartsPuzzle) {
              _teamAScore++;
            } else {
              _teamBScore++;
            }

            _isTieBreaker = false;
            _phase = _EmojiGuessPhase.finalResults;
          });

          return;
        }

        setState(() {
          _resultMessage =
              'No steal.\n\n'
              'Answer: ${puzzle.answer}';

          _phase = _EmojiGuessPhase.puzzleResult;
        });
      },
    );
  }

  void _startTimer({required int seconds, required VoidCallback onFinished}) {
    _timer?.cancel();

    _secondsRemaining = seconds;

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

        onFinished();
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  void _handleCorrectNormalAnswer() {
    _timer?.cancel();

    if (_isTieBreaker) {
      setState(() {
        if (_teamAStartsPuzzle) {
          _teamAScore++;
        } else {
          _teamBScore++;
        }

        _isTieBreaker = false;
        _phase = _EmojiGuessPhase.finalResults;
      });

      return;
    }

    setState(() {
      if (_teamAStartsPuzzle) {
        _teamAScore += 2;
      } else {
        _teamBScore += 2;
      }

      _resultMessage =
          '$_startingTeamName guessed correctly!\n\n'
          '+2 points';

      _phase = _EmojiGuessPhase.puzzleResult;
    });
  }

  void _handleCorrectSteal() {
    _timer?.cancel();

    if (_isTieBreaker) {
      setState(() {
        if (_teamAStartsPuzzle) {
          _teamBScore++;
        } else {
          _teamAScore++;
        }

        _isTieBreaker = false;
        _phase = _EmojiGuessPhase.finalResults;
      });

      return;
    }

    setState(() {
      if (_teamAStartsPuzzle) {
        _teamBScore += 1;
      } else {
        _teamAScore += 1;
      }

      _resultMessage =
          '$_stealingTeamName stole the puzzle!\n\n'
          '+1 point';

      _phase = _EmojiGuessPhase.puzzleResult;
    });
  }

  void _handleFailedSteal() {
    _timer?.cancel();

    final puzzle = _puzzles[_globalPuzzleIndex];

    if (_isTieBreaker) {
      setState(() {
        if (_teamAStartsPuzzle) {
          _teamAScore++;
        } else {
          _teamBScore++;
        }

        _isTieBreaker = false;
        _phase = _EmojiGuessPhase.finalResults;
      });

      return;
    }

    setState(() {
      _resultMessage =
          'Steal missed.\n\n'
          'Answer: ${puzzle.answer}';

      _phase = _EmojiGuessPhase.puzzleResult;
    });
  }

  void _continueAfterPuzzle() {
    final isLastPuzzleInRound = _puzzleInRound == _puzzlesPerRound - 1;

    if (isLastPuzzleInRound) {
      setState(() {
        _phase = _EmojiGuessPhase.roundSummary;
      });

      return;
    }

    setState(() {
      _puzzleInRound++;
      _globalPuzzleIndex++;
    });

    _startNormalPuzzle();
  }

  void _continueAfterRound() {
    final isLastRound = _currentRound == _selectedRounds;

    if (isLastRound) {
      if (_teamAScore == _teamBScore) {
        setState(() {
          _globalPuzzleIndex++;
          _isTieBreaker = true;
          _secondsRemaining = 10;
          _phase = _EmojiGuessPhase.tieBreaker;
        });

        _startTimer(seconds: 10, onFinished: _startSteal);

        return;
      }

      setState(() {
        _phase = _EmojiGuessPhase.finalResults;
      });

      return;
    }

    setState(() {
      _currentRound++;
      _puzzleInRound = 0;
      _globalPuzzleIndex++;
    });

    _startNormalPuzzle();
  }

  void _playAgain() {
    _timer?.cancel();

    setState(() {
      _phase = _EmojiGuessPhase.setup;
      _puzzles = [];

      _currentRound = 1;
      _puzzleInRound = 0;
      _globalPuzzleIndex = 0;

      _teamAScore = 0;
      _teamBScore = 0;

      _resultMessage = '';
      _isTieBreaker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Guess')),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(24), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _EmojiGuessPhase.setup => _buildSetup(),
      _EmojiGuessPhase.puzzle => _buildPuzzleScreen(),
      _EmojiGuessPhase.steal => _buildStealScreen(),
      _EmojiGuessPhase.puzzleResult => _buildPuzzleResultScreen(),
      _EmojiGuessPhase.roundSummary => _buildRoundSummaryScreen(),
      _EmojiGuessPhase.tieBreaker => _buildTieBreakerScreen(),
      _EmojiGuessPhase.finalResults => _buildFinalResultsScreen(),
    };
  }

  Widget _buildSetup() {
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyError != null) {
      return Center(child: Text(_familyError!, textAlign: TextAlign.center));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who is playing?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text('Choose at least 2 players.'),

          const SizedBox(height: 16),

          ..._familyMembers.map((player) {
            final selected = _selectedPlayerIds.contains(player.id);

            return CheckboxListTile(
              value: selected,
              onChanged: (_) => _togglePlayer(player),
              title: Text(player.name),
            );
          }),

          const SizedBox(height: 24),

          Text(
            'Choose teams',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text('Assign every selected player to Team A or Team B.'),

          const SizedBox(height: 16),

          ..._familyMembers
              .where((player) => _selectedPlayerIds.contains(player.id))
              .map((player) {
                final inTeamA = _teamA.any((member) => member.id == player.id);

                final inTeamB = _teamB.any((member) => member.id == player.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          ChoiceChip(
                            label: const Text('Team A'),
                            selected: inTeamA,
                            onSelected: (_) {
                              _assignPlayerToTeam(player, 'A');
                            },
                          ),

                          const SizedBox(width: 8),

                          ChoiceChip(
                            label: const Text('Team B'),
                            selected: inTeamB,
                            onSelected: (_) {
                              _assignPlayerToTeam(player, 'B');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _selectedPlayerIds.length >= 2 ? _shuffleTeams : null,
            icon: const Icon(Icons.shuffle),
            label: const Text('Shuffle Teams'),
          ),

          const SizedBox(height: 24),

          Text(
            'Category',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: category == _selectedCategory,
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          GameRoundSelector(
            value: _selectedRounds,
            onChanged: (rounds) {
              setState(() {
                _selectedRounds = rounds;
              });
            },
          ),

          const SizedBox(height: 28),

          Text(
            'Puzzles per round',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            children: [4, 6, 10].map((puzzleCount) {
              return ChoiceChip(
                label: Text('$puzzleCount'),
                selected: _puzzlesPerRound == puzzleCount,
                onSelected: (_) {
                  setState(() {
                    _puzzlesPerRound = puzzleCount;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          Text(
            'Time per puzzle',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            children: [20, 30, 45].map((seconds) {
              return ChoiceChip(
                label: Text('$seconds sec'),
                selected: _secondsPerPuzzle == seconds,
                onSelected: (_) {
                  setState(() {
                    _secondsPerPuzzle = seconds;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          FilledButton(
            onPressed:
                _teamA.isNotEmpty &&
                    _teamB.isNotEmpty &&
                    (_teamA.length + _teamB.length ==
                        _selectedPlayerIds.length) &&
                    !_isLoadingPuzzles
                ? _startGame
                : null,
            child: _isLoadingPuzzles
                ? const CircularProgressIndicator()
                : const Text('Start Emoji Guess'),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleScreen() {
    final puzzle = _puzzles[_globalPuzzleIndex];

    return _buildPuzzleLayout(
      heading: '$_startingTeamName\'S TURN',
      puzzle: puzzle,
      steal: false,
    );
  }

  Widget _buildStealScreen() {
    final puzzle = _puzzles[_globalPuzzleIndex];

    return _buildPuzzleLayout(
      heading: 'STEAL — $_stealingTeamName',
      puzzle: puzzle,
      steal: true,
    );
  }

  Widget _buildPuzzleLayout({
    required String heading,
    required EmojiGuessPuzzle puzzle,
    required bool steal,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            heading,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Round $_currentRound of $_selectedRounds • '
            'Puzzle ${_puzzleInRound + 1} of $_puzzlesPerRound',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Text(
            '$_secondsRemaining s',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 32),

          Text(
            puzzle.emojis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 72),
          ),

          const SizedBox(height: 24),

          Text(
            'Hint: ${puzzle.hint}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 36),

          TextField(
            controller: _answerController,
            enabled: !_isCheckingAnswer,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Type your answer',
              prefixIcon: Icon(Icons.edit_outlined),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _submitTypedAnswer(steal: steal);
            },
          ),

          const SizedBox(height: 14),

          FilledButton.icon(
            onPressed: _isCheckingAnswer
                ? null
                : () {
                    _submitTypedAnswer(steal: steal);
                  },
            icon: _isCheckingAnswer
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_isCheckingAnswer ? 'Checking...' : 'Submit Answer'),
          ),

          const SizedBox(height: 24),

          Text(
            'Team A: $_teamAScore     Team B: $_teamBScore',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleResultScreen() {
    final puzzle = _puzzles[_globalPuzzleIndex];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Puzzle Complete',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          Text(_resultMessage, textAlign: TextAlign.center),

          const SizedBox(height: 18),

          Text(
            'Answer: ${puzzle.answer}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 28),

          FilledButton(
            onPressed: _continueAfterPuzzle,
            child: Text(
              _puzzleInRound == _puzzlesPerRound - 1
                  ? 'Round Results'
                  : 'Next Puzzle',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSummaryScreen() {
    final isLastRound = _currentRound == _selectedRounds;

    final isTie = _teamAScore == _teamBScore;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Round $_currentRound Complete',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 28),

          Text('Team A: $_teamAScore'),
          const SizedBox(height: 10),
          Text('Team B: $_teamBScore'),

          const SizedBox(height: 32),

          FilledButton(
            onPressed: _continueAfterRound,
            child: Text(
              isLastRound
                  ? isTie
                        ? 'Start Tie-Breaker'
                        : 'See Final Results'
                  : 'Start Round ${_currentRound + 1}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTieBreakerScreen() {
    final puzzle = _puzzles[_globalPuzzleIndex];

    return _buildPuzzleLayout(
      heading: 'TIE-BREAKER — $_startingTeamName',
      puzzle: puzzle,
      steal: false,
    );
  }

  CompetitionGameResult _buildCompetitionResult() {
    final teamAWon = _teamAScore > _teamBScore;

    final winningTeam = teamAWon ? _teamA : _teamB;
    final losingTeam = teamAWon ? _teamB : _teamA;

    final players = <CompetitionPlayerResult>[
      ...winningTeam.map(
        (player) => CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: 1,
          placement: 1,
        ),
      ),
      ...losingTeam.map(
        (player) => CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: 0,
          placement: 2,
        ),
      ),
    ];

    return CompetitionGameResult(
      gameId: CompetitionGameIds.emojiGuess,
      gameName: 'Emoji Guess',
      players: players,
      sharedWin: true,
    );
  }

  Widget _buildFinalResultsScreen() {
    final winner = _teamAScore > _teamBScore ? 'Team A' : 'Team B';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 80),

          const SizedBox(height: 20),

          Text(
            '$winner Wins!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 28),

          Text('Team A: $_teamAScore'),
          const SizedBox(height: 10),
          Text('Team B: $_teamBScore'),

          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              if (widget.playMode.isOfficial) {
                Navigator.of(context).pop(_buildCompetitionResult());
                return;
              }

              _playAgain();
            },
            child: Text(
              widget.playMode.isOfficial
                  ? 'Return to ${widget.playMode.displayName}'
                  : 'Play Again',
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTypedAnswer({required bool steal}) async {
    final answer = _answerController.text.trim();

    if (answer.isEmpty || _isCheckingAnswer) {
      return;
    }

    _timer?.cancel();

    setState(() {
      _isCheckingAnswer = true;
    });

    final puzzle = _puzzles[_globalPuzzleIndex];

    bool correct = false;

    try {
      correct = await _aiService.checkAnswer(
        expectedAnswer: puzzle.answer,
        playerAnswer: answer,
      );
    } catch (_) {
      correct = false;
    }

    if (!mounted) return;

    setState(() {
      _isCheckingAnswer = false;
    });

    if (correct) {
      if (steal) {
        _handleCorrectSteal();
      } else {
        _handleCorrectNormalAnswer();
      }

      return;
    }

    if (steal) {
      _handleFailedSteal();
    } else {
      _startSteal();
    }
  }
}

class _EmojiPlayer {
  const _EmojiPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
