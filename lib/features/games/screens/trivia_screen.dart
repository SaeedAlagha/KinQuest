import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/trivia_ai_service.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  final TriviaAiService _aiService = TriviaAiService();
  bool _isLoadingFamily = true;
String? _familyError;

final List<_TriviaPlayer> _familyMembers = [];
final Set<String> _selectedPlayerIds = {};

final List<_TriviaPlayer> _teamA = [];
final List<_TriviaPlayer> _teamB = [];

int _selectedRounds = 3;
int _questionsPerRound = 5;
int _secondsPerQuestion = 30;

  final List<String> _categories = [
    'Science',
    'Geography',
    'History',
    'Sports',
    'General Knowledge',
  ];

  final List<TriviaQuestion> _fallbackQuestions = const [
    TriviaQuestion(
      question: 'What planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Venus', 'Jupiter'],
      correctIndex: 1,
    ),
    TriviaQuestion(
      question: 'How many continents are there?',
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    TriviaQuestion(
      question: 'What is the largest ocean on Earth?',
      options: [
        'Atlantic Ocean',
        'Indian Ocean',
        'Pacific Ocean',
        'Arctic Ocean',
      ],
      correctIndex: 2,
    ),
    TriviaQuestion(
      question: 'How many sides does a triangle have?',
      options: ['3', '4', '5', '6'],
      correctIndex: 0,
    ),
    TriviaQuestion(
      question: 'Which animal is known as the king of the jungle?',
      options: ['Tiger', 'Lion', 'Elephant', 'Bear'],
      correctIndex: 1,
    ),
  ];

  String _selectedCategory = 'Science';

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;

  List<TriviaQuestion> _questions = [];

  @override
void initState() {
  super.initState();
  _loadFamilyMembers();
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
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    if (!mounted) return;

    setState(() {
      _familyMembers
        ..clear()
        ..addAll(members);

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

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _score = 0;
      _currentIndex = 0;
      _selectedAnswer = null;
    });

    try {
      final generated = await _aiService.generateQuestions(
        category: _selectedCategory,
        count: 10,
      );

      if (!mounted) return;

      setState(() {
        _questions = generated;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallback = List<TriviaQuestion>.from(_fallbackQuestions)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _questions = fallback;
        _isPlaying = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach AI. Using offline questions instead.'),
        ),
      );
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = index;

      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _isPlaying = false;
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _showResults
            ? _buildResults()
            : _isPlaying
            ? _buildGame()
            : _buildSetup(),
      ),
    );
  }

Widget _buildSetup() {
  if (_isLoadingFamily) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (_familyError != null) {
    return Center(
      child: Text(
        _familyError!,
        textAlign: TextAlign.center,
      ),
    );
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Who is playing?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose at least 2 players.',
        ),
        const SizedBox(height: 16),

        ..._familyMembers.map((player) {
          final selected =
              _selectedPlayerIds.contains(player.id);

          return CheckboxListTile(
            value: selected,
            onChanged: (_) => _togglePlayer(player),
            title: Text(player.name),
          );
        }),

        const SizedBox(height: 24),

const SizedBox(height: 24),

Text(
  'Choose teams',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
),

const SizedBox(height: 8),

const Text(
  'Assign every selected player to Team A or Team B.',
),

const SizedBox(height: 16),

..._familyMembers
    .where(
      (player) => _selectedPlayerIds.contains(player.id),
    )
    .map((player) {
  final inTeamA = _teamA.any(
    (member) => member.id == player.id,
  );

  final inTeamB = _teamB.any(
    (member) => member.id == player.id,
  );

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
                _assignPlayerToTeam(
                  player,
                  'A',
                );
              },
            ),

            const SizedBox(width: 8),

            ChoiceChip(
              label: const Text('Team B'),
              selected: inTeamB,
              onSelected: (_) {
                _assignPlayerToTeam(
                  player,
                  'B',
                );
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
      onPressed: _selectedPlayerIds.length >= 2
          ? _shuffleTeams
          : null,
      icon: const Icon(Icons.shuffle),
      label: const Text('Shuffle Teams'),
    ),

    const SizedBox(height: 20),

    if (_teamA.isNotEmpty || _teamB.isNotEmpty) ...[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTeamCard(
              title: 'Team A',
              players: _teamA,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTeamCard(
              title: 'Team B',
              players: _teamB,
            ),
          ),
        ],
      ),

      const SizedBox(height: 28),
    ],        

        Text(
          'Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

        Text(
          'Rounds',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          children: [3, 5, 10].map((rounds) {
            return ChoiceChip(
              label: Text('$rounds'),
              selected: _selectedRounds == rounds,
              onSelected: (_) {
                setState(() {
                  _selectedRounds = rounds;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        Text(
          'Questions per round',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          children: [3, 5, 10].map((count) {
            return ChoiceChip(
              label: Text('$count'),
              selected: _questionsPerRound == count,
              onSelected: (_) {
                setState(() {
                  _questionsPerRound = count;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        Text(
          'Time per question',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
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

        const SizedBox(height: 32),

        FilledButton(
          onPressed: _teamA.isNotEmpty &&
                  _teamB.isNotEmpty &&
                  (_teamA.length + _teamB.length ==
                      _selectedPlayerIds.length) &&
                  !_isLoading
              ? _startGame
              : null,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Start Trivia'),
        ),
      ],
    ),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...players.map(
            (player) => Text(player.name),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGame() {
    final question = _questions[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_currentIndex + 1} of ${_questions.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length),
        const SizedBox(height: 30),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? () => _selectAnswer(index)
                  : null,
              child: Text(question.options[index]),
            ),
          );
        }),
        if (_selectedAnswer != null) ...[
          const SizedBox(height: 12),
          Text(
            _selectedAnswer == question.correctIndex
                ? 'Correct!'
                : 'Incorrect. Correct answer: ${question.options[question.correctIndex]}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _nextQuestion,
            child: Text(
              _currentIndex == _questions.length - 1
                  ? 'See Results'
                  : 'Next Question',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.emoji_events, size: 72),
        const SizedBox(height: 24),
        const Text(
          'Trivia Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          'Score: $_score / ${_questions.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        ElevatedButton(onPressed: _startGame, child: const Text('Play Again')),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _showResults = false;
              _isPlaying = false;
            });
          },
          child: const Text('Change Category'),
        ),
      ],
    );
  }
  void _assignPlayerToTeam(
  _TriviaPlayer player,
  String team,
) {
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

void _shuffleTeams() {
  final selectedPlayers = _familyMembers
      .where(
        (player) => _selectedPlayerIds.contains(player.id),
      )
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
}

class _TriviaPlayer {
  const _TriviaPlayer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
