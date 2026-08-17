class CompetitionPeriod {
  const CompetitionPeriod._();

  static String dailyKey([DateTime? value]) {
    final date = value ?? DateTime.now();

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String monthlyKey([DateTime? value]) {
    final date = value ?? DateTime.now();

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  static String weeklyKey([DateTime? value]) {
    final date = value ?? DateTime.now();

    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    // ISO weeks are based around Thursday.
    final thursday = normalized.add(
      Duration(days: 4 - normalized.weekday),
    );

    final firstThursday = DateTime(
      thursday.year,
      1,
      4,
    );

    final firstWeekThursday = firstThursday.add(
      Duration(days: 4 - firstThursday.weekday),
    );

    final weekNumber =
        1 + thursday.difference(firstWeekThursday).inDays ~/ 7;

    return '${thursday.year}-W'
        '${weekNumber.toString().padLeft(2, '0')}';
  }

  static String dailyCompetitionId([DateTime? value]) {
    return 'daily_${dailyKey(value)}';
  }

  static String weeklyCompetitionId([DateTime? value]) {
    return 'weekly_${weeklyKey(value)}';
  }

  static String monthlyCompetitionId([DateTime? value]) {
    return 'monthly_${monthlyKey(value)}';
  }
}
