import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/family_quiz_screen.dart';
import 'package:kinquest/features/games/services/family_quiz_ai_service.dart';

void main() {
  group('FamilyQuizScreen', () {
    testWidgets('validates the player list before starting', (tester) async {
      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);

      await _tapText(tester, 'Start Quiz');

      expect(
        find.text('Add at least 2 family members to start.'),
        findsOneWidget,
      );
      expect(service.callCount, 0);

      await _addMember(tester, 'Alex');
      await _addMember(tester, 'Alex');

      expect(find.text('Alex is already in the game.'), findsOneWidget);
      expect(service.callCount, 0);
    });

    testWidgets('plays the private-answer flow and calculates real matches', (
      tester,
    ) async {
      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);
      await _addMember(tester, 'Alex');
      await _addMember(tester, 'Sam');

      await _tapText(tester, 'Start Quiz');

      expect(service.callCount, 1);
      expect(service.lastCategory, 'Family Fun');
      expect(service.lastCount, 3);
      expect(service.lastFamilyMembers, ['Alex', 'Sam']);

      await _playPrivateAnswerRound(
        tester,
        member: 'Alex',
        privateAnswer: 'Games',
        familyGuess: 'Games',
        expectedReveal: 'Perfect match!',
        nextButton: 'Next Round',
      );
      await _playPrivateAnswerRound(
        tester,
        member: 'Sam',
        privateAnswer: 'Beach',
        familyGuess: 'Museum',
        expectedReveal: 'Different answers!',
        nextButton: 'Next Round',
      );
      await _playPrivateAnswerRound(
        tester,
        member: 'Alex',
        privateAnswer: 'Music',
        familyGuess: 'Music',
        expectedReveal: 'Perfect match!',
        nextButton: 'See Results',
      );

      expect(find.text('Quiz complete!'), findsOneWidget);
      expect(
        find.text('Your family matched 2 of 3 private answers.'),
        findsOneWidget,
      );

      await _tapText(tester, 'Play Again');

      expect(service.callCount, 2);
      expect(find.text('Pass the device to Alex'), findsOneWidget);
    });

    testWidgets('keeps votes private and reports winners and ties', (
      tester,
    ) async {
      final service = _FakeFamilyQuizAiService(_votingQuestions);
      await _pumpQuiz(tester, service);
      await _addMember(tester, 'Alex');
      await _addMember(tester, 'Sam');
      await _tapChoiceChip(tester, 'Most Likely To');

      await _tapText(tester, 'Start Voting');

      expect(service.callCount, 1);
      expect(service.lastCategory, 'Most Likely To');

      await _playVotingRound(
        tester,
        alexVote: 'Alex',
        samVote: 'Alex',
        expectedReveal: 'Alex received the most votes!',
        nextButton: 'Next Vote',
      );
      await _playVotingRound(
        tester,
        alexVote: 'Alex',
        samVote: 'Sam',
        expectedReveal: 'It is a tie!',
        nextButton: 'Next Vote',
      );
      await _playVotingRound(
        tester,
        alexVote: 'Sam',
        samVote: 'Sam',
        expectedReveal: 'Sam received the most votes!',
        nextButton: 'See Results',
      );

      expect(find.text('Family voting complete!'), findsOneWidget);
      expect(find.text('Top vote: Alex'), findsOneWidget);
      expect(find.text('Top vote: Alex & Sam'), findsOneWidget);
      expect(find.text('Top vote: Sam'), findsOneWidget);

      await _tapText(tester, 'Change Settings');

      expect(find.text('Who is playing?'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Alex'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Sam'), findsOneWidget);
    });

    testWidgets('uses offline prompts when the AI request fails', (
      tester,
    ) async {
      final service = _FailingFamilyQuizAiService();
      await _pumpQuiz(tester, service);
      await _addMember(tester, 'Alex');
      await _addMember(tester, 'Sam');

      await _tapText(tester, 'Start Quiz');

      expect(service.callCount, 1);
      expect(
        find.text('Could not reach AI. Using offline prompts instead.'),
        findsOneWidget,
      );
      expect(find.text('Pass the device to Alex'), findsOneWidget);
    });

    testWidgets('setup remains usable on a narrow screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = _FakeFamilyQuizAiService(_privateAnswerQuestions);
      await _pumpQuiz(tester, service);
      await _addMember(tester, 'Alex');
      await _addMember(tester, 'Sam');

      final startButton = find.text('Start Quiz');
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();

      expect(startButton, findsOneWidget);
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
  }) async {
    callCount++;
    lastCategory = category;
    lastCount = count;
    lastFamilyMembers = List<String>.from(familyMembers);
    return questions;
  }
}

class _FailingFamilyQuizAiService extends FamilyQuizAiService {
  int callCount = 0;

  @override
  Future<List<FamilyQuizQuestion>> generateQuestions({
    required String category,
    required int count,
    required List<String> familyMembers,
  }) async {
    callCount++;
    throw Exception('AI unavailable');
  }
}

Future<void> _pumpQuiz(WidgetTester tester, FamilyQuizAiService service) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: FamilyQuizScreen(aiService: service),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _addMember(WidgetTester tester, String name) async {
  final field = find.byType(TextField);
  await tester.ensureVisible(field);
  await tester.enterText(field, name);
  await tester.tap(find.byTooltip('Add family member'));
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

Future<void> _playPrivateAnswerRound(
  WidgetTester tester, {
  required String member,
  required String privateAnswer,
  required String familyGuess,
  required String expectedReveal,
  required String nextButton,
}) async {
  expect(find.text('Pass the device to $member'), findsOneWidget);
  await _tapText(tester, "I'm $member");
  await _tapOutlinedChoice(tester, privateAnswer);
  await _tapText(tester, 'Ready to Guess');
  await _tapOutlinedChoice(tester, familyGuess);

  expect(find.text(expectedReveal), findsOneWidget);
  await _tapText(tester, nextButton);
}

Future<void> _playVotingRound(
  WidgetTester tester, {
  required String alexVote,
  required String samVote,
  required String expectedReveal,
  required String nextButton,
}) async {
  expect(find.text('Pass the device to Alex'), findsOneWidget);
  await _tapText(tester, "I'm Alex");
  await _tapOutlinedChoice(tester, alexVote);
  await _tapText(tester, 'Submit Private Vote');

  expect(find.text('Pass the device to Sam'), findsOneWidget);
  await _tapText(tester, "I'm Sam");
  await _tapOutlinedChoice(tester, samVote);
  await _tapText(tester, 'Submit Private Vote');

  expect(find.text(expectedReveal), findsOneWidget);
  await _tapText(tester, nextButton);
}
