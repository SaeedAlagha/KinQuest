import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/services/caption_battle_ai_service.dart';

void main() {
  group('CaptionBattleAiService offline modes', () {
    test('storytelling includes five distinct story prompts', () {
      final modes = CaptionBattleAiService.offlineModes(
        count: 5,
        promptStyle: 'Storytelling',
        random: Random(7),
      );

      expect(modes, hasLength(5));
      expect(modes.toSet(), hasLength(5));
      expect(modes, contains('What Happened Next?'));
      expect(modes, contains('Plot Twist'));
    });

    test('surprise mode draws distinct prompts from every style', () {
      final modes = CaptionBattleAiService.offlineModes(
        count: 5,
        random: Random(11),
      );

      expect(modes, hasLength(5));
      expect(modes.toSet(), hasLength(5));
      expect(modes, isNot(contains('Funny Caption')));
    });

    test('prompt copy explains the selected challenge', () {
      expect(
        CaptionBattleAiService.instructionForMode('What Happened Next?'),
        contains('next moment'),
      );
      expect(
        CaptionBattleAiService.hintForMode('What Happened Next?'),
        startsWith('And then'),
      );
    });
  });
}
