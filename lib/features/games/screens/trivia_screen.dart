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
import '../services/trivia_ai_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

enum _TriviaPhase {
  setup,
  question,
  steal,
  questionResult,
  roundSummary,
  tieBreaker,
  finalResults,
}

enum _TriviaFamilyError { signedOut, noFamily, loadFailed }

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

  _TriviaFamilyError? _familyError;

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
        _familyError = _TriviaFamilyError.signedOut;
      });
      return;
    }

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final familyId = userDocument.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoadingFamily = false;
          _familyError = _TriviaFamilyError.noFamily;
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) return;

      final fallbackName = AppLocalizations.of(context)!.familyMemberFallback;

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name'] as String?;
        final email = data['email'] as String?;

        return _TriviaPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true ? name! : email ?? fallbackName,
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
        _familyError = _TriviaFamilyError.loadFailed;
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotPrepareTrivia),
        ),
      );
    }
  }

  bool get _teamAStartsQuestion => _globalQuestionIndex.isEven;

  AppLocalizations get _strings => AppLocalizations.of(context)!;

  String get _startingTeamName =>
      _teamAStartsQuestion ? _strings.teamA : _strings.teamB;

  String get _stealingTeamName =>
      _teamAStartsQuestion ? _strings.teamB : _strings.teamA;

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
          _questionResultMessage = _strings.noStealCorrectAnswer(
            question.options[question.correctIndex],
          );

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

        _questionResultMessage = _strings.teamAnsweredCorrectly(
          _startingTeamName,
          2,
        );

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

        _questionResultMessage = _strings.teamStoleQuestion(
          _stealingTeamName,
          1,
        );

        _phase = _TriviaPhase.questionResult;
      });
    } else {
      setState(() {
        _selectedAnswer = index;

        _questionResultMessage = _strings.stealMissedCorrectAnswer(
          question.options[question.correctIndex],
        );

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

  String _familyErrorMessage(
    AppLocalizations strings,
    _TriviaFamilyError error,
  ) {
    return switch (error) {
      _TriviaFamilyError.signedOut => strings.mustBeLoggedInToPlay,
      _TriviaFamilyError.noFamily => strings.triviaFamilyRequired,
      _TriviaFamilyError.loadFailed => strings.couldNotLoadFamilyMembers,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    final gameInProgress =
        _phase != _TriviaPhase.setup && _phase != _TriviaPhase.finalResults;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: const SilaGameCoachButton(),
        appBar: AppBar(title: Text(strings.trivia)),
        body: SafeArea(
          child: _phase == _TriviaPhase.setup
              ? _buildSetup()
              : Padding(padding: const EdgeInsets.all(24), child: _buildBody()),
        ),
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
    final strings = AppLocalizations.of(context)!;

    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyError != null) {
      return Center(
        child: Text(
          _familyErrorMessage(strings, _familyError!),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GameSetupView(
      icon: Icons.quiz_rounded,
      title: strings.trivia,
      description: strings.triviaSetupDescription,
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.whoIsPlaying,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(strings.chooseAtLeastTwoPlayers),
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
                strings.chooseTeams,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(strings.assignPlayersToTeams),
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
                                label: Text(strings.teamA),
                                selected: inTeamA,
                                onSelected: (_) {
                                  _assignPlayerToTeam(player, 'A');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(strings.teamB),
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
                label: Text(strings.shuffleTeams),
              ),
              if (_teamA.isNotEmpty || _teamB.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTeamCard(
                        title: strings.teamA,
                        players: _teamA,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTeamCard(
                        title: strings.teamB,
                        players: _teamB,
                      ),
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
              Text(
                strings.category,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(localizedGameCategory(strings, category)),
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
              Text(
                strings.matchPace,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Text(strings.questionsPerRound),
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
              Text(strings.timePerQuestion),
              const SizedBox(height: 9),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [20, 30, 45].map((seconds) {
                  return ChoiceChip(
                    label: Text(strings.secondsShort(seconds)),
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
            _isLoadingQuestions
                ? strings.preparingNamedGame(strings.trivia)
                : strings.startNamedGame(strings.trivia),
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
      heading: _strings.teamTurn(_startingTeamName),
      question: question,
      seconds: _secondsRemaining,
      onAnswer: _selectNormalAnswer,
    );
  }

  Widget _buildStealScreen() {
    final question = _questions[_globalQuestionIndex];

    return _buildQuestionLayout(
      heading: _strings.stealTeam(_stealingTeamName),
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
    final strings = AppLocalizations.of(context)!;

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
            strings.questionRoundProgress(
              _currentRound,
              _selectedRounds,
              _questionInRound + 1,
              _questionsPerRound,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Text(
            strings.secondsRemaining(seconds),
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
                    strings.teamScore(strings.teamA, _teamAScore),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    strings.teamScore(strings.teamB, _teamBScore),
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
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.fact_check_outlined, size: 72),

            const SizedBox(height: 20),

            Text(
              strings.questionComplete,
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
                    Text(
                      strings.teamScore(strings.teamA, _teamAScore),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      strings.teamScore(strings.teamB, _teamBScore),
                      textAlign: TextAlign.center,
                    ),
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
                      ? strings.roundResults
                      : strings.nextQuestion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSummaryScreen() {
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.flag_outlined, size: 72),

            const SizedBox(height: 20),

            Text(
              strings.roundNumberComplete(_currentRound),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            Text(
              strings.teamScore(strings.teamA, _teamAScore),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              strings.teamScore(strings.teamB, _teamBScore),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterRound,
                child: Text(
                  _currentRound == _selectedRounds
                      ? strings.seeFinalResults
                      : strings.startRound(_currentRound + 1),
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
    final strings = AppLocalizations.of(context)!;
    final isTie = _teamAScore == _teamBScore;

    final winner = _teamAScore > _teamBScore ? strings.teamA : strings.teamB;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 80),

            const SizedBox(height: 20),

            Text(
              isTie ? strings.triviaTie : strings.teamWins(winner),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            Text(
              strings.teamScore(strings.teamA, _teamAScore),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              strings.teamScore(strings.teamB, _teamBScore),
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
                      ? strings.returnToCompetition(
                          widget.playMode.localizedName(strings),
                        )
                      : strings.playAgain,
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
                child: Text(strings.backToGames),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTieBreakerScreen() {
    final question = _questions[_globalQuestionIndex];
    final strings = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.tieBreaker,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(strings.oneFinalQuestion, textAlign: TextAlign.center),

          const SizedBox(height: 18),

          Text(
            strings.secondsRemaining(10),
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
