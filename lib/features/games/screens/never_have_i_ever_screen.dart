import 'dart:math';

import 'package:flutter/material.dart';

import '../services/never_have_i_ever_ai_service.dart';
import '../widgets/game_setup_widgets.dart';

class NeverHaveIEverScreen extends StatefulWidget {
  const NeverHaveIEverScreen({super.key});

  @override
  State<NeverHaveIEverScreen> createState() => _NeverHaveIEverScreenState();
}

class _NeverHaveIEverScreenState extends State<NeverHaveIEverScreen> {
  final NeverHaveIEverAiService _aiService = NeverHaveIEverAiService();

  final List<String> _categories = [
    'Family',
    'School',
    'Travel',
    'Food',
    'Funny',
  ];

  final Map<String, List<String>> _fallbackPrompts = {
    'Family': [
      'Never have I ever fallen asleep during a family movie.',
      'Never have I ever eaten someone else\'s snack.',
      'Never have I ever forgotten a family birthday.',
      'Never have I ever blamed someone else for a mess.',
      'Never have I ever laughed so hard at dinner.',
    ],
    'School': [
      'Never have I ever forgotten my homework.',
      'Never have I ever been late to class.',
      'Never have I ever doodled during a lesson.',
      'Never have I ever forgotten my lunch.',
      'Never have I ever answered a question incorrectly.',
    ],
    'Travel': [
      'Never have I ever missed a bus or train.',
      'Never have I ever gotten lost while traveling.',
      'Never have I ever slept during a road trip.',
      'Never have I ever forgotten something important at home.',
      'Never have I ever taken too many photos on a trip.',
    ],
    'Food': [
      'Never have I ever eaten dessert before dinner.',
      'Never have I ever tried a very spicy food.',
      'Never have I ever dropped food on the floor.',
      'Never have I ever eaten breakfast for dinner.',
      'Never have I ever mixed two strange foods together.',
    ],
    'Funny': [
      'Never have I ever walked into the wrong room.',
      'Never have I ever worn mismatched socks.',
      'Never have I ever laughed at the wrong moment.',
      'Never have I ever forgotten why I entered a room.',
      'Never have I ever talked to myself out loud.',
    ],
  };

  String _selectedCategory = 'Family';
  int _selectedRounds = 3;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;

  int _currentIndex = 0;
  int _iHaveCount = 0;
  int _neverCount = 0;

  List<String> _prompts = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _iHaveCount = 0;
      _neverCount = 0;
    });

    try {
      final generated = await _aiService.generatePrompts(
        category: _selectedCategory,
        count: _selectedRounds,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (!mounted) return;

      setState(() {
        _prompts = generated.map((prompt) => prompt.text).toList();
        _currentIndex = 0;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallback = List<String>.from(_fallbackPrompts[_selectedCategory]!)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _prompts = fallback.take(_selectedRounds).toList();
        _currentIndex = 0;
        _isPlaying = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach AI. Using offline prompts instead.'),
        ),
      );
    }
  }

  void _answer(bool hasDoneIt) {
    if (hasDoneIt) {
      _iHaveCount++;
    } else {
      _neverCount++;
    }

    if (_currentIndex < _prompts.length - 1) {
      setState(() {
        _currentIndex++;
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
      appBar: AppBar(title: const Text('Never Have I Ever')),
      body: _showResults || _isPlaying
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: _showResults ? _buildResults() : _buildGame(),
            )
          : _buildSetup(),
    );
  }

  Widget _buildSetup() {
    return GameSetupView(
      icon: Icons.sentiment_satisfied_alt_rounded,
      title: 'Never Have I Ever',
      description:
          'Pick a family-friendly theme and choose 1, 3, or 5 prompts for a quick round of surprising stories.',
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) {
                  final selected = category == _selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
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
        const SizedBox(height: 18),
        GameRoundSelector(
          value: _selectedRounds,
          onChanged: (rounds) {
            setState(() {
              _selectedRounds = rounds;
            });
          },
        ),
        const SizedBox(height: 22),
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
                    Text('Generating prompts...'),
                  ],
                )
              : const Text('Start Game'),
        ),
      ],
    );
  }

  Widget _buildGame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Prompt ${_currentIndex + 1} of ${_prompts.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        LinearProgressIndicator(value: (_currentIndex + 1) / _prompts.length),
        const SizedBox(height: 30),
        Expanded(
          child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _prompts[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _answer(false),
                child: const Text('Never'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _answer(true),
                child: const Text('I Have'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.celebration, size: 72),
        const SizedBox(height: 24),
        const Text(
          'Round Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        Text(
          'I Have: $_iHaveCount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          'Never: $_neverCount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
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
