enum CompetitionType {
  daily,
  weekly,
  monthly,
}

extension CompetitionTypeX on CompetitionType {
  String get firestoreValue {
    switch (this) {
      case CompetitionType.daily:
        return 'daily';
      case CompetitionType.weekly:
        return 'weekly';
      case CompetitionType.monthly:
        return 'monthly';
    }
  }

  String get displayName {
    switch (this) {
      case CompetitionType.daily:
        return 'Daily Challenge';
      case CompetitionType.weekly:
        return 'Weekly Championship';
      case CompetitionType.monthly:
        return 'Monthly Cup';
    }
  }
}