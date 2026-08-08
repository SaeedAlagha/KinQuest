import 'dart:math';

import 'package:flutter/material.dart';

import '../services/trivia_ai_service.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

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
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Generating questions...'),
                  ],
                )
              : const Text('Start Trivia'),
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
}
