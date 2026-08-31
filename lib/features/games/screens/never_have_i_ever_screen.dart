import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../services/never_have_i_ever_ai_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

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

  final Map<String, List<String>> _arabicFallbackPrompts = {
    'Family': [
      'لم أنم من قبل أثناء مشاهدة فيلم عائلي.',
      'لم آكل من قبل وجبة خفيفة تخص شخصًا آخر.',
      'لم أنسَ من قبل عيد ميلاد أحد أفراد العائلة.',
      'لم ألقِ اللوم من قبل على غيري بسبب فوضى.',
      'لم أضحك من قبل كثيرًا أثناء العشاء.',
    ],
    'School': [
      'لم أنسَ من قبل واجبي المدرسي.',
      'لم أتأخر من قبل عن الحصة.',
      'لم أرسم من قبل أثناء الدرس.',
      'لم أنسَ من قبل وجبة الغداء.',
      'لم أجب من قبل إجابة خاطئة عن سؤال.',
    ],
    'Travel': [
      'لم تفُتني من قبل حافلة أو قطار.',
      'لم أضل الطريق من قبل أثناء السفر.',
      'لم أنم من قبل خلال رحلة بالسيارة.',
      'لم أنسَ من قبل شيئًا مهمًا في المنزل.',
      'لم ألتقط من قبل صورًا كثيرة جدًا في رحلة.',
    ],
    'Food': [
      'لم آكل من قبل الحلوى قبل العشاء.',
      'لم أجرب من قبل طعامًا حارًا جدًا.',
      'لم أسقط من قبل الطعام على الأرض.',
      'لم أتناول من قبل الفطور وقت العشاء.',
      'لم أمزج من قبل نوعين غريبين من الطعام.',
    ],
    'Funny': [
      'لم أدخل من قبل الغرفة الخطأ.',
      'لم أرتدِ من قبل جوربين غير متطابقين.',
      'لم أضحك من قبل في الوقت الخطأ.',
      'لم أنسَ من قبل لماذا دخلت الغرفة.',
      'لم أتحدث من قبل مع نفسي بصوت مرتفع.',
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
        appBar: AppBar(title: Text(strings.neverHaveIEver)),
        body: _showResults || _isPlaying
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: _showResults ? _buildResults() : _buildGame(),
              )
            : _buildSetup(),
      ),
    );
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;

    return GameSetupView(
      icon: Icons.sentiment_satisfied_alt_rounded,
      title: strings.neverHaveIEver,
      description: strings.neverSetupDescription,
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
              : Text(strings.startGame),
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
                child: Text(strings.never),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _answer(true),
                child: Text(strings.iHave),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 32),
        Text(
          strings.iHaveCount(_iHaveCount),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          strings.neverCount(_neverCount),
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
