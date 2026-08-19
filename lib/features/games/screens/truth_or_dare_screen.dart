import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../services/truth_or_dare_ai_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';

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

  final List<TruthOrDarePrompt> _arabicFallbackPrompts = const [
    TruthOrDarePrompt(type: 'truth', text: 'ما أطرف شيء فعلته مؤخرًا؟'),
    TruthOrDarePrompt(type: 'dare', text: 'قلّد حيوانك المفضل لمدة 10 ثوانٍ.'),
    TruthOrDarePrompt(
      type: 'truth',
      text: 'ما الطعام الذي يمكنك تناوله كل يوم؟',
    ),
    TruthOrDarePrompt(type: 'dare', text: 'ارقص من دون موسيقى لمدة 15 ثانية.'),
    TruthOrDarePrompt(type: 'truth', text: 'ما الشيء الذي يجعلك تضحك دائمًا؟'),
  ];

  String _selectedCategory = 'Family';
  int _selectedRounds = 3;

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
        count: _selectedRounds,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (!mounted) return;

      setState(() {
        _prompts = generated;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (error) {
      final fallbackSource =
          Localizations.localeOf(context).languageCode == 'ar'
          ? _arabicFallbackPrompts
          : _fallbackPrompts;
      final fallback = List<TruthOrDarePrompt>.from(fallbackSource)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _prompts = fallback.take(_selectedRounds).toList();
        _isPlaying = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotReachAiOfflinePrompts,
          ),
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
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.truthOrDare)),
      body: _showResults || _isPlaying
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: _showResults ? _buildResults() : _buildGame(),
            )
          : _buildSetup(),
    );
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;

    return GameSetupView(
      icon: Icons.casino_rounded,
      title: strings.truthOrDare,
      description: strings.truthDareSetupDescription,
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.chooseCategory,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
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
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(strings.generatingPrompts),
                  ],
                )
              : Text(strings.startGame),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final strings = AppLocalizations.of(context)!;
    final prompt = _prompts[_currentIndex];
    final isTruth = prompt.type == 'truth';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.promptProgress(_currentIndex + 1, _prompts.length),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: (_currentIndex + 1) / _prompts.length),
        const SizedBox(height: 30),
        Text(
          isTruth ? strings.truth : strings.dare,
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
        ElevatedButton(onPressed: _completePrompt, child: Text(strings.done)),
      ],
    );
  }

  Widget _buildResults() {
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.celebration, size: 72),
        const SizedBox(height: 24),
        Text(
          strings.roundCompleteCelebration,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Text(
          strings.truthsCompleted(_truthCount),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          strings.daresCompleted(_dareCount),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const Spacer(),
        ElevatedButton(onPressed: _startGame, child: Text(strings.playAgain)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _showResults = false;
              _isPlaying = false;
            });
          },
          child: Text(strings.changeCategory),
        ),
      ],
    );
  }
}
