import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../services/ai_question_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';

class WouldYouRatherScreen extends StatefulWidget {
  const WouldYouRatherScreen({super.key});

  @override
  State<WouldYouRatherScreen> createState() => _WouldYouRatherScreenState();
}

enum _GamePhase { setup, playing, results }

class WouldYouRatherQuestion {
  final String optionA;
  final String optionB;

  const WouldYouRatherQuestion({required this.optionA, required this.optionB});
}

class _WouldYouRatherScreenState extends State<WouldYouRatherScreen> {
  static const Map<String, List<WouldYouRatherQuestion>> _questionBank = {
    'Family': [
      WouldYouRatherQuestion(
        optionA: 'Eat a pancake breakfast with everyone',
        optionB: 'Have a movie night with everyone',
      ),
      WouldYouRatherQuestion(
        optionA: 'Build a blanket fort',
        optionB: 'Play a board game together',
      ),
      WouldYouRatherQuestion(
        optionA: 'Tell a funny story',
        optionB: 'Sing a silly song',
      ),
      WouldYouRatherQuestion(
        optionA: 'Go on a picnic in the park',
        optionB: 'Bake cookies together',
      ),
      WouldYouRatherQuestion(
        optionA: 'Draw a family portrait',
        optionB: 'Make a paper airplane race',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have a game night with cards',
        optionB: 'Have a scavenger hunt around the house',
      ),
      WouldYouRatherQuestion(
        optionA: 'Make up a new handshake',
        optionB: 'Make up a new joke',
      ),
      WouldYouRatherQuestion(
        optionA: 'Share a happy memory',
        optionB: 'Share a dream for the future',
      ),
    ],
    'Travel': [
      WouldYouRatherQuestion(
        optionA: 'Visit a beach town',
        optionB: 'Visit a mountain town',
      ),
      WouldYouRatherQuestion(
        optionA: 'Ride a train through the countryside',
        optionB: 'Fly above the clouds on an airplane',
      ),
      WouldYouRatherQuestion(
        optionA: 'Eat a new snack in a different city',
        optionB: 'Take pictures of every new place',
      ),
      WouldYouRatherQuestion(
        optionA: 'See a sunrise on vacation',
        optionB: 'See a sunset on vacation',
      ),
      WouldYouRatherQuestion(
        optionA: 'Find a treasure map',
        optionB: 'Find a hidden playground',
      ),
      WouldYouRatherQuestion(
        optionA: 'Ride a bike on vacation',
        optionB: 'Take a boat ride on vacation',
      ),
      WouldYouRatherQuestion(
        optionA: 'Visit a zoo or aquarium',
        optionB: 'Visit a science museum',
      ),
      WouldYouRatherQuestion(
        optionA: 'Try a local dessert',
        optionB: 'Try a local drink',
      ),
    ],
    'At Home': [
      WouldYouRatherQuestion(
        optionA: 'Build a pillow fort',
        optionB: 'Make a LEGO city',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have a family cooking challenge',
        optionB: 'Have a family art challenge',
      ),
      WouldYouRatherQuestion(
        optionA: 'Read a story together',
        optionB: 'Invent a new story together',
      ),
      WouldYouRatherQuestion(
        optionA: 'Decorate cookies',
        optionB: 'Decorate cupcakes',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have a dance party',
        optionB: 'Have a quiet game night',
      ),
      WouldYouRatherQuestion(
        optionA: 'Make a treasure map',
        optionB: 'Make a friendship bracelet',
      ),
      WouldYouRatherQuestion(
        optionA: 'Play hide and seek',
        optionB: 'Play charades',
      ),
      WouldYouRatherQuestion(
        optionA: 'Plant a small garden',
        optionB: 'Paint a picture',
      ),
    ],
    'Food': [
      WouldYouRatherQuestion(
        optionA: 'Eat strawberries',
        optionB: 'Eat blueberries',
      ),
      WouldYouRatherQuestion(
        optionA: 'Make a fruit salad',
        optionB: 'Make a yogurt parfait',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have a picnic lunch',
        optionB: 'Have a backyard barbecue',
      ),
      WouldYouRatherQuestion(
        optionA: 'Try a new sandwich',
        optionB: 'Try a new smoothie',
      ),
      WouldYouRatherQuestion(
        optionA: 'Eat crunchy carrots',
        optionB: 'Eat juicy grapes',
      ),
      WouldYouRatherQuestion(
        optionA: 'Choose pizza toppings',
        optionB: 'Choose ice cream toppings',
      ),
      WouldYouRatherQuestion(
        optionA: 'Sip hot chocolate',
        optionB: 'Sip lemonade',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have breakfast for dinner',
        optionB: 'Have dessert first',
      ),
    ],
    'School': [
      WouldYouRatherQuestion(
        optionA: 'Learn about space',
        optionB: 'Learn about animals',
      ),
      WouldYouRatherQuestion(
        optionA: 'Write a story',
        optionB: 'Draw a picture',
      ),
      WouldYouRatherQuestion(
        optionA: 'Solve a puzzle',
        optionB: 'Build something',
      ),
      WouldYouRatherQuestion(
        optionA: 'Choose gym time',
        optionB: 'Choose art time',
      ),
      WouldYouRatherQuestion(
        optionA: 'Have quiet reading',
        optionB: 'Have science experiments',
      ),
      WouldYouRatherQuestion(
        optionA: 'Explore a history story',
        optionB: 'Explore a nature story',
      ),
      WouldYouRatherQuestion(
        optionA: 'Design a paper airplane',
        optionB: 'Design a bookmark',
      ),
      WouldYouRatherQuestion(
        optionA: 'Create a class cheer',
        optionB: 'Create a class mural',
      ),
    ],
  };

  static const Map<String, List<WouldYouRatherQuestion>> _arabicQuestionBank = {
    'Family': [
      WouldYouRatherQuestion(
        optionA: 'تناول فطور الفطائر مع الجميع',
        optionB: 'قضاء ليلة أفلام مع الجميع',
      ),
      WouldYouRatherQuestion(
        optionA: 'تنظيم نزهة عائلية',
        optionB: 'تنظيم ليلة ألعاب عائلية',
      ),
      WouldYouRatherQuestion(
        optionA: 'طبخ وجبة مع العائلة',
        optionB: 'تزيين المنزل مع العائلة',
      ),
      WouldYouRatherQuestion(
        optionA: 'سماع قصة عائلية قديمة',
        optionB: 'صنع ذكرى عائلية جديدة',
      ),
      WouldYouRatherQuestion(
        optionA: 'زيارة الأقارب',
        optionB: 'استضافة الأقارب في المنزل',
      ),
    ],
    'Travel': [
      WouldYouRatherQuestion(
        optionA: 'السفر إلى الجبال',
        optionB: 'السفر إلى الشاطئ',
      ),
      WouldYouRatherQuestion(optionA: 'ركوب القطار', optionB: 'ركوب الطائرة'),
      WouldYouRatherQuestion(
        optionA: 'استكشاف مدينة جديدة',
        optionB: 'استكشاف محمية طبيعية',
      ),
      WouldYouRatherQuestion(
        optionA: 'التخييم تحت النجوم',
        optionB: 'الإقامة في فندق مريح',
      ),
      WouldYouRatherQuestion(
        optionA: 'التقاط صور الرحلة',
        optionB: 'كتابة يوميات الرحلة',
      ),
    ],
    'At Home': [
      WouldYouRatherQuestion(
        optionA: 'بناء حصن من الوسائد',
        optionB: 'إعداد ركن للقراءة',
      ),
      WouldYouRatherQuestion(optionA: 'خبز كعكة', optionB: 'إعداد بيتزا'),
      WouldYouRatherQuestion(
        optionA: 'لعب لعبة جماعية',
        optionB: 'مشاهدة فيلم',
      ),
      WouldYouRatherQuestion(
        optionA: 'ترتيب الغرفة مع الموسيقى',
        optionB: 'تزيين الغرفة بالصور',
      ),
      WouldYouRatherQuestion(optionA: 'زراعة نبتة', optionB: 'صنع عمل فني'),
    ],
    'Food': [
      WouldYouRatherQuestion(optionA: 'تناول البيتزا', optionB: 'تناول البرغر'),
      WouldYouRatherQuestion(
        optionA: 'اختيار حلوى باردة',
        optionB: 'اختيار حلوى دافئة',
      ),
      WouldYouRatherQuestion(
        optionA: 'تجربة فاكهة جديدة',
        optionB: 'تجربة طبق جديد',
      ),
      WouldYouRatherQuestion(optionA: 'إعداد الفطور', optionB: 'إعداد العشاء'),
      WouldYouRatherQuestion(
        optionA: 'تناول الفطور وقت العشاء',
        optionB: 'تناول الحلوى أولًا',
      ),
    ],
    'School': [
      WouldYouRatherQuestion(
        optionA: 'التعلم عن الفضاء',
        optionB: 'التعلم عن الحيوانات',
      ),
      WouldYouRatherQuestion(optionA: 'كتابة قصة', optionB: 'رسم صورة'),
      WouldYouRatherQuestion(optionA: 'حل لغز', optionB: 'بناء شيء جديد'),
      WouldYouRatherQuestion(
        optionA: 'اختيار وقت الرياضة',
        optionB: 'اختيار وقت الفن',
      ),
      WouldYouRatherQuestion(
        optionA: 'القراءة بهدوء',
        optionB: 'إجراء تجربة علمية',
      ),
    ],
  };

  static const List<String> _categories = [
    'Family',
    'Travel',
    'At Home',
    'Food',
    'School',
  ];

  String _selectedCategory = _categories[0];
  int _selectedRounds = 5;
  _GamePhase _phase = _GamePhase.setup;
  final List<WouldYouRatherQuestion> _selectedQuestions = [];
  final List<int> _selectedChoices = [];
  int _gameSession = 0;
  int _currentRound = 0;
  int? _selectedChoiceIndex;
  final AiQuestionService _aiQuestionService = AiQuestionService();
  bool _isLoadingQuestions = false;

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final aiQuestions = await _aiQuestionService
          .generateWouldYouRatherQuestions(
            category: _selectedCategory,
            count: _selectedRounds,
            languageCode: Localizations.localeOf(context).languageCode,
          );

      final generatedQuestions = aiQuestions
          .map(
            (question) => WouldYouRatherQuestion(
              optionA: question.optionA,
              optionB: question.optionB,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _selectedQuestions
          ..clear()
          ..addAll(generatedQuestions);

        _selectedChoices.clear();
        _gameSession += 1;
        _currentRound = 0;
        _selectedChoiceIndex = null;
        _phase = _GamePhase.playing;
        _isLoadingQuestions = false;
      });
    } catch (error) {
      final bank = Localizations.localeOf(context).languageCode == 'ar'
          ? _arabicQuestionBank
          : _questionBank;
      final fallbackQuestions = List<WouldYouRatherQuestion>.from(
        bank[_selectedCategory]!,
      )..shuffle(Random());

      if (!mounted) return;

      setState(() {
        _selectedQuestions
          ..clear()
          ..addAll(fallbackQuestions.take(_selectedRounds));

        _selectedChoices.clear();
        _gameSession += 1;
        _currentRound = 0;
        _selectedChoiceIndex = null;
        _phase = _GamePhase.playing;
        _isLoadingQuestions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotReachAiOfflineQuestions,
          ),
        ),
      );
    }
  }

  void _selectAnswer(int index) {
    if (_selectedChoiceIndex == index) {
      return;
    }
    setState(() {
      _selectedChoiceIndex = index;
    });
  }

  void _nextRound() {
    if (_selectedChoiceIndex == null) {
      return;
    }
    setState(() {
      _selectedChoices.add(_selectedChoiceIndex!);
      _selectedChoiceIndex = null;
      _currentRound += 1;
      if (_currentRound >= _selectedQuestions.length) {
        _phase = _GamePhase.results;
      }
    });
  }

  void _resetToSetup() {
    setState(() {
      _phase = _GamePhase.setup;
      _selectedQuestions.clear();
      _selectedChoices.clear();
      _currentRound = 0;
      _selectedChoiceIndex = null;
    });
  }

  Future<void> _playAgain() async {
    _phase = _GamePhase.setup;

    await _startGame();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.wouldYouRather)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _phase == _GamePhase.setup
                  ? _buildSetupView(context, colors)
                  : _phase == _GamePhase.playing
                  ? _buildQuestionView(context, colors, constraints)
                  : _buildResultsView(context, colors, constraints),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSetupView(BuildContext context, ColorScheme colors) {
    final strings = AppLocalizations.of(context)!;

    return GameSetupView(
      key: const ValueKey(_GamePhase.setup),
      icon: Icons.compare_arrows_rounded,
      title: strings.wouldYouRather,
      description: strings.wouldRatherSetupDescription,
      children: [
        GameSetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.pickCategory,
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
                    selectedColor: colors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: category == _selectedCategory
                          ? colors.primary
                          : colors.onSurface,
                    ),
                    onSelected: (_) => _selectCategory(category),
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
          onPressed: _isLoadingQuestions ? null : _startGame,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _isLoadingQuestions
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(strings.generatingQuestions),
                    ],
                  )
                : Text(strings.startGame),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    ColorScheme colors,
    BoxConstraints constraints,
  ) {
    final strings = AppLocalizations.of(context)!;
    final question = _selectedQuestions[_currentRound];
    final bool isWide = constraints.maxWidth >= 560;
    final selected = _selectedChoiceIndex;
    return Column(
      key: const ValueKey(_GamePhase.playing),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  strings.roundProgress(
                    _currentRound + 1,
                    _selectedQuestions.length,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentRound + 1) / _selectedQuestions.length,
                color: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.2),
                semanticsLabel: strings.gameProgress,
                semanticsValue: strings.roundProgress(
                  _currentRound + 1,
                  _selectedQuestions.length,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, contentConstraints) {
                return SingleChildScrollView(
                  key: PageStorageKey('question-$_gameSession-$_currentRound'),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: max(0.0, contentConstraints.maxHeight - 44),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.wouldYouRatherPrompt,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: colors.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              strings.chooseMostFunAnswer,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildAnswerCard(
                                        context,
                                        question.optionA,
                                        0,
                                        selected,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildAnswerCard(
                                        context,
                                        question.optionB,
                                        1,
                                        selected,
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildAnswerCard(
                                        context,
                                        question.optionA,
                                        0,
                                        selected,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildAnswerCard(
                                        context,
                                        question.optionB,
                                        1,
                                        selected,
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selected == null
                                ? strings.tapAnswerToLock
                                : strings.youSelectedAnswer(
                                    selected == 0
                                        ? question.optionA
                                        : question.optionB,
                                  ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            key: ValueKey(_currentRound),
                            onPressed: selected == null ? null : _nextRound,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                _currentRound + 1 >= _selectedQuestions.length
                                    ? strings.seeResults
                                    : strings.nextRound,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(
    BuildContext context,
    String text,
    int index,
    int? selectedIndex,
  ) {
    final colors = Theme.of(context).colorScheme;
    final bool isSelected = selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _selectAnswer(index),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? colors.primary : colors.outline,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? colors.primary : colors.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    ColorScheme colors,
    BoxConstraints constraints,
  ) {
    final strings = AppLocalizations.of(context)!;
    final totalRounds = _selectedQuestions.length;
    return SingleChildScrollView(
      key: const ValueKey(_GamePhase.results),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: max(0.0, constraints.maxHeight - 40),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.greatJob,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              strings.completedRoundsCategory(
                totalRounds,
                localizedGameCategory(strings, _selectedCategory),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(totalRounds, (index) {
                  final answer = _selectedChoices[index];
                  final question = _selectedQuestions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answer == 0 ? question.optionA : question.optionB,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _playAgain,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(strings.playAgain),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _resetToSetup,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(strings.changeSettings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
