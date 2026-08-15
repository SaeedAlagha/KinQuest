// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sila';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageReminders => 'Manage reminders and alerts';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get passwordAccountSecurity => 'Password and account security';

  @override
  String get allowSilaReminders => 'Allow Sila reminders';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get dailyChallengeReminder => 'Remind me about the daily family challenge';

  @override
  String get familyMissions => 'Family Missions';

  @override
  String get familyMissionsReminder => 'Remind me about family missions';

  @override
  String get competitions => 'Competitions';

  @override
  String get competitionReminder => 'Weekly Championship and Monthly Cup reminders';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyDescription => 'Your family content is associated with your signed-in account and family.';

  @override
  String get accountEmail => 'Account Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get sendPasswordReset => 'Send a password reset email';

  @override
  String get passwordResetSent => 'Password reset email sent.';

  @override
  String get noEmailAvailable => 'No email address is available for this account.';

  @override
  String get couldNotSendReset => 'Could not send the password reset email.';

  @override
  String get couldNotLoadNotifications => 'Could not load notification preferences.';

  @override
  String get couldNotSaveNotifications => 'Could not save notification preferences.';
}
