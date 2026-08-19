import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/family_quiz_screen.dart';
import 'package:kinquest/features/games/services/family_quiz_ai_service.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  group('FamilyQuizScreen', () {
    testWidgets('requires at least two selected family members', (
      tester,
    ) async {
      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);

      final startButton = find.widgetWithText(
        FilledButton,
        'Start Family Quiz',
      );

      expect(tester.widget<FilledButton>(startButton).onPressed, isNull);
      expect(service.callCount, 0);

      await _selectPlayer(tester, 'Amal');
      expect(tester.widget<FilledButton>(startButton).onPressed, isNull);

      await _selectPlayer(tester, 'Omar');
      expect(tester.widget<FilledButton>(startButton).onPressed, isNotNull);
      expect(service.callCount, 0);
    });

    testWidgets('starts the upgraded private-answer flow and scores a match', (
      tester,
    ) async {
      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);
      await _selectPlayer(tester, 'Amal');
      await _selectPlayer(tester, 'Omar');

      await _tapText(tester, 'Start Family Quiz');

      expect(service.callCount, 1);
      expect(service.lastCategory, 'Family Fun');
      expect(service.lastCount, 9);
      expect(service.lastFamilyMembers, ['Amal', 'Omar']);

      expect(find.text('Pass the phone to Amal'), findsOneWidget);
      await _tapText(tester, "I'm Amal");
      await _tapText(tester, 'Games');

      expect(find.text('Pass the phone to Omar'), findsOneWidget);
      await _tapText(tester, "I'm Omar");
      await _tapText(tester, 'Games');

      expect(find.text('Omar guessed correctly!'), findsOneWidget);
      expect(find.text('+1 point each'), findsOneWidget);

      await _tapText(tester, 'Next Question');
      expect(find.text('Pass the phone to Omar'), findsOneWidget);
    });

    testWidgets('keeps upgraded voting private and reports the winner', (
      tester,
    ) async {
      final service = _FakeFamilyQuizAiService(_votingQuestions);
      await _pumpQuiz(tester, service);
      await _selectPlayer(tester, 'Amal');
      await _selectPlayer(tester, 'Omar');
      await _tapChoiceChip(tester, 'Most Likely To');

      await _tapText(tester, 'Start Voting');

      expect(service.callCount, 1);
      expect(service.lastCategory, 'Most Likely To');

      expect(find.text('Pass the phone to Amal'), findsOneWidget);
      await _tapText(tester, "I'm Amal");
      await _tapOutlinedChoice(tester, 'Amal');
      await _tapText(tester, 'Submit Private Vote');

      expect(find.text('Pass the phone to Omar'), findsOneWidget);
      await _tapText(tester, "I'm Omar");
      await _tapOutlinedChoice(tester, 'Amal');
      await _tapText(tester, 'Submit Private Vote');

      expect(find.text('Amal received the most votes!'), findsOneWidget);
      expect(find.text('2 votes'), findsOneWidget);

      await _tapText(tester, 'Next Vote');
      expect(find.text('Pass the phone to Amal'), findsOneWidget);
    });

    testWidgets('uses offline prompts when the AI request fails', (
      tester,
    ) async {
      final service = _FailingFamilyQuizAiService();
      await _pumpQuiz(tester, service);
      await _selectPlayer(tester, 'Amal');
      await _selectPlayer(tester, 'Omar');

      await _tapText(tester, 'Start Family Quiz');

      expect(service.callCount, 1);
      expect(find.text('Pass the phone to Amal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles unavailable Firebase without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FamilyQuizScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load your family members.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('setup remains usable on a narrow screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);
      await _selectPlayer(tester, 'Amal');
      await _selectPlayer(tester, 'Omar');

      final startButton = find.text('Start Family Quiz');
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();

      expect(startButton, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic AI failure uses Arabic offline questions and RTL', (
      tester,
    ) async {
      final service = _FailingFamilyQuizAiService();
      await _pumpQuiz(tester, service, locale: const Locale('ar'));
      await _selectPlayer(tester, 'Amal');
      await _selectPlayer(tester, 'Omar');

      await _tapText(tester, 'ابدأ اختبار العائلة');

      expect(find.text('مرر الهاتف إلى Amal'), findsOneWidget);
      await _tapText(tester, 'أنا Amal');
      expect(find.textContaining('أي'), findsWidgets);
      expect(
        tester
            .widget<Directionality>(find.byType(Directionality).first)
            .textDirection,
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

const _privateAnswerQuestions = [
  FamilyQuizQuestion(
    question: 'Which activity would you choose?',
    options: ['Games', 'Movies', 'Cooking', 'Walking'],
  ),
  FamilyQuizQuestion(
    question: 'Where would you go?',
    options: ['Beach', 'Museum', 'Park', 'Cafe'],
  ),
  FamilyQuizQuestion(
    question: 'What helps you relax?',
    options: ['Music', 'Reading', 'Talking', 'Sleeping'],
  ),
];

const _votingQuestions = [
  FamilyQuizQuestion(
    question: 'Who is most likely to plan an outing?',
    options: [],
  ),
  FamilyQuizQuestion(
    question: 'Who is most likely to make everyone laugh?',
    options: [],
  ),
  FamilyQuizQuestion(
    question: 'Who is most likely to remember birthdays?',
    options: [],
  ),
];

class _FakeFamilyQuizAiService extends FamilyQuizAiService {
  _FakeFamilyQuizAiService(this.questions);

  final List<FamilyQuizQuestion> questions;
  int callCount = 0;
  String? lastCategory;
  int? lastCount;
  List<String>? lastFamilyMembers;

  @override
  Future<List<FamilyQuizQuestion>> generateQuestions({
    required String category,
    required int count,
    required List<String> familyMembers,
    required String languageCode,
  }) async {
    callCount++;
    lastCategory = category;
    lastCount = count;
    lastFamilyMembers = List<String>.from(familyMembers);
    return List.generate(count, (index) => questions[index % questions.length]);
  }
}

class _FailingFamilyQuizAiService extends FamilyQuizAiService {
  int callCount = 0;

  @override
  Future<List<FamilyQuizQuestion>> generateQuestions({
    required String category,
    required int count,
    required List<String> familyMembers,
    required String languageCode,
  }) async {
    callCount++;
    throw Exception('AI unavailable');
  }
}

Future<void> _pumpQuiz(
  WidgetTester tester,
  FamilyQuizAiService service, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FamilyQuizScreen(aiService: service, developerPreview: true),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectPlayer(WidgetTester tester, String name) async {
  final tile = find.widgetWithText(CheckboxListTile, name);
  expect(tile, findsOneWidget);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200);
  }
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapChoiceChip(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ChoiceChip, label);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapOutlinedChoice(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(OutlinedButton, label);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
