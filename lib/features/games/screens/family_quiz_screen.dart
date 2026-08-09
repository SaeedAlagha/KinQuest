import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/family_quiz_ai_service.dart';

enum _FamilyQuizPhase {
  setup,
  privateAnswerHandoff,
  privateAnswer,
  familyGuessHandoff,
  familyGuess,
  answerReveal,
  voteHandoff,
  vote,
  voteReveal,
  results,
}

class _VoteRoundSummary {
  const _VoteRoundSummary({required this.question, required this.winners});

  final String question;
  final List<String> winners;
}

class FamilyQuizScreen extends StatefulWidget {
  const FamilyQuizScreen({
    super.key,
    this.aiService = const FamilyQuizAiService(),
  });

  final FamilyQuizAiService aiService;

  @override
  State<FamilyQuizScreen> createState() => _FamilyQuizScreenState();
}

class _FamilyQuizScreenState extends State<FamilyQuizScreen> {
  static const int _minimumRounds = 3;
  static const int _maximumRounds = 5;
  static const int _maximumFamilyMembers = 8;

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

  final TextEditingController _memberController = TextEditingController();

  final List<String> _familyMembers = [];

  bool _isLoadingFamilyMembers = true;
  String? _familyLoadError;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isLoadingFamilyMembers = false;
          _familyLoadError = 'No user is currently signed in.';
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoadingFamilyMembers = false;
          _familyLoadError = 'You have not joined a family yet.';
        });
        return;
      }

      final familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .get();

      final memberIds = List<String>.from(
        familyDoc.data()?['members'] ?? const [],
      );

      final names = <String>[];

      for (final memberId in memberIds) {
        final memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        final name = memberDoc.data()?['name'] as String?;

        if (name != null && name.trim().isNotEmpty) {
          names.add(name.trim());
        }
      }

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(names.take(_maximumFamilyMembers));

        _isLoadingFamilyMembers = false;
        _familyLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingFamilyMembers = false;
        _familyLoadError = 'Could not load family members.';
      });
    }
  }

  final List<_VoteRoundSummary> _voteSummaries = [];

  _FamilyQuizPhase _phase = _FamilyQuizPhase.setup;
  String _selectedCategory = 'Family Fun';
  String? _memberError;
  bool _isLoading = false;
  int _selectedRounds = _minimumRounds;
  int _currentQuestionIndex = 0;
  int _matches = 0;
  int? _privateAnswerIndex;
  int? _familyGuessIndex;
  int _currentVoterIndex = 0;
  int? _selectedVoteIndex;
  List<int> _currentVotes = [];
  List<FamilyQuizQuestion> _questions = [];

  bool get _isVotingMode => _selectedCategory == 'Most Likely To';

  String get _featuredMember =>
      _familyMembers[_currentQuestionIndex % _familyMembers.length];

  FamilyQuizQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  void _addFamilyMember() {
    final name = _memberController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _memberError = 'Enter a family member name.';
      });
      return;
    }

    final alreadyAdded = _familyMembers.any(
      (member) => member.toLowerCase() == name.toLowerCase(),
    );

    if (alreadyAdded) {
      setState(() {
        _memberError = '$name is already in the game.';
      });
      return;
    }

    if (_familyMembers.length >= _maximumFamilyMembers) {
      setState(() {
        _memberError = 'Use up to $_maximumFamilyMembers family members.';
      });
      return;
    }

    setState(() {
      _familyMembers.add(name);
      _memberError = null;
    });
    _memberController.clear();
  }

  void _removeFamilyMember(String member) {
    setState(() {
      _familyMembers.remove(member);
      _memberError = null;
    });
  }

  void _changeRounds(int delta) {
    setState(() {
      _selectedRounds = (_selectedRounds + delta).clamp(
        _minimumRounds,
        _maximumRounds,
      );
    });
  }

  Future<void> _startGame() async {
    FocusScope.of(context).unfocus();

    if (_familyMembers.length < 2) {
      setState(() {
        _memberError = 'Add at least 2 family members to start.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _memberError = null;
    });

    try {
      final generated = await widget.aiService.generateQuestions(
        category: _selectedCategory,
        count: _selectedRounds,
        familyMembers: _familyMembers,
      );

      if (generated.length < _selectedRounds ||
          (!_isVotingMode &&
              generated.any(
                (question) =>
                    question.options.length != 4 ||
                    question.options.toSet().length != 4,
              ))) {
        throw const FormatException('Invalid Family Quiz response');
      }

      if (!mounted) return;

      _beginSession(generated.take(_selectedRounds).toList());
    } catch (error) {
      final fallback = List<FamilyQuizQuestion>.from(
        _fallbackQuestions[_selectedCategory]!,
      )..shuffle(Random());

      if (!mounted) return;

      _beginSession(fallback.take(_selectedRounds).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach AI. Using offline prompts instead.'),
        ),
      );
    }
  }

  void _beginSession(List<FamilyQuizQuestion> questions) {
    setState(() {
      _questions = questions;
      _isLoading = false;
      _currentQuestionIndex = 0;
      _matches = 0;
      _privateAnswerIndex = null;
      _familyGuessIndex = null;
      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = List<int>.filled(_familyMembers.length, 0);
      _voteSummaries.clear();
      _phase = _isVotingMode
          ? _FamilyQuizPhase.voteHandoff
          : _FamilyQuizPhase.privateAnswerHandoff;
    });
  }

  void _choosePrivateAnswer(int index) {
    setState(() {
      _privateAnswerIndex = index;
      _phase = _FamilyQuizPhase.familyGuessHandoff;
    });
  }

  void _chooseFamilyGuess(int index) {
    setState(() {
      _familyGuessIndex = index;
      if (_familyGuessIndex == _privateAnswerIndex) {
        _matches++;
      }
      _phase = _FamilyQuizPhase.answerReveal;
    });
  }

  void _advancePrivateRound() {
    if (_currentQuestionIndex == _questions.length - 1) {
      _awardTokens(5);

      setState(() {
        _phase = _FamilyQuizPhase.results;
      });
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _privateAnswerIndex = null;
      _familyGuessIndex = null;
      _phase = _FamilyQuizPhase.privateAnswerHandoff;
    });
  }

  void _submitVote() {
    final selectedVoteIndex = _selectedVoteIndex;
    if (selectedVoteIndex == null) return;

    final isLastVoter = _currentVoterIndex == _familyMembers.length - 1;

    setState(() {
      _currentVotes[selectedVoteIndex]++;
      _selectedVoteIndex = null;

      if (isLastVoter) {
        final highestVoteCount = _currentVotes.reduce(max);
        final winners = <String>[
          for (var index = 0; index < _familyMembers.length; index++)
            if (_currentVotes[index] == highestVoteCount) _familyMembers[index],
        ];

        _voteSummaries.add(
          _VoteRoundSummary(
            question: _currentQuestion.question,
            winners: winners,
          ),
        );
        _phase = _FamilyQuizPhase.voteReveal;
      } else {
        _currentVoterIndex++;
        _phase = _FamilyQuizPhase.voteHandoff;
      }
    });
  }

  void _advanceVotingRound() {
    if (_currentQuestionIndex == _questions.length - 1) {
      _awardTokens(5);

      setState(() {
        _phase = _FamilyQuizPhase.results;
      });
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _currentVoterIndex = 0;
      _selectedVoteIndex = null;
      _currentVotes = List<int>.filled(_familyMembers.length, 0);
      _phase = _FamilyQuizPhase.voteHandoff;
    });
  }

  void _changeSettings() {
    setState(() {
      _phase = _FamilyQuizPhase.setup;
      _isLoading = false;
      _questions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Family Quiz')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildCurrentPhase(colorScheme),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPhase(ColorScheme colorScheme) {
    return switch (_phase) {
      _FamilyQuizPhase.setup => _buildSetup(colorScheme),
      _FamilyQuizPhase.privateAnswerHandoff => _buildHandoff(
        key: const ValueKey(_FamilyQuizPhase.privateAnswerHandoff),
        icon: Icons.lock_outline,
        title: 'Pass the device to $_featuredMember',
        message:
            '$_featuredMember will choose a private answer. Everyone else should look away.',
        buttonLabel: "I'm $_featuredMember",
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.privateAnswer;
          });
        },
      ),
      _FamilyQuizPhase.privateAnswer => _buildPrivateAnswer(colorScheme),
      _FamilyQuizPhase.familyGuessHandoff => _buildHandoff(
        key: const ValueKey(_FamilyQuizPhase.familyGuessHandoff),
        icon: Icons.groups_outlined,
        title: 'Pass the device back',
        message:
            'The rest of the family can now agree on what $_featuredMember chose.',
        buttonLabel: 'Ready to Guess',
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.familyGuess;
          });
        },
      ),
      _FamilyQuizPhase.familyGuess => _buildFamilyGuess(colorScheme),
      _FamilyQuizPhase.answerReveal => _buildAnswerReveal(colorScheme),
      _FamilyQuizPhase.voteHandoff => _buildHandoff(
        key: const ValueKey(_FamilyQuizPhase.voteHandoff),
        icon: Icons.how_to_vote_outlined,
        title: 'Pass the device to ${_familyMembers[_currentVoterIndex]}',
        message:
            'Votes are private. Other family members should look away for a moment.',
        buttonLabel: "I'm ${_familyMembers[_currentVoterIndex]}",
        onPressed: () {
          setState(() {
            _phase = _FamilyQuizPhase.vote;
          });
        },
      ),
      _FamilyQuizPhase.vote => _buildVote(colorScheme),
      _FamilyQuizPhase.voteReveal => _buildVoteReveal(colorScheme),
      _FamilyQuizPhase.results => _buildResults(colorScheme),
    };
  }

  Widget _buildSetup(ColorScheme colorScheme) {
    if (_isLoadingFamilyMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_familyLoadError != null) {
      _familyLoadError = null;
    }
    return SingleChildScrollView(
      key: const ValueKey(_FamilyQuizPhase.setup),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who is playing?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add the real family members taking part in this game.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _memberController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: 24,
                  onSubmitted: (_) => _addFamilyMember(),
                  decoration: const InputDecoration(
                    labelText: 'Family member name',
                    hintText: 'Enter a name',
                    prefixIcon: Icon(Icons.person_add_alt_1_outlined),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _addFamilyMember,
                tooltip: 'Add family member',
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (_memberError != null) ...[
            const SizedBox(height: 8),
            Text(_memberError!, style: TextStyle(color: colorScheme.error)),
          ],
          if (_familyMembers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _familyMembers.map((member) {
                return InputChip(
                  label: Text(member),
                  onDeleted: () => _removeFamilyMember(member),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Choose a category',
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
          const SizedBox(height: 20),
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isVotingMode
                        ? Icons.how_to_vote_outlined
                        : Icons.lock_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isVotingMode
                          ? 'Everyone votes privately. The group result is revealed without a fake correct answer.'
                          : 'One family member answers privately. Everyone else guesses that real answer.',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rounds',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _selectedRounds == _minimumRounds
                    ? null
                    : () => _changeRounds(-1),
                tooltip: 'Decrease rounds',
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_selectedRounds rounds',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: _selectedRounds == _maximumRounds
                    ? null
                    : () => _changeRounds(1),
                tooltip: 'Increase rounds',
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _startGame,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Creating the game...'),
                      ],
                    )
                  : Text(_isVotingMode ? 'Start Voting' : 'Start Quiz'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoff({
    required Key key,
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateAnswer(ColorScheme colorScheme) {
    return _buildQuestionChoices(
      key: const ValueKey(_FamilyQuizPhase.privateAnswer),
      colorScheme: colorScheme,
      badge: 'Private answer: $_featuredMember',
      title: '$_featuredMember, ${_currentQuestion.question}',
      helper: 'Choose your real answer. The rest of the family will guess it.',
      selectedIndex: null,
      onSelected: _choosePrivateAnswer,
    );
  }

  Widget _buildFamilyGuess(ColorScheme colorScheme) {
    return _buildQuestionChoices(
      key: const ValueKey(_FamilyQuizPhase.familyGuess),
      colorScheme: colorScheme,
      badge: 'Family guess',
      title: 'What did $_featuredMember choose?',
      subtitle: _currentQuestion.question,
      helper: 'Agree on one answer before choosing.',
      selectedIndex: null,
      onSelected: _chooseFamilyGuess,
    );
  }

  Widget _buildQuestionChoices({
    required Key key,
    required ColorScheme colorScheme,
    required String badge,
    required String title,
    required String helper,
    required int? selectedIndex,
    required ValueChanged<int> onSelected,
    String? subtitle,
  }) {
    return ListView(
      key: key,
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(label: Text(badge)),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
        const SizedBox(height: 12),
        Text(
          helper,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < _currentQuestion.options.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: selectedIndex == index
                    ? colorScheme.primaryContainer
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onPressed: () => onSelected(index),
              child: Text(_currentQuestion.options[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswerReveal(ColorScheme colorScheme) {
    final matched = _privateAnswerIndex == _familyGuessIndex;
    final privateAnswer = _currentQuestion.options[_privateAnswerIndex!];
    final familyGuess = _currentQuestion.options[_familyGuessIndex!];

    return ListView(
      key: const ValueKey(_FamilyQuizPhase.answerReveal),
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),
        const SizedBox(height: 40),
        Icon(
          matched ? Icons.celebration : Icons.favorite_outline,
          size: 72,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          matched ? 'Perfect match!' : 'Different answers!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          matched
              ? 'Your family knows $_featuredMember well.'
              : 'Now you learned something new about $_featuredMember.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "$_featuredMember's answer",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  privateAnswer,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                Text(
                  'Family guess',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  familyGuess,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _advancePrivateRound,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              _currentQuestionIndex == _questions.length - 1
                  ? 'See Results'
                  : 'Next Round',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVote(ColorScheme colorScheme) {
    return ListView(
      key: const ValueKey(_FamilyQuizPhase.vote),
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            label: Text(
              'Private vote ${_currentVoterIndex + 1} of ${_familyMembers.length}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _currentQuestion.question,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          '${_familyMembers[_currentVoterIndex]}, choose one person. Your vote stays hidden until everyone finishes.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < _familyMembers.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: _selectedVoteIndex == index
                    ? colorScheme.primaryContainer
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedVoteIndex = index;
                });
              },
              icon: Icon(
                _selectedVoteIndex == index
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              label: Text(_familyMembers[index]),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _selectedVoteIndex == null ? null : _submitVote,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Submit Private Vote'),
          ),
        ),
      ],
    );
  }

  Widget _buildVoteReveal(ColorScheme colorScheme) {
    final highestVoteCount = _currentVotes.reduce(max);
    final winners = <String>[
      for (var index = 0; index < _familyMembers.length; index++)
        if (_currentVotes[index] == highestVoteCount) _familyMembers[index],
    ];

    return ListView(
      key: const ValueKey(_FamilyQuizPhase.voteReveal),
      padding: const EdgeInsets.all(24),
      children: [
        _buildProgress(),
        const SizedBox(height: 28),
        const Icon(Icons.how_to_vote, size: 64),
        const SizedBox(height: 16),
        Text(
          winners.length == 1
              ? '${winners.first} received the most votes!'
              : 'It is a tie!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _currentQuestion.question,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 28),
        for (var index = 0; index < _familyMembers.length; index++) ...[
          Row(
            children: [
              Expanded(child: Text(_familyMembers[index])),
              Text(
                '${_currentVotes[index]} ${_currentVotes[index] == 1 ? 'vote' : 'votes'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentVotes[index] / _familyMembers.length,
            color: _currentVotes[index] == highestVoteCount
                ? colorScheme.primary
                : colorScheme.secondary,
          ),
          const SizedBox(height: 18),
        ],
        FilledButton(
          onPressed: _advanceVotingRound,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              _currentQuestionIndex == _questions.length - 1
                  ? 'See Results'
                  : 'Next Vote',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _awardTokens(int amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userRef.update({
        'tokens': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Ignore Firebase errors here so the game can still finish.
    }
  }

  Widget _buildResults(ColorScheme colorScheme) {
    return ListView(
      key: const ValueKey(_FamilyQuizPhase.results),
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          _isVotingMode ? Icons.groups : Icons.emoji_events,
          size: 72,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          _isVotingMode ? 'Family voting complete!' : 'Quiz complete!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _isVotingMode
              ? 'There are no wrong answers—these are your family results.'
              : 'Your family matched $_matches of ${_questions.length} private answers.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (_isVotingMode) ...[
          const SizedBox(height: 28),
          for (var index = 0; index < _voteSummaries.length; index++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_voteSummaries[index].question),
                subtitle: Text(
                  'Top vote: ${_voteSummaries[index].winners.join(' & ')}',
                ),
              ),
            ),
        ],
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _isLoading ? null : _startGame,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: _isLoading
                ? const Text('Creating a new game...')
                : const Text('Play Again'),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _isLoading ? null : _changeSettings,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Change Settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Round ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
        ),
      ],
    );
  }
}
