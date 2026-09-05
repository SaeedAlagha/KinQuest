import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/utils/offline_quiz_bank.dart';

void main() {
  test('offline quiz bank supplies every requested validated question', () {
    final questions = OfflineQuizBank.questions(
      category: 'Science',
      count: 40,
      languageCode: 'en',
      random: Random(7),
    );

    expect(questions, hasLength(40));
    for (final question in questions) {
      expect(question.question.trim(), isNotEmpty);
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(question.correctIndex, inInclusiveRange(0, 3));
    }
  });

  test('offline quiz bank serves Arabic and mixed-category variety', () {
    final questions = OfflineQuizBank.questions(
      category: 'Mixed',
      count: 30,
      languageCode: 'ar-AE',
      random: Random(11),
    );

    expect(questions, hasLength(30));
    expect(
      questions.every(
        (question) => RegExp(r'[\u0600-\u06FF]').hasMatch(question.question),
      ),
      isTrue,
    );
    expect(questions.map((question) => question.question).toSet().length, 30);
  });
}
