import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/family_quiz_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';

enum _FamilyQuizPhase {
  setup,
  subjectHandoff,
  subjectAnswer,
  guesserHandoff,
  guess,
  answerReveal,
  roundSummary,
  voteHandoff,
  vote,
  voteReveal,
  finalResults,
}

class FamilyQuizScreen extends StatefulWidget {
  const FamilyQuizScreen({
    super.key,
    this.aiService = const FamilyQuizAiService(),
    this.developerPreview = false,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
  });

  final FamilyQuizAiService aiService;
  final bool developerPreview;
  final GamePlayMode playMode;
  final Set<String>? participantIds;

  @override
  State<FamilyQuizScreen> createState() => _FamilyQuizScreenState();
}

class _FamilyQuizScreenState extends State<FamilyQuizScreen> {
  static const List<String> _categories = [
    'Family Fun',
    'Favorites',
    'Habits',
    'Memories',
    'Most Likely To',
  ];

  static const Map<String, List<FamilyQuizQuestion>> _fallbackQuestions = {
    'Family Fun': [
      FamilyQuizQuestion(
        question: 'Which family activity would you choose for a free day?',
        options: ['Game night', 'Picnic', 'Movie marathon', 'Day trip'],
      ),
      FamilyQuizQuestion(
        question: 'Which imaginary family pet would you choose?',
        options: ['Tiny dragon', 'Talking dog', 'Flying cat', 'Friendly robot'],
      ),
      FamilyQuizQuestion(
        question: 'Which role would you choose in a family talent show?',
        options: ['Singer', 'Comedian', 'Magician', 'Host'],
      ),
      FamilyQuizQuestion(
        question: 'Which surprise would make you smile the most?',
        options: [
          'Favorite meal',
          'Mystery trip',
          'Handmade gift',
          'Extra sleep',
        ],
      ),
      FamilyQuizQuestion(
        question: 'Which family challenge would you enjoy most?',
        options: ['Bake-off', 'Treasure hunt', 'Dance contest', 'Puzzle race'],
      ),
    ],
    'Favorites': [
      FamilyQuizQuestion(
        question: 'Which snack would you choose for family movie night?',
        options: ['Popcorn', 'Pizza', 'Fruit', 'Ice cream'],
      ),
      FamilyQuizQuestion(
        question: 'Which kind of outing would you choose?',
        options: ['Beach', 'Theme park', 'Museum', 'Nature walk'],
      ),
      FamilyQuizQuestion(
        question: 'Which movie type would you choose tonight?',
        options: ['Comedy', 'Adventure', 'Animation', 'Mystery'],
      ),
      FamilyQuizQuestion(
        question: 'Which hobby would you most like to try?',
        options: ['Painting', 'Cooking', 'Photography', 'Gardening'],
      ),
      FamilyQuizQuestion(
        question: 'Which treat would you choose for dessert?',
        options: ['Cake', 'Cookies', 'Fruit', 'Ice cream'],
      ),
    ],
    'Habits': [
      FamilyQuizQuestion(
        question: 'What do you usually do first after waking up?',
        options: ['Check the time', 'Drink water', 'Stretch', 'Stay in bed'],
      ),
      FamilyQuizQuestion(
        question: 'How do you prefer to get ready for an event?',
        options: ['Very early', 'With a checklist', 'With help', 'Last minute'],
      ),
      FamilyQuizQuestion(
        question: 'Which task do you prefer to finish first?',
        options: ['Cleaning', 'Homework', 'Messages', 'Planning'],
      ),
      FamilyQuizQuestion(
        question: 'What helps you relax at the end of the day?',
        options: ['Music', 'A show', 'Reading', 'Talking'],
      ),
      FamilyQuizQuestion(
        question: 'How do you usually remember something important?',
        options: [
          'Write a note',
          'Set an alarm',
          'Tell someone',
          'Just remember',
        ],
      ),
    ],
    'Memories': [
      FamilyQuizQuestion(
        question: 'Which type of family memory would you most like to revisit?',
        options: ['A trip', 'A celebration', 'A funny moment', 'A quiet day'],
      ),
      FamilyQuizQuestion(
        question: 'Which keepsake would you save from a special day?',
        options: ['Photo', 'Ticket', 'Small gift', 'Written note'],
      ),
      FamilyQuizQuestion(
        question: 'Which family moment do you remember most easily?',
        options: ['A meal', 'A journey', 'A game', 'A celebration'],
      ),
      FamilyQuizQuestion(
        question: 'How would you preserve a favorite family memory?',
        options: ['Photo album', 'Video', 'Story', 'Memory box'],
      ),
      FamilyQuizQuestion(
        question: 'Which tradition would you most enjoy repeating?',
        options: ['Holiday meal', 'Annual trip', 'Game night', 'Family photo'],
      ),
    ],
    'Most Likely To': [
      FamilyQuizQuestion(
        question: 'Who is most likely to plan a surprise family outing?',
        options: [],
      ),
      FamilyQuizQuestion(
        question: 'Who is most likely to make everyone laugh?',
        options: [],
      ),
      FamilyQuizQuestion(
        question: 'Who is most likely to remember every birthday?',
        options: [],
      ),
      FamilyQuizQuestion(
        question: 'Who is most likely to suggest a family game night?',
        options: [],
      ),
      FamilyQuizQuestion(
        question: 'Who is most likely to help without being asked?',
        options: [],
      ),
    ],
  };

  bool _isLoadingFamily = true;
  bool _isPreparingGame = false;

  String? _familyError;

  final List<_QuizPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_QuizPlayer> _players = [];
  List<FamilyQuizQuestion> _questions = [];

  final Map<String, int> _scores = {};

  String _selectedCategory = 'Family Fun';

  int _selectedRounds = 3;
  int _questionsPerRound = 3;

  int _currentRound = 1;
  int _questionInRound = 0;
  int _globalQuestionIndex = 0;

  int _currentSubjectIndex = 0;
  int _currentGuesserIndex = 0;

  int? _subjectAnswerIndex;

  final Map<String, int> _currentGuesses = {};

  int _currentVoterIndex = 0;
  int? _selectedVoteIndex;
  List<int> _currentVotes = [];

  _FamilyQuizPhase _phase = _FamilyQuizPhase.setup;

  bool get _isVotingMode => _selectedCategory == 'Most Likely To';

  FamilyQuizQuestion get _currentQuestion => _questions[_globalQuestionIndex];

  _QuizPlayer get _currentSubject => _players[_currentSubjectIndex];

  List<_QuizPlayer> get _guessers =>
      _players.where((player) => player.id != _currentSubject.id).toList();

  _QuizPlayer get _currentGuesser => _guessers[_currentGuesserIndex];
  bool get _hasLockedParticipants => widget.participantIds != null;
  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _familyMembers.addAll(const [
        _QuizPlayer(id: '1', name: 'Amal'),
        _QuizPlayer(id: '2', name: 'Omar'),
        _QuizPlayer(id: '3', name: 'Mariam'),
        _QuizPlayer(id: '4', name: 'Zayed'),
      ]);

      _isLoadingFamily = false;
      return;
    }

    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoadingFamily = false;
          _familyError = 'You must be logged in to play.';
        });

        return;
      }

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDocument.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingFamily = false;
          _familyError = 'Join or create a family before playing Family Quiz.';
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

        return _QuizPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      final availableMembers = widget.participantIds == null
          ? members
          : members
                .where((member) => widget.participantIds!.contains(member.id))
                .toList();
      if (!mounted) {
        return;
      }

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(availableMembers);

        _selectedPlayerIds.clear();
        if (_hasLockedParticipants) {
          _selectedPlayerIds.addAll(
            availableMembers.map((member) => member.id),
          );
        }

        _isLoadingFamily = false;

        if (_hasLockedParticipants && availableMembers.length < 2) {
          _familyError =
              'This official Family Quiz match does not have enough valid family members.';
        } else {
          _familyError = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingFamily = false;
        _familyError = 'Could not load your family members.';
      });
    }
  }

  void _togglePlayer(_QuizPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  Future<void> _startGame() async {
    final selectedPlayers = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    if (selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family Quiz needs at least 2 players.')),
      );
      return;
    }

    final totalQuestions = _selectedRounds * _questionsPerRound;

    setState(() {
      _isPreparingGame = true;
    });

    try {
      final generated = await widget.aiService.generateQuestions(
        category: _selectedCategory,
        count: totalQuestions,
        familyMembers: selectedPlayers.map((player) => player.name).toList(),
      );

      if (generated.length < totalQuestions) {
        throw const FormatException('Not enough Family Quiz questions');
      }

      if (!_isVotingMode &&
          generated.any(
            (question) =>
                question.options.length != 4 ||
                question.options.toSet().length != 4,
          )) {
        throw const FormatException('Invalid Family Quiz options');
      }

      if (!mounted) {
        return;
      }

      _beginSession(
        players: selectedPlayers,
        questions: generated.take(totalQuestions).toList(),
      );
    } catch (_) {
      final fallback = List<FamilyQuizQuestion>.from(
        _fallbackQuestions[_selectedCategory]!,
      )..shuffle(Random());

      if (!mounted) {
        return;
      }

      if (fallback.isEmpty) {
        setState(() {
          _isPreparingGame = false;
        });

        return;
      }

      final repeatedQuestions = <FamilyQuizQuestion>[];

      while (repeatedQuestions.length < totalQuestions) {
        final copy = List<FamilyQuizQuestion>.from(fallback)..shuffle(Random());

        repeatedQuestions.addAll(copy);
      }

      _beginSession(
        players: selectedPlayers,
        questions: repeatedQuestions.take(totalQuestions).toList(),
      );
    }
  }

  void _beginSession({
    required List<_QuizPlayer> players,
    required List<FamilyQuizQuestion> questions,
  }) {
    _scores.clear();

    for (final player in players) {
      _scores[player.id] = 0;
    }

    setState(() {
      _players = players;
      _questions = questions;

      _currentRound = 1;
      _questionInRound = 0;
      _globalQuestionIndex = 0;

      _currentSubjectIndex = 0;
      _currentGuesserIndex = 0;

      _subjectAnswerIndex = null;
      _currentGuesses.clear();

      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = List<int>.filled(players.length, 0);

      _isPreparingGame = false;

      _phase = _isVotingMode
          ? _FamilyQuizPhase.voteHandoff
          : _FamilyQuizPhase.subjectHandoff;
    });
  }

  void _chooseSubjectAnswer(int index) {
    setState(() {
      _subjectAnswerIndex = index;
      _currentGuesserIndex = 0;
      _currentGuesses.clear();
      _phase = _FamilyQuizPhase.guesserHandoff;
    });
  }

  void _chooseGuess(int index) {
    final guesser = _currentGuesser;

    _currentGuesses[guesser.id] = index;

    final isLastGuesser = _currentGuesserIndex == _guessers.length - 1;

    if (isLastGuesser) {
      _calculateQuestionScores();

      setState(() {
        _phase = _FamilyQuizPhase.answerReveal;
      });

      return;
    }

    setState(() {
      _currentGuesserIndex++;
      _phase = _FamilyQuizPhase.guesserHandoff;
    });
  }

  void _calculateQuestionScores() {
    final answer = _subjectAnswerIndex;

    if (answer == null) {
      return;
    }

    for (final guesser in _guessers) {
      if (_currentGuesses[guesser.id] == answer) {
        _scores[guesser.id] = (_scores[guesser.id] ?? 0) + 1;
      }
    }
  }

  void _submitVote() {
    final selectedVoteIndex = _selectedVoteIndex;

    if (selectedVoteIndex == null) {
      return;
    }

    final isLastVoter = _currentVoterIndex == _players.length - 1;

    setState(() {
      _currentVotes[selectedVoteIndex]++;
      _selectedVoteIndex = null;

      if (isLastVoter) {
        _phase = _FamilyQuizPhase.voteReveal;
      } else {
        _currentVoterIndex++;
        _phase = _FamilyQuizPhase.voteHandoff;
      }
    });
  }

  void _continueAfterQuestion() {
    final isLastQuestionInRound = _questionInRound == _questionsPerRound - 1;

    if (isLastQuestionInRound) {
      setState(() {
        _phase = _FamilyQuizPhase.roundSummary;
      });

      return;
    }

    _prepareNextQuestion();
  }

  void _continueAfterVote() {
    final highestVoteCount = _currentVotes.reduce(max);

    for (int i = 0; i < _players.length; i++) {
      if (_currentVotes[i] == highestVoteCount) {
        _scores[_players[i].id] = (_scores[_players[i].id] ?? 0) + 1;
      }
    }

    final isLastQuestionInRound = _questionInRound == _questionsPerRound - 1;

    if (isLastQuestionInRound) {
      setState(() {
        _phase = _FamilyQuizPhase.roundSummary;
      });

      return;
    }

    _prepareNextQuestion();
  }

  void _prepareNextQuestion() {
    setState(() {
      _questionInRound++;
      _globalQuestionIndex++;

      _currentSubjectIndex = (_currentSubjectIndex + 1) % _players.length;

      _currentGuesserIndex = 0;

      _subjectAnswerIndex = null;
      _currentGuesses.clear();

      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = List<int>.filled(_players.length, 0);

      _phase = _isVotingMode
          ? _FamilyQuizPhase.voteHandoff
          : _FamilyQuizPhase.subjectHandoff;
    });
  }

  void _continueAfterRound() {
    final isLastRound = _currentRound == _selectedRounds;

    if (isLastRound) {
      setState(() {
        _phase = _FamilyQuizPhase.finalResults;
      });

      return;
    }

    setState(() {
      _currentRound++;
      _questionInRound = 0;
      _globalQuestionIndex++;

      _currentSubjectIndex = (_currentSubjectIndex + 1) % _players.length;

      _currentGuesserIndex = 0;

      _subjectAnswerIndex = null;
      _currentGuesses.clear();

      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = List<int>.filled(_players.length, 0);

      _phase = _isVotingMode
          ? _FamilyQuizPhase.voteHandoff
          : _FamilyQuizPhase.subjectHandoff;
    });
  }

  void _playAgain() {
    setState(() {
      _phase = _FamilyQuizPhase.setup;
      _questions = [];
      _players = [];

      _currentRound = 1;
      _questionInRound = 0;
      _globalQuestionIndex = 0;

      _currentSubjectIndex = 0;
      _currentGuesserIndex = 0;

      _subjectAnswerIndex = null;
      _currentGuesses.clear();

      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = [];
      _selectedPlayerIds
        ..clear()
        ..addAll(
          _hasLockedParticipants
              ? _familyMembers.map((player) => player.id)
              : const <String>[],
        );
      _scores.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Quiz')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _FamilyQuizPhase.setup => _buildSetup(),

      _FamilyQuizPhase.subjectHandoff => _buildHandoff(
        icon: Icons.lock_outline,
        title: 'Pass the phone to ${_currentSubject.name}',
        message:
            'Everyone else should look away while ${_currentSubject.name} chooses a private answer.',
        buttonLabel: 'I\'m ${_currentSubject.name}',
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.subjectAnswer;
          });
        },
      ),

      _FamilyQuizPhase.subjectAnswer => _buildSubjectAnswer(),

      _FamilyQuizPhase.guesserHandoff => _buildHandoff(
        icon: Icons.visibility_off_outlined,
        title: 'Pass the phone to ${_currentGuesser.name}',
        message:
            '${_currentGuesser.name} will privately guess what ${_currentSubject.name} chose.',
        buttonLabel: 'I\'m ${_currentGuesser.name}',
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.guess;
          });
        },
      ),

      _FamilyQuizPhase.guess => _buildGuess(),

      _FamilyQuizPhase.answerReveal => _buildAnswerReveal(),

      _FamilyQuizPhase.roundSummary => _buildRoundSummary(),

      _FamilyQuizPhase.voteHandoff => _buildHandoff(
        icon: Icons.how_to_vote_outlined,
        title: 'Pass the phone to ${_players[_currentVoterIndex].name}',
        message: 'Votes are private. Everyone else should look away.',
        buttonLabel: 'I\'m ${_players[_currentVoterIndex].name}',
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.vote;
          });
        },
      ),

      _FamilyQuizPhase.vote => _buildVote(),

      _FamilyQuizPhase.voteReveal => _buildVoteReveal(),

      _FamilyQuizPhase.finalResults => _buildFinalResults(),
    };
  }

  Widget _buildSetup() {
    if (_isLoadingFamily) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_familyError!, textAlign: TextAlign.center),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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

          const SizedBox(height: 18),

          ..._familyMembers.map((player) {
            final selected = _selectedPlayerIds.contains(player.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                child: CheckboxListTile(
                  value: selected,
                  onChanged: _hasLockedParticipants
                      ? null
                      : (_) => _togglePlayer(player),
                  secondary: CircleAvatar(
                    child: Text(
                      player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

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
                selected: _selectedCategory == category,
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
            'Questions per round',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [3, 5, 10].map((questionCount) {
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

          const SizedBox(height: 32),

          FilledButton(
            onPressed: _selectedPlayerIds.length >= 2 && !_isPreparingGame
                ? _startGame
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _isPreparingGame
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Preparing Game...'),
                      ],
                    )
                  : Text(_isVotingMode ? 'Start Voting' : 'Start Family Quiz'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoff({
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72),

            const SizedBox(height: 24),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAnswer() {
    return _buildChoices(
      heading: '${_currentSubject.name}, choose your real answer',
      helper: 'Everyone else will try to predict what you chose.',
      onSelected: _chooseSubjectAnswer,
    );
  }

  Widget _buildGuess() {
    return _buildChoices(
      heading: 'What did ${_currentSubject.name} choose?',
      helper: '${_currentGuesser.name}, make your private guess.',
      onSelected: _chooseGuess,
    );
  }

  Widget _buildChoices({
    required String heading,
    required String helper,
    required ValueChanged<int> onSelected,
  }) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),

        const SizedBox(height: 24),

        Text(
          _currentQuestion.question,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Text(
          heading,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 8),

        Text(helper, textAlign: TextAlign.center),

        const SizedBox(height: 24),

        for (int i = 0; i < _currentQuestion.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.tonal(
              onPressed: () => onSelected(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_currentQuestion.options[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswerReveal() {
    final answerIndex = _subjectAnswerIndex!;

    final correctGuessers = _guessers
        .where((player) => _currentGuesses[player.id] == answerIndex)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),

        const SizedBox(height: 32),

        const Icon(Icons.celebration_outlined, size: 72),

        const SizedBox(height: 20),

        Text(
          '${_currentSubject.name} chose:',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 10),

        Text(
          _currentQuestion.options[answerIndex],
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 28),

        Text(
          correctGuessers.isEmpty
              ? 'Nobody guessed correctly!'
              : '${correctGuessers.map((player) => player.name).join(', ')} guessed correctly!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),

        if (correctGuessers.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('+1 point each', textAlign: TextAlign.center),
        ],

        const SizedBox(height: 32),

        FilledButton(
          onPressed: _continueAfterQuestion,
          child: Text(
            _questionInRound == _questionsPerRound - 1
                ? 'Round Results'
                : 'Next Question',
          ),
        ),
      ],
    );
  }

  Widget _buildVote() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),

        const SizedBox(height: 24),

        Text(
          _currentQuestion.question,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Text(
          '${_players[_currentVoterIndex].name}, choose privately.',
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        for (int i = 0; i < _players.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedVoteIndex = i;
                });
              },
              icon: Icon(
                _selectedVoteIndex == i
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              label: Text(_players[i].name),
            ),
          ),

        const SizedBox(height: 12),

        FilledButton(
          onPressed: _selectedVoteIndex == null ? null : _submitVote,
          child: const Text('Submit Private Vote'),
        ),
      ],
    );
  }

  Widget _buildVoteReveal() {
    final highestVoteCount = _currentVotes.reduce(max);

    final winners = <_QuizPlayer>[
      for (int i = 0; i < _players.length; i++)
        if (_currentVotes[i] == highestVoteCount) _players[i],
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),

        const SizedBox(height: 28),

        const Icon(Icons.how_to_vote_outlined, size: 72),

        const SizedBox(height: 18),

        Text(
          winners.length == 1
              ? '${winners.first.name} received the most votes!'
              : 'It\'s a tie!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Text(_currentQuestion.question, textAlign: TextAlign.center),

        const SizedBox(height: 28),

        for (int i = 0; i < _players.length; i++)
          ListTile(
            title: Text(_players[i].name),
            trailing: Text(
              '${_currentVotes[i]} '
              '${_currentVotes[i] == 1 ? 'vote' : 'votes'}',
            ),
          ),

        const SizedBox(height: 24),

        FilledButton(
          onPressed: _continueAfterVote,
          child: Text(
            _questionInRound == _questionsPerRound - 1
                ? 'Round Results'
                : 'Next Vote',
          ),
        ),
      ],
    );
  }

  Widget _buildRoundSummary() {
    final leaderboard = [..._players];

    leaderboard.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Round $_currentRound Complete',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: leaderboard.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final player = leaderboard[index];

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(player.name),
                  trailing: Text(
                    '${_scores[player.id] ?? 0} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: _continueAfterRound,
            child: Text(
              _currentRound == _selectedRounds
                  ? 'See Final Results'
                  : 'Start Round ${_currentRound + 1}',
            ),
          ),
        ],
      ),
    );
  }

  CompetitionGameResult _buildCompetitionResult() {
    final leaderboard = List<_QuizPlayer>.from(_players)
      ..sort((a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0));

    final results = <CompetitionPlayerResult>[];

    int placement = 0;
    int? previousScore;

    for (var index = 0; index < leaderboard.length; index++) {
      final player = leaderboard[index];
      final score = _scores[player.id] ?? 0;

      if (previousScore == null || score != previousScore) {
        placement = index + 1;
      }

      results.add(
        CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: score,
          placement: placement,
        ),
      );

      previousScore = score;
    }

    return CompetitionGameResult(
      gameId: CompetitionGameIds.familyQuiz,
      gameName: 'Family Quiz',
      players: results,
    );
  }

  Widget _buildFinalResults() {
    final leaderboard = [..._players];

    leaderboard.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final highestScore = _scores[leaderboard.first.id] ?? 0;

    final winners = leaderboard
        .where((player) => (_scores[player.id] ?? 0) == highestScore)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 80),

          const SizedBox(height: 16),

          Text(
            winners.length == 1
                ? '${winners.first.name} Wins!'
                : 'It\'s a Tie!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 28),

          Expanded(
            child: ListView.separated(
              itemCount: leaderboard.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final player = leaderboard[index];

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    '${_scores[player.id] ?? 0} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

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

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Round $_currentRound of $_selectedRounds • '
          'Question ${_questionInRound + 1} of $_questionsPerRound',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 10),

        LinearProgressIndicator(
          value: (_questionInRound + 1) / _questionsPerRound,
        ),
      ],
    );
  }
}

class _QuizPlayer {
  const _QuizPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
