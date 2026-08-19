import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/trivia_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';

enum _TriviaPhase {
  setup,
  question,
  steal,
  questionResult,
  roundSummary,
  tieBreaker,
  finalResults,
}

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  final TriviaAiService _aiService = TriviaAiService();

  final List<String> _categories = [
    'Science',
    'Geography',
    'History',
    'Sports',
    'General Knowledge',
  ];

  bool _isLoadingFamily = true;
  bool _isLoadingQuestions = false;

  String? _familyError;

  final List<_TriviaPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  final List<_TriviaPlayer> _teamA = [];
  final List<_TriviaPlayer> _teamB = [];

  String _selectedCategory = 'Science';

  int _selectedRounds = 3;
  int _questionsPerRound = 6;
  int _secondsPerQuestion = 30;

  List<TriviaQuestion> _questions = [];

  int _currentRound = 1;
  int _questionInRound = 0;
  int _globalQuestionIndex = 0;

  int _teamAScore = 0;
  int _teamBScore = 0;
  bool _isTieBreaker = false;

  Timer? _questionTimer;
  int _secondsRemaining = 0;

  int? _selectedAnswer;

  String _questionResultMessage = '';

  _TriviaPhase _phase = _TriviaPhase.setup;

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
    _questionTimer?.cancel();
    super.dispose();
  }

  void _loadPreviewFamilyMembers() {
    const members = [
      _TriviaPlayer(id: 'preview-1', name: 'Alex'),
      _TriviaPlayer(id: 'preview-2', name: 'Sam'),
      _TriviaPlayer(id: 'preview-3', name: 'Jordan'),
      _TriviaPlayer(id: 'preview-4', name: 'Taylor'),
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
          _familyError = 'Join or create a family before playing Trivia.';
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

        return _TriviaPlayer(
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

  void _togglePlayer(_TriviaPlayer player) {
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

  void _assignPlayerToTeam(_TriviaPlayer player, String team) {
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

    final assignedPlayers = _teamA.length + _teamB.length;

    if (assignedPlayers != _selectedPlayerIds.length) {
      return;
    }

    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final totalQuestions = (_selectedRounds * _questionsPerRound) + 1;

      final generated = await _aiService.generateQuestions(
        category: _selectedCategory,
        count: totalQuestions,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (generated.length < totalQuestions) {
        throw Exception('Not enough questions generated');
      }

      if (!mounted) return;

      setState(() {
        _questions = generated;

        _currentRound = 1;
        _questionInRound = 0;
        _globalQuestionIndex = 0;

        _teamAScore = 0;
        _teamBScore = 0;

        _selectedAnswer = null;
        _questionResultMessage = '';

        _isLoadingQuestions = false;
      });

      _startNormalQuestion();
    } catch (error) {
      debugPrint('Trivia start error: $error');
      if (!mounted) return;

      setState(() {
        _isLoadingQuestions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not prepare Trivia. Please try again.'),
        ),
      );
    }
  }

  bool get _teamAStartsQuestion => _globalQuestionIndex.isEven;

  String get _startingTeamName => _teamAStartsQuestion ? 'Team A' : 'Team B';

  String get _stealingTeamName => _teamAStartsQuestion ? 'Team B' : 'Team A';

  void _startNormalQuestion() {
    _questionTimer?.cancel();

    setState(() {
      _selectedAnswer = null;
      _secondsRemaining = _secondsPerQuestion;
      _phase = _TriviaPhase.question;
    });

    _startTimer(seconds: _secondsPerQuestion, onFinished: _startSteal);
  }

  void _startSteal() {
    _questionTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _selectedAnswer = null;
      _secondsRemaining = 10;
      _phase = _TriviaPhase.steal;
    });

    _startTimer(
      seconds: 10,
      onFinished: () {
        final question = _questions[_globalQuestionIndex];

        setState(() {
          _questionResultMessage =
              'No steal.\n\n'
              'Correct answer: '
              '${question.options[question.correctIndex]}';

          _phase = _TriviaPhase.questionResult;
        });
      },
    );
  }

  void _startTimer({required int seconds, required VoidCallback onFinished}) {
    _questionTimer?.cancel();

    _secondsRemaining = seconds;

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _selectNormalAnswer(int index) {
    if (_selectedAnswer != null) return;

    _questionTimer?.cancel();

    final question = _questions[_globalQuestionIndex];

    final correct = index == question.correctIndex;

    if (correct) {
      setState(() {
        _selectedAnswer = index;

        if (_teamAStartsQuestion) {
          _teamAScore += 2;
        } else {
          _teamBScore += 2;
        }

        _questionResultMessage =
            '$_startingTeamName answered correctly!\n\n'
            '+2 points';

        _phase = _TriviaPhase.questionResult;
      });
    } else {
      setState(() {
        _selectedAnswer = index;
      });

      _startSteal();
    }
  }

  void _selectStealAnswer(int index) {
    if (_selectedAnswer != null) return;

    _questionTimer?.cancel();

    final question = _questions[_globalQuestionIndex];

    final correct = index == question.correctIndex;

    if (_isTieBreaker) {
      if (correct) {
        setState(() {
          _teamBScore += 1;
          _selectedAnswer = index;
          _isTieBreaker = false;
          _phase = _TriviaPhase.finalResults;
        });
      } else {
        setState(() {
          _teamAScore += 1;
          _selectedAnswer = index;
          _isTieBreaker = false;
          _phase = _TriviaPhase.finalResults;
        });
      }

      return;
    }

    if (correct) {
      setState(() {
        _selectedAnswer = index;

        if (_teamAStartsQuestion) {
          _teamBScore += 1;
        } else {
          _teamAScore += 1;
        }

        _questionResultMessage =
            '$_stealingTeamName stole the question!\n\n'
            '+1 point';

        _phase = _TriviaPhase.questionResult;
      });
    } else {
      setState(() {
        _selectedAnswer = index;

        _questionResultMessage =
            'Steal missed.\n\n'
            'Correct answer: '
            '${question.options[question.correctIndex]}';

        _phase = _TriviaPhase.questionResult;
      });
    }
  }

  void _continueAfterQuestion() {
    final isLastQuestionInRound = _questionInRound == _questionsPerRound - 1;

    if (isLastQuestionInRound) {
      setState(() {
        _phase = _TriviaPhase.roundSummary;
      });

      return;
    }

    setState(() {
      _questionInRound++;
      _globalQuestionIndex++;
    });

    _startNormalQuestion();
  }

  void _continueAfterRound() {
    final isLastRound = _currentRound == _selectedRounds;

    if (isLastRound) {
      if (_teamAScore == _teamBScore) {
        setState(() {
          _isTieBreaker = true;
          _globalQuestionIndex++;
          _selectedAnswer = null;
          _secondsRemaining = 10;
          _phase = _TriviaPhase.tieBreaker;
        });

        return;
      }

      setState(() {
        _phase = _TriviaPhase.finalResults;
      });

      return;
    }

    setState(() {
      _currentRound++;
      _questionInRound = 0;
      _globalQuestionIndex++;
    });

    _startNormalQuestion();
  }

  void _playAgain() {
    _questionTimer?.cancel();

    setState(() {
      _phase = _TriviaPhase.setup;
      _questions = [];

      _currentRound = 1;
      _questionInRound = 0;
      _globalQuestionIndex = 0;
      _isTieBreaker = false;

      _teamAScore = 0;
      _teamBScore = 0;

      _selectedAnswer = null;
      _questionResultMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: SafeArea(
        child: _phase == _TriviaPhase.setup
            ? _buildSetup()
            : Padding(padding: const EdgeInsets.all(24), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _TriviaPhase.setup => _buildSetup(),
      _TriviaPhase.question => _buildQuestionScreen(),
      _TriviaPhase.steal => _buildStealScreen(),
      _TriviaPhase.questionResult => _buildQuestionResultScreen(),
      _TriviaPhase.roundSummary => _buildRoundSummaryScreen(),
      _TriviaPhase.tieBreaker => _buildTieBreakerScreen(),
      _TriviaPhase.finalResults => _buildFinalResultsScreen(),
    };
  }

  Widget _buildSetup() {
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyError != null) {
      return Center(child: Text(_familyError!, textAlign: TextAlign.center));
    }

    return GameSetupView(
      icon: Icons.quiz_rounded,
      title: 'Trivia',
      description:
          'Build two teams, pick a category, and race through family-friendly questions.',
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
              const Text('Choose at least 2 players for the family match.'),
              const SizedBox(height: 12),
              for (final player in _familyMembers)
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selectedPlayerIds.contains(player.id),
                    onChanged: (_) => _togglePlayer(player),
                    secondary: const Icon(Icons.person_rounded),
                    title: Text(player.name),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose teams',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('Assign every selected player to Team A or Team B.'),
              const SizedBox(height: 14),
              ..._familyMembers
                  .where((player) => _selectedPlayerIds.contains(player.id))
                  .map((player) {
                    final inTeamA = _teamA.any(
                      (member) => member.id == player.id,
                    );
                    final inTeamB = _teamB.any(
                      (member) => member.id == player.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
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
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _selectedPlayerIds.length >= 2
                    ? _shuffleTeams
                    : null,
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Shuffle Teams'),
              ),
              if (_teamA.isNotEmpty || _teamB.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTeamCard(title: 'Team A', players: _teamA),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTeamCard(title: 'Team B', players: _teamB),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: Theme.of(context).textTheme.titleLarge),
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
        ),
        const SizedBox(height: 16),
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Match pace', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              const Text('Questions per round'),
              const SizedBox(height: 9),
              Wrap(
                spacing: 10,
                children: [4, 6, 10].map((questionCount) {
                  return ChoiceChip(
                    label: Text('$questionCount'),
                    selected: _questionsPerRound == questionCount,
                    onSelected: (_) {
                      setState(() {
                        _questionsPerRound = questionCount;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text('Time per question'),
              const SizedBox(height: 9),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [20, 30, 45].map((seconds) {
                  return ChoiceChip(
                    label: Text('$seconds sec'),
                    selected: _secondsPerQuestion == seconds,
                    onSelected: (_) {
                      setState(() {
                        _secondsPerQuestion = seconds;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed:
              _teamA.isNotEmpty &&
                  _teamB.isNotEmpty &&
                  (_teamA.length + _teamB.length ==
                      _selectedPlayerIds.length) &&
                  !_isLoadingQuestions
              ? _startGame
              : null,
          icon: _isLoadingQuestions
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(
            _isLoadingQuestions ? 'Preparing Trivia...' : 'Start Trivia',
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required String title,
    required List<_TriviaPlayer> players,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...players.map((player) => Text(player.name)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_globalQuestionIndex];

    return _buildQuestionLayout(
      heading: '$_startingTeamName\'S TURN',
      question: question,
      seconds: _secondsRemaining,
      onAnswer: _selectNormalAnswer,
    );
  }

  Widget _buildStealScreen() {
    final question = _questions[_globalQuestionIndex];

    return _buildQuestionLayout(
      heading: 'STEAL — $_stealingTeamName',
      question: question,
      seconds: _secondsRemaining,
      onAnswer: _selectStealAnswer,
    );
  }

  Widget _buildQuestionLayout({
    required String heading,
    required TriviaQuestion question,
    required int seconds,
    required ValueChanged<int> onAnswer,
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
            'Question ${_questionInRound + 1} of $_questionsPerRound',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Text(
            '$seconds s',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.tonal(
                onPressed: () => onAnswer(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(question.options[index]),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Team A: $_teamAScore',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Team B: $_teamBScore',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResultScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.fact_check_outlined, size: 72),

            const SizedBox(height: 20),

            Text(
              'Question Complete',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            Text(_questionResultMessage, textAlign: TextAlign.center),

            const SizedBox(height: 28),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Team A\n$_teamAScore', textAlign: TextAlign.center),
                    Text('Team B\n$_teamBScore', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterQuestion,
                child: Text(
                  _questionInRound == _questionsPerRound - 1
                      ? 'Round Results'
                      : 'Next Question',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSummaryScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.flag_outlined, size: 72),

            const SizedBox(height: 20),

            Text(
              'Round $_currentRound Complete',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            Text(
              'Team A: $_teamAScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'Team B: $_teamBScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterRound,
                child: Text(
                  _currentRound == _selectedRounds
                      ? 'See Final Results'
                      : 'Start Round ${_currentRound + 1}',
                ),
              ),
            ),
          ],
        ),
      ),
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
      gameId: CompetitionGameIds.trivia,
      gameName: 'Trivia',
      players: players,
      sharedWin: true,
    );
  }

  Widget _buildFinalResultsScreen() {
    final isTie = _teamAScore == _teamBScore;

    final winner = _teamAScore > _teamBScore ? 'Team A' : 'Team B';

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 80),

            const SizedBox(height: 20),

            Text(
              isTie ? 'Trivia Tie!' : '$winner Wins!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            Text(
              'Team A: $_teamAScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'Team B: $_teamBScore',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
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
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Games'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTieBreakerScreen() {
    final question = _questions[_globalQuestionIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TIE-BREAKER',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'One final question decides the winner.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Text(
            '10 s',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.tonal(
                onPressed: () => _selectTieBreakerAnswer(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(question.options[index]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _selectTieBreakerAnswer(int index) {
    if (_selectedAnswer != null) return;

    final question = _questions[_globalQuestionIndex];
    final correct = index == question.correctIndex;

    if (correct) {
      setState(() {
        _teamAScore += 1;
        _selectedAnswer = index;
        _phase = _TriviaPhase.finalResults;
      });

      return;
    }

    setState(() {
      _selectedAnswer = index;
    });

    _startTieBreakerSteal();
  }

  void _startTieBreakerSteal() {
    _questionTimer?.cancel();

    setState(() {
      _selectedAnswer = null;
      _secondsRemaining = 10;
      _phase = _TriviaPhase.steal;
    });

    _startTimer(
      seconds: 10,
      onFinished: () {
        setState(() {
          _teamAScore += 1;
          _phase = _TriviaPhase.finalResults;
        });
      },
    );
  }
}

class _TriviaPlayer {
  const _TriviaPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
