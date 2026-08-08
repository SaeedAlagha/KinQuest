import 'dart:math';

import 'package:flutter/material.dart';

import '../services/family_quiz_ai_service.dart';

class FamilyQuizScreen extends StatefulWidget {
  const FamilyQuizScreen({super.key});

  @override
  State<FamilyQuizScreen> createState() => _FamilyQuizScreenState();
}

class _FamilyQuizScreenState extends State<FamilyQuizScreen> {
  final FamilyQuizAiService _aiService = FamilyQuizAiService();

  final List<String> _categories = [
    'Family Fun',
    'Favorites',
    'Habits',
    'Memories',
    'Most Likely To',
  ];

  final List<FamilyQuizQuestion> _fallbackQuestions = const [
    FamilyQuizQuestion(
      question: 'Which planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Venus', 'Jupiter'],
      correctIndex: 1,
    ),
    FamilyQuizQuestion(
      question: 'How many days are in a week?',
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    FamilyQuizQuestion(
      question: 'Which animal is known as the king of the jungle?',
      options: ['Tiger', 'Elephant', 'Lion', 'Bear'],
      correctIndex: 2,
    ),
    FamilyQuizQuestion(
      question: 'What is the largest ocean on Earth?',
      options: ['Atlantic', 'Indian', 'Pacific', 'Arctic'],
      correctIndex: 2,
    ),
    FamilyQuizQuestion(
      question: 'Which season comes after spring?',
      options: ['Winter', 'Summer', 'Autumn', 'Monsoon'],
      correctIndex: 1,
    ),
  ];

  String _selectedCategory = 'Family Fun';
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;
  bool _answered = false;

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;

  List<FamilyQuizQuestion> _questions = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _score = 0;
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
    });

    try {
      final generated = await _aiService.generateQuestions(
        category: _selectedCategory,
        count: 10,
        familyMembers: ['Mohammed', 'Saeed', 'Ahmed', 'Sara'],
      );

      if (!mounted) return;

      setState(() {
        _questions = generated;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallback = List<FamilyQuizQuestion>.from(_fallbackQuestions)
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
    if (_answered) return;

    final question = _questions[_currentIndex];

    setState(() {
      _selectedAnswer = index;
      _answered = true;

      if (index == question.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
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
      appBar: AppBar(title: const Text('Family Quiz')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Choose a category',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _isLoading ? null : _startGame,
          child: _isLoading
              ? const Text('Generating questions...')
              : const Text('Start Quiz'),
        ),
      ],
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
        Text(
          question.question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ...List.generate(question.options.length, (index) {
          final isCorrect = index == question.correctIndex;
          final isSelected = index == _selectedAnswer;

          String label = question.options[index];

          if (_answered && isCorrect) {
            label = '✓ $label';
          } else if (_answered && isSelected && !isCorrect) {
            label = '✗ $label';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _answered ? null : () => _selectAnswer(index),
              child: Text(label),
            ),
          );
        }),
        const Spacer(),
        if (_answered)
          ElevatedButton(
            onPressed: _nextQuestion,
            child: Text(
              _currentIndex == _questions.length - 1
                  ? 'See Results'
                  : 'Next Question',
            ),
          ),
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
          'Quiz Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Text(
          'Score: $_score / ${_questions.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
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
}
