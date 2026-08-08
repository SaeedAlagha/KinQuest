import 'dart:math';

import 'package:flutter/material.dart';

import '../services/charades_ai_service.dart';

class CharadesScreen extends StatefulWidget {
  const CharadesScreen({super.key});

  @override
  State<CharadesScreen> createState() => _CharadesScreenState();
}

class _CharadesScreenState extends State<CharadesScreen> {
  final CharadesAiService _aiService = CharadesAiService();

  final List<String> _categories = [
    'Animals',
    'Actions',
    'Movies',
    'Objects',
    'Sports',
  ];

  final Map<String, List<String>> _fallbackPrompts = {
    'Animals': ['Elephant', 'Penguin', 'Kangaroo', 'Monkey', 'Giraffe'],
    'Actions': [
      'Brushing your teeth',
      'Swimming',
      'Dancing',
      'Cooking',
      'Sleeping',
    ],
    'Movies': ['Superhero', 'Pirate', 'Robot', 'Detective', 'Princess'],
    'Objects': ['Umbrella', 'Camera', 'Backpack', 'Telephone', 'Bicycle'],
    'Sports': ['Basketball', 'Football', 'Tennis', 'Swimming', 'Boxing'],
  };

  String _selectedCategory = 'Animals';
  bool _isLoading = false;
  bool _isPlaying = false;
  int _currentIndex = 0;
  List<String> _prompts = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final generated = await _aiService.generatePrompts(
        category: _selectedCategory,
        count: 10,
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
        _prompts = fallback;
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

  void _nextPrompt() {
    if (_currentIndex < _prompts.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _isPlaying = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Charades round complete!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charades')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isPlaying ? _buildGame() : _buildSetup(),
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
              : const Text('Start Charades'),
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _nextPrompt,
          child: const Text('Next Prompt'),
        ),
      ],
    );
  }
}
