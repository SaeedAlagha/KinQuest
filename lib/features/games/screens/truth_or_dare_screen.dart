import 'dart:math';

import 'package:flutter/material.dart';

import '../services/truth_or_dare_ai_service.dart';

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  final TruthOrDareAiService _aiService = TruthOrDareAiService();

  final List<String> _categories = [
    'Family',
    'Funny',
    'School',
    'Friends',
    'Mixed',
  ];

  final List<TruthOrDarePrompt> _fallbackPrompts = const [
    TruthOrDarePrompt(
      type: 'truth',
      text: 'What is the funniest thing you have done recently?',
    ),
    TruthOrDarePrompt(
      type: 'dare',
      text: 'Do your best animal impression for 10 seconds.',
    ),
    TruthOrDarePrompt(
      type: 'truth',
      text: 'What food could you eat every day?',
    ),
    TruthOrDarePrompt(
      type: 'dare',
      text: 'Dance without music for 15 seconds.',
    ),
    TruthOrDarePrompt(
      type: 'truth',
      text: 'What is one thing that always makes you laugh?',
    ),
  ];

  String _selectedCategory = 'Family';

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;

  int _currentIndex = 0;
  int _truthCount = 0;
  int _dareCount = 0;

  List<TruthOrDarePrompt> _prompts = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _truthCount = 0;
      _dareCount = 0;
      _currentIndex = 0;
    });

    try {
      final generated = await _aiService.generatePrompts(
        category: _selectedCategory,
        count: 10,
      );

      if (!mounted) return;

      setState(() {
        _prompts = generated;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallback = List<TruthOrDarePrompt>.from(_fallbackPrompts)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _prompts = fallback;
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

  void _completePrompt() {
    final prompt = _prompts[_currentIndex];

    if (prompt.type == 'truth') {
      _truthCount++;
    } else {
      _dareCount++;
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
      appBar: AppBar(title: const Text('Truth or Dare')),
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
                    Text('Generating prompts...'),
                  ],
                )
              : const Text('Start Game'),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final prompt = _prompts[_currentIndex];
    final isTruth = prompt.type == 'truth';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Prompt ${_currentIndex + 1} of ${_prompts.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: (_currentIndex + 1) / _prompts.length),
        const SizedBox(height: 30),
        Text(
          isTruth ? 'TRUTH' : 'DARE',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  prompt.text,
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
        ElevatedButton(onPressed: _completePrompt, child: const Text('Done')),
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
        const SizedBox(height: 30),
        Text(
          'Truths completed: $_truthCount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          'Dares completed: $_dareCount',
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
