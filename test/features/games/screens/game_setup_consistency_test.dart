import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/games/screens/charades_screen.dart';
import 'package:kinquest/features/games/screens/dont_say_it_screen.dart';
import 'package:kinquest/features/games/screens/draw_and_guess_screen.dart';
import 'package:kinquest/features/games/screens/never_have_i_ever_screen.dart';
import 'package:kinquest/features/games/screens/pass_the_bomb_screen.dart';
import 'package:kinquest/features/games/screens/quick_play_player_selection_screen.dart';
import 'package:kinquest/features/games/screens/trivia_screen.dart';
import 'package:kinquest/features/games/screens/truth_or_dare_screen.dart';
import 'package:kinquest/features/games/screens/would_you_rather_screen.dart';
import 'package:kinquest/features/games/services/dont_say_it_ai_service.dart';
import 'package:kinquest/features/games/services/draw_and_guess_ai_service.dart';
import 'package:kinquest/features/games/services/pass_the_bomb_ai_service.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  final games = <String, Widget>{
    'Would You Rather': const WouldYouRatherScreen(),
    'Charades': const CharadesScreen(),
    'Never Have I Ever': const NeverHaveIEverScreen(),
    'Truth or Dare': const TruthOrDareScreen(),
  };

  for (final game in games.entries) {
    testWidgets('${game.key} uses the shared 1, 3, 5-round setup', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: game.value,
        ),
      );
      await tester.pump();

      expect(find.text('1 round'), findsOneWidget);
      expect(find.text('3 rounds'), findsOneWidget);
      expect(find.text('5 rounds'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('classic game setup is localized and RTL in Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CharadesScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('التمثيل الصامت'), findsWidgets);
    expect(find.text('اختر فئة'), findsOneWidget);
    expect(find.text('جولة واحدة'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Trivia setup is localized in Arabic', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TriviaScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(find.text('معلومات عامة'), findsWidgets);
    expect(find.text('من سيلعب؟'), findsOneWidget);
    expect(find.text('العلوم'), findsOneWidget);
    expect(find.text('ابدأ معلومات عامة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('shared-phone AI game copy is available in Arabic', () {
    final strings = lookupAppLocalizations(const Locale('ar'));

    expect(strings.drawAndGuess, 'ارسم وخمّن');
    expect(strings.drawingTurnEachRound, contains('كل رسام'));
    expect(strings.dontSayIt, 'لا تقلها');
    expect(strings.dontSayHeading, 'لا تقل:');
    expect(strings.passTheBomb, 'مرّر القنبلة');
    expect(strings.submitAndPassPhone, 'إرسال وتمرير الهاتف');
    expect(strings.couldNotCheckAnswer, contains('تعذر التحقق'));
    expect(strings.memoryChallenge, 'تحدي الذكريات');
    expect(strings.memoryChallengeCreateError, contains('تعذر إنشاء'));
  });

  test('shared-phone AI games have complete Arabic offline content', () {
    final prompts = DrawAndGuessAiService.offlinePrompts(
      count: 5,
      languageCode: 'ar',
    );
    final cards = DontSayItAiService.offlineCards(count: 5, languageCode: 'ar');
    final categories = PassTheBombAiService.offlineCategories(
      count: 5,
      languageCode: 'ar',
    );
    final arabic = RegExp(r'[\u0600-\u06FF]');

    expect(prompts, hasLength(5));
    expect(prompts.every((prompt) => arabic.hasMatch(prompt.text)), isTrue);
    expect(cards, hasLength(5));
    expect(
      cards.every(
        (card) =>
            arabic.hasMatch(card.word) &&
            card.forbiddenWords.every(arabic.hasMatch),
      ),
      isTrue,
    );
    expect(categories, hasLength(5));
    expect(categories.every(arabic.hasMatch), isTrue);
  });

  final previewAiGames = <String, Widget>{
    'ارسم وخمّن': const DrawAndGuessScreen(developerPreview: true),
    'لا تقلها': const DontSayItScreen(developerPreview: true),
    'مرّر القنبلة': const PassTheBombScreen(developerPreview: true),
  };

  for (final game in previewAiGames.entries) {
    testWidgets('${game.key} preview opens in Arabic without Firebase', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: game.value,
        ),
      );
      await tester.pump();

      expect(find.text(game.key), findsOneWidget);
      expect(find.text('من سيلعب؟'), findsOneWidget);

      final startLabel = game.key == 'مرّر القنبلة'
          ? 'ابدأ مرّر القنبلة'
          : 'متابعة';
      final startButton = find.text(startLabel);
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.text('الجولة 1 من 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Quick Play player selection is Arabic and RTL', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: QuickPlayPlayerSelectionScreen(developerPreview: true),
      ),
    );
    await tester.pump();

    expect(find.text('اختر اللاعبين'), findsOneWidget);
    expect(find.text('من سيلعب؟'), findsOneWidget);
    expect(find.text('تم اختيار 4 لاعبين'), findsOneWidget);
    expect(find.text('اختر اللعبة'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });
}
