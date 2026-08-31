import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../services/charades_ai_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

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

  final Map<String, List<String>> _arabicFallbackPrompts = {
    'Animals': ['فيل', 'بطريق', 'كنغر', 'قرد', 'زرافة'],
    'Actions': ['تنظيف الأسنان', 'السباحة', 'الرقص', 'الطبخ', 'النوم'],
    'Movies': ['بطل خارق', 'قرصان', 'روبوت', 'محقق', 'أميرة'],
    'Objects': ['مظلة', 'كاميرا', 'حقيبة ظهر', 'هاتف', 'دراجة'],
    'Sports': ['كرة السلة', 'كرة القدم', 'التنس', 'السباحة', 'الملاكمة'],
  };

  String _selectedCategory = 'Animals';
  int _selectedRounds = 3;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;
  int _currentIndex = 0;
  List<String> _prompts = [];

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _showResults = false;
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
      final fallbackBank = Localizations.localeOf(context).languageCode == 'ar'
          ? _arabicFallbackPrompts
          : _fallbackPrompts;
      final fallback = List<String>.from(fallbackBank[_selectedCategory]!)
        ..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _prompts = fallback.take(_selectedRounds).toList();
        _currentIndex = 0;
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

  void _nextPrompt() {
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

    return GameExitGuard(
      gameInProgress: _isPlaying,
      child: Scaffold(
        floatingActionButton: _showResults
            ? const SilaGameCoachButton(
                tone: SilaGameCoachTone.celebrating,
                resultScreen: true,
              )
            : _isPlaying
            ? const SilaGameCoachButton()
            : null,
        appBar: AppBar(title: Text(strings.charades)),
        body: _showResults
            ? Padding(padding: const EdgeInsets.all(24), child: _buildResults())
            : _isPlaying
            ? Padding(padding: const EdgeInsets.all(24), child: _buildGame())
            : _buildSetup(),
      ),
    );
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;

    return GameSetupView(
      icon: Icons.theater_comedy_rounded,
      title: strings.charades,
      description: strings.charadesSetupDescription,
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
                  final selected = category == _selectedCategory;

                  return ChoiceChip(
                    label: Text(localizedGameCategory(strings, category)),
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
              : Text(strings.startCharades),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.promptProgress(_currentIndex + 1, _prompts.length),
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
        ElevatedButton(onPressed: _nextPrompt, child: Text(strings.nextPrompt)),
      ],
    );
  }

  Widget _buildResults() {
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(Icons.celebration_rounded, size: 72),
        const SizedBox(height: 24),
        Text(
          strings.charadesRoundComplete,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          strings.roundCompleteCelebration,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        ElevatedButton(onPressed: _startGame, child: Text(strings.playAgain)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(() => _showResults = false),
          child: Text(strings.changeCategory),
        ),
      ],
    );
  }
}
