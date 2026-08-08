import 'dart:math';

import 'package:flutter/material.dart';

import '../services/emoji_guess_ai_service.dart';

class EmojiGuessScreen extends StatefulWidget {
  const EmojiGuessScreen({super.key});

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

  final List<EmojiGuessPuzzle> _fallbackPuzzles = const [
    EmojiGuessPuzzle(
      emojis: '🦁👑',
      answer: 'The Lion King',
      hint: 'A famous animated movie',
    ),
    EmojiGuessPuzzle(
      emojis: '🍕🧀',
      answer: 'Cheese Pizza',
      hint: 'A popular food',
    ),
    EmojiGuessPuzzle(
      emojis: '🐼🎋',
      answer: 'Panda',
      hint: 'An animal that loves bamboo',
    ),
    EmojiGuessPuzzle(
      emojis: '🗼🇫🇷',
      answer: 'Paris',
      hint: 'A famous European city',
    ),
    EmojiGuessPuzzle(
      emojis: '🐠🔍',
      answer: 'Finding Nemo',
      hint: 'An animated ocean movie',
    ),
  ];

  String _selectedCategory = 'Movies';

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;
  bool _showAnswer = false;

  int _currentIndex = 0;
  int _score = 0;

  List<EmojiGuessPuzzle> _puzzles = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _score = 0;
      _currentIndex = 0;
      _showAnswer = false;
    });

    try {
      final generated = await _aiService.generatePuzzles(
        category: _selectedCategory,
        count: 10,
      );

      if (!mounted) return;

      setState(() {
        _puzzles = generated;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallback = List<EmojiGuessPuzzle>.from(_fallbackPuzzles)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _puzzles = fallback;
        _isPlaying = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach AI. Using offline puzzles instead.'),
        ),
      );
    }
  }

  void _answer(bool correct) {
    if (correct) {
      _score++;
    }

    if (_currentIndex < _puzzles.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
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
      appBar: AppBar(title: const Text('Emoji Guess')),
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
              ? const Text('Generating puzzles...')
              : const Text('Start Game'),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final puzzle = _puzzles[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Puzzle ${_currentIndex + 1} of ${_puzzles.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: (_currentIndex + 1) / _puzzles.length),
        const SizedBox(height: 40),
        Text(
          puzzle.emojis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 30),
        Text(
          'Hint: ${puzzle.hint}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 30),
        if (!_showAnswer)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAnswer = true;
              });
            },
            child: const Text('Show Answer'),
          ),
        if (_showAnswer) ...[
          Text(
            puzzle.answer,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _answer(true),
            child: const Text('I Got It'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _answer(false),
            child: const Text('I Missed It'),
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
          'Round Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Text(
          'Score: $_score / ${_puzzles.length}',
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
