import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/competitions/models/game_play_mode.dart';
import 'package:kinquest/features/competitions/utils/competition_period.dart';
import 'package:kinquest/l10n/app_localizations_ar.dart';
import 'package:kinquest/l10n/app_localizations_en.dart';

void main() {
  group('competition periods', () {
    test('builds stable daily and monthly keys', () {
      final date = DateTime(2026, 8, 9);

      expect(CompetitionPeriod.dailyKey(date), '2026-08-09');
      expect(CompetitionPeriod.dailyCompetitionId(date), 'daily_2026-08-09');
      expect(CompetitionPeriod.monthlyKey(date), '2026-08');
      expect(CompetitionPeriod.monthlyCompetitionId(date), 'monthly_2026-08');
    });

    test('uses the ISO week-year across calendar boundaries', () {
      expect(CompetitionPeriod.weeklyKey(DateTime(2027, 1, 1)), '2026-W53');
      expect(
        CompetitionPeriod.weeklyCompetitionId(DateTime(2027, 1, 4)),
        'weekly_2027-W01',
      );
    });
  });

  test('Quick Play remains outside every ranked competition mode', () {
    expect(GamePlayMode.quickPlay.isOfficial, isFalse);
    expect(GamePlayMode.dailyChallenge.isOfficial, isTrue);
    expect(GamePlayMode.weeklyChampionship.isOfficial, isTrue);
    expect(GamePlayMode.monthlyCup.isOfficial, isTrue);
  });

  test('competition mode and result labels follow the active locale', () {
    final english = AppLocalizationsEn();
    final arabic = AppLocalizationsAr();

    expect(
      GamePlayMode.weeklyChampionship.localizedName(english),
      'Weekly Championship',
    );
    expect(
      GamePlayMode.weeklyChampionship.localizedName(arabic),
      'البطولة الأسبوعية',
    );
    expect(
      arabic.officialResultsTitle(
        GamePlayMode.monthlyCup.localizedName(arabic),
      ),
      'نتائج الكأس الشهري',
    );
  });
}
