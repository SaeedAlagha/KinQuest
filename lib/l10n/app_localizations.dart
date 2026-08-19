import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sila'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how Sila looks across the app'**
  String get appearanceDescription;

  /// No description provided for @selectAppearance.
  ///
  /// In en, this message translates to:
  /// **'Choose your Sila theme'**
  String get selectAppearance;

  /// No description provided for @silaLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Sila Light'**
  String get silaLightTheme;

  /// No description provided for @silaLightThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Bright, calm, and familiar'**
  String get silaLightThemeDescription;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @darkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A comfortable palette for evenings'**
  String get darkThemeDescription;

  /// No description provided for @uaeFamilyYearTheme.
  ///
  /// In en, this message translates to:
  /// **'UAE Family Year 2026'**
  String get uaeFamilyYearTheme;

  /// No description provided for @uaeFamilyYearThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Warm family colors inspired by the UAE'**
  String get uaeFamilyYearThemeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage reminders and alerts'**
  String get manageReminders;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @passwordAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password and account security'**
  String get passwordAccountSecurity;

  /// No description provided for @allowSilaReminders.
  ///
  /// In en, this message translates to:
  /// **'Allow Sila reminders'**
  String get allowSilaReminders;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @dailyChallengeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me about the daily family challenge'**
  String get dailyChallengeReminder;

  /// No description provided for @familyMissions.
  ///
  /// In en, this message translates to:
  /// **'Family Missions'**
  String get familyMissions;

  /// No description provided for @familyMissionsReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me about family missions'**
  String get familyMissionsReminder;

  /// No description provided for @competitions.
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get competitions;

  /// No description provided for @competitionReminder.
  ///
  /// In en, this message translates to:
  /// **'Weekly Championship and Monthly Cup reminders'**
  String get competitionReminder;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your family content is associated with your signed-in account and family.'**
  String get privacyDescription;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account Email'**
  String get accountEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sendPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Send a password reset email'**
  String get sendPasswordReset;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get passwordResetSent;

  /// No description provided for @noEmailAvailable.
  ///
  /// In en, this message translates to:
  /// **'No email address is available for this account.'**
  String get noEmailAvailable;

  /// No description provided for @couldNotSendReset.
  ///
  /// In en, this message translates to:
  /// **'Could not send the password reset email.'**
  String get couldNotSendReset;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notification preferences.'**
  String get couldNotLoadNotifications;

  /// No description provided for @couldNotSaveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not save notification preferences.'**
  String get couldNotSaveNotifications;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get navMemories;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @navMissions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get navMissions;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @developerFamilyPreview.
  ///
  /// In en, this message translates to:
  /// **'Developer Family preview • Demo data only'**
  String get developerFamilyPreview;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @noUserSignedIn.
  ///
  /// In en, this message translates to:
  /// **'No user is currently signed in.'**
  String get noUserSignedIn;

  /// No description provided for @silaMember.
  ///
  /// In en, this message translates to:
  /// **'Sila Member'**
  String get silaMember;

  /// No description provided for @noFamilyJoined.
  ///
  /// In en, this message translates to:
  /// **'No family joined'**
  String get noFamilyJoined;

  /// No description provided for @yourFamily.
  ///
  /// In en, this message translates to:
  /// **'Your Family'**
  String get yourFamily;

  /// No description provided for @developerPreviewMemoryReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Developer preview is read-only. No memory was added.'**
  String get developerPreviewMemoryReadOnly;

  /// No description provided for @todaysDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Daily Challenge'**
  String get todaysDailyChallenge;

  /// No description provided for @dailyChallengeHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s family challenge and earn bonus tokens.'**
  String get dailyChallengeHomeDescription;

  /// No description provided for @growingInUnity.
  ///
  /// In en, this message translates to:
  /// **'GROWING IN UNITY'**
  String get growingInUnity;

  /// No description provided for @smallMomentsStrongerBonds.
  ///
  /// In en, this message translates to:
  /// **'Small moments, stronger bonds'**
  String get smallMomentsStrongerBonds;

  /// No description provided for @homeBondDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a memory or play together—simple ways to stay close every day.'**
  String get homeBondDescription;

  /// No description provided for @addMemory.
  ///
  /// In en, this message translates to:
  /// **'Add a Memory'**
  String get addMemory;

  /// No description provided for @addMemoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Save a photo, video, or story from today.'**
  String get addMemoryDescription;

  /// No description provided for @challengeFamily.
  ///
  /// In en, this message translates to:
  /// **'Challenge the Family'**
  String get challengeFamily;

  /// No description provided for @challengeFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a friendly match and share a laugh.'**
  String get challengeFamilyDescription;

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeName(String name);

  /// No description provided for @silaFamilySpace.
  ///
  /// In en, this message translates to:
  /// **'SILA FAMILY SPACE • صِلَة'**
  String get silaFamilySpace;

  /// No description provided for @rootsBondsGrowth.
  ///
  /// In en, this message translates to:
  /// **'ROOTS • BONDS • GROWTH'**
  String get rootsBondsGrowth;

  /// No description provided for @familyMembersConnected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No family members connected yet.} =1{1 family member connected through stories, play, and moments together.} other{{count} family members connected through stories, play, and moments together.}}'**
  String familyMembersConnected(int count);

  /// No description provided for @familyOverview.
  ///
  /// In en, this message translates to:
  /// **'Family Overview'**
  String get familyOverview;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembers;

  /// No description provided for @familyTokens.
  ///
  /// In en, this message translates to:
  /// **'Family tokens'**
  String get familyTokens;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @gamesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'FAMILY YEAR • BONDS THROUGH PLAY'**
  String get gamesEyebrow;

  /// No description provided for @gamesHeading.
  ///
  /// In en, this message translates to:
  /// **'Find your next family favorite'**
  String get gamesHeading;

  /// No description provided for @gamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a quick laugh, a thoughtful question, or a challenge that brings every generation closer.'**
  String get gamesDescription;

  /// No description provided for @familyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Family Quiz'**
  String get familyQuiz;

  /// No description provided for @familyQuizDescription.
  ///
  /// In en, this message translates to:
  /// **'Share real answers and discover how well your family knows one another.'**
  String get familyQuizDescription;

  /// No description provided for @connectedPlay.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED PLAY'**
  String get connectedPlay;

  /// No description provided for @trivia.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get trivia;

  /// No description provided for @triviaDescription.
  ///
  /// In en, this message translates to:
  /// **'Challenge your family with questions and compete for the highest score.'**
  String get triviaDescription;

  /// No description provided for @knowledge.
  ///
  /// In en, this message translates to:
  /// **'KNOWLEDGE'**
  String get knowledge;

  /// No description provided for @emojiGuess.
  ///
  /// In en, this message translates to:
  /// **'Emoji Guess'**
  String get emojiGuess;

  /// No description provided for @emojiGuessDescription.
  ///
  /// In en, this message translates to:
  /// **'Decode emoji clues and compete to get the highest score.'**
  String get emojiGuessDescription;

  /// No description provided for @guessingGame.
  ///
  /// In en, this message translates to:
  /// **'GUESSING GAME'**
  String get guessingGame;

  /// No description provided for @partyGames.
  ///
  /// In en, this message translates to:
  /// **'Party Games'**
  String get partyGames;

  /// No description provided for @partyGamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Quick family games for laughs and fun.'**
  String get partyGamesDescription;

  /// No description provided for @fourGamesInside.
  ///
  /// In en, this message translates to:
  /// **'4 GAMES INSIDE'**
  String get fourGamesInside;

  /// No description provided for @familyImpostor.
  ///
  /// In en, this message translates to:
  /// **'Family Impostor'**
  String get familyImpostor;

  /// No description provided for @familyImpostorDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the hidden impostor through clues, discussion, and family voting.'**
  String get familyImpostorDescription;

  /// No description provided for @socialDeduction.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL DEDUCTION'**
  String get socialDeduction;

  /// No description provided for @secretMission.
  ///
  /// In en, this message translates to:
  /// **'Secret Mission'**
  String get secretMission;

  /// No description provided for @secretMissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete a hidden mission without your family figuring out what you are doing.'**
  String get secretMissionDescription;

  /// No description provided for @secretChallenge.
  ///
  /// In en, this message translates to:
  /// **'SECRET CHALLENGE'**
  String get secretChallenge;

  /// No description provided for @captionBattle.
  ///
  /// In en, this message translates to:
  /// **'Caption Battle'**
  String get captionBattle;

  /// No description provided for @captionBattleDescription.
  ///
  /// In en, this message translates to:
  /// **'Caption real family photos, vote anonymously, and crown the funniest family member.'**
  String get captionBattleDescription;

  /// No description provided for @photoParty.
  ///
  /// In en, this message translates to:
  /// **'PHOTO PARTY'**
  String get photoParty;

  /// No description provided for @passTheBomb.
  ///
  /// In en, this message translates to:
  /// **'Pass the Bomb'**
  String get passTheBomb;

  /// No description provided for @passTheBombDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer quickly, pass the phone, and avoid being caught when the hidden timer explodes.'**
  String get passTheBombDescription;

  /// No description provided for @fastFamilyFun.
  ///
  /// In en, this message translates to:
  /// **'FAST FAMILY FUN'**
  String get fastFamilyFun;

  /// No description provided for @drawAndGuess.
  ///
  /// In en, this message translates to:
  /// **'Draw & Guess'**
  String get drawAndGuess;

  /// No description provided for @drawAndGuessDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw AI-generated prompts while your family guesses aloud.'**
  String get drawAndGuessDescription;

  /// No description provided for @creativePlay.
  ///
  /// In en, this message translates to:
  /// **'CREATIVE PLAY'**
  String get creativePlay;

  /// No description provided for @dontSayIt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Say It'**
  String get dontSayIt;

  /// No description provided for @dontSayItDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the secret word without saying any of the forbidden words.'**
  String get dontSayItDescription;

  /// No description provided for @wordChallenge.
  ///
  /// In en, this message translates to:
  /// **'WORD CHALLENGE'**
  String get wordChallenge;

  /// No description provided for @openGame.
  ///
  /// In en, this message translates to:
  /// **'Open game'**
  String get openGame;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @wouldYouRather.
  ///
  /// In en, this message translates to:
  /// **'Would You Rather'**
  String get wouldYouRather;

  /// No description provided for @wouldYouRatherDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose between two playful options.'**
  String get wouldYouRatherDescription;

  /// No description provided for @charades.
  ///
  /// In en, this message translates to:
  /// **'Charades'**
  String get charades;

  /// No description provided for @charadesDescription.
  ///
  /// In en, this message translates to:
  /// **'Act out creative prompts for the whole family.'**
  String get charadesDescription;

  /// No description provided for @neverHaveIEver.
  ///
  /// In en, this message translates to:
  /// **'Never Have I Ever'**
  String get neverHaveIEver;

  /// No description provided for @neverHaveIEverDescription.
  ///
  /// In en, this message translates to:
  /// **'Share family-friendly moments and surprises.'**
  String get neverHaveIEverDescription;

  /// No description provided for @truthOrDare.
  ///
  /// In en, this message translates to:
  /// **'Truth or Dare'**
  String get truthOrDare;

  /// No description provided for @truthOrDareDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a friendly truth or a fun challenge.'**
  String get truthOrDareDescription;

  /// No description provided for @partyGamesHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick games. Big laughs.'**
  String get partyGamesHeading;

  /// No description provided for @partyGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a game and pass the device around—no setup required.'**
  String get partyGamesSubtitle;

  /// No description provided for @gameFutureUpdate.
  ///
  /// In en, this message translates to:
  /// **'This game will be implemented in a future update.'**
  String get gameFutureUpdate;

  /// No description provided for @playTogether.
  ///
  /// In en, this message translates to:
  /// **'Play Together'**
  String get playTogether;

  /// No description provided for @playTogetherDescription.
  ///
  /// In en, this message translates to:
  /// **'Gather around, choose how you want to play, then pick a game.'**
  String get playTogetherDescription;

  /// No description provided for @quickPlay.
  ///
  /// In en, this message translates to:
  /// **'Quick Play'**
  String get quickPlay;

  /// No description provided for @quickPlayDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose any game and play together on one phone. No Tokens or official ranking.'**
  String get quickPlayDescription;

  /// No description provided for @quickPlayReward.
  ///
  /// In en, this message translates to:
  /// **'Just for fun • No Tokens'**
  String get quickPlayReward;

  /// No description provided for @dailyChallengeCompetitionDescription.
  ///
  /// In en, this message translates to:
  /// **'Compete in today\'s selected game. The winner earns Tokens.'**
  String get dailyChallengeCompetitionDescription;

  /// No description provided for @dailyChallengeCompetitionReward.
  ///
  /// In en, this message translates to:
  /// **'Winner Tokens'**
  String get dailyChallengeCompetitionReward;

  /// No description provided for @weeklyChampionship.
  ///
  /// In en, this message translates to:
  /// **'Weekly Championship'**
  String get weeklyChampionship;

  /// No description provided for @weeklyChampionshipDescription.
  ///
  /// In en, this message translates to:
  /// **'Compete across several game rounds and become this week\'s Family Champion.'**
  String get weeklyChampionshipDescription;

  /// No description provided for @weeklyChampionshipReward.
  ///
  /// In en, this message translates to:
  /// **'Family Wish'**
  String get weeklyChampionshipReward;

  /// No description provided for @monthlyCup.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cup'**
  String get monthlyCup;

  /// No description provided for @monthlyCupDescription.
  ///
  /// In en, this message translates to:
  /// **'The family\'s biggest monthly competition. Win a trophy and bonus Tokens.'**
  String get monthlyCupDescription;

  /// No description provided for @monthlyCupReward.
  ///
  /// In en, this message translates to:
  /// **'Trophy and Bonus Tokens'**
  String get monthlyCupReward;

  /// No description provided for @rewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward: {reward}'**
  String rewardLabel(String reward);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @familyTrophyCabinet.
  ///
  /// In en, this message translates to:
  /// **'Family Trophy Cabinet'**
  String get familyTrophyCabinet;

  /// No description provided for @familyTrophyCabinetDescription.
  ///
  /// In en, this message translates to:
  /// **'Previous weekly and monthly champions will appear here.'**
  String get familyTrophyCabinetDescription;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @leaderboardSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your family leaderboard.'**
  String get leaderboardSignIn;

  /// No description provided for @leaderboardJoinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family to view the leaderboard.'**
  String get leaderboardJoinFamily;

  /// No description provided for @leaderboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the family leaderboard.'**
  String get leaderboardLoadError;

  /// No description provided for @leaderboardNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No family members found.'**
  String get leaderboardNoMembers;

  /// No description provided for @familyLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Family Leaderboard'**
  String get familyLeaderboard;

  /// No description provided for @familyMember.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMember;

  /// No description provided for @tokenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 token} other{{count} tokens}}'**
  String tokenCount(num count);

  /// No description provided for @developerFamilyLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Developer Family Leaderboard'**
  String get developerFamilyLeaderboard;

  /// No description provided for @competitionFutureUpdate.
  ///
  /// In en, this message translates to:
  /// **'Competition logic will be implemented in a future update.'**
  String get competitionFutureUpdate;

  /// No description provided for @familyQuizDay.
  ///
  /// In en, this message translates to:
  /// **'Family Quiz Day'**
  String get familyQuizDay;

  /// No description provided for @familyQuizDayDescription.
  ///
  /// In en, this message translates to:
  /// **'See how well your family knows one another in today\'s Family Quiz.'**
  String get familyQuizDayDescription;

  /// No description provided for @memoryChallengeDay.
  ///
  /// In en, this message translates to:
  /// **'Memory Challenge Day'**
  String get memoryChallengeDay;

  /// No description provided for @memoryChallengeDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Look back at your family moments and test how well you remember them.'**
  String get memoryChallengeDayDescription;

  /// No description provided for @familyMissionDay.
  ///
  /// In en, this message translates to:
  /// **'Family Mission Day'**
  String get familyMissionDay;

  /// No description provided for @familyMissionDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete one meaningful activity together from Family Missions.'**
  String get familyMissionDayDescription;

  /// No description provided for @partyGameDay.
  ///
  /// In en, this message translates to:
  /// **'Party Game Day'**
  String get partyGameDay;

  /// No description provided for @partyGameDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a quick family game and share a few laughs together.'**
  String get partyGameDayDescription;

  /// No description provided for @dailyChallengeSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to use Daily Challenge.'**
  String get dailyChallengeSignInRequired;

  /// No description provided for @dailyChallengeFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before playing Daily Challenge.'**
  String get dailyChallengeFamilyRequired;

  /// No description provided for @dailyChallengeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load today\'s challenge. Please try again.'**
  String get dailyChallengeLoadError;

  /// No description provided for @dailyChallengeCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge complete! You earned 10 tokens.'**
  String get dailyChallengeCompleteMessage;

  /// No description provided for @dailyChallengeAlreadyClaimed.
  ///
  /// In en, this message translates to:
  /// **'You already claimed today\'s Daily Challenge.'**
  String get dailyChallengeAlreadyClaimed;

  /// No description provided for @dailyChallengeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the Daily Challenge. Please try again.'**
  String get dailyChallengeSaveError;

  /// No description provided for @todaysFamilyChallenge.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S FAMILY CHALLENGE'**
  String get todaysFamilyChallenge;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily reward'**
  String get dailyReward;

  /// No description provided for @dailyRewardDescription.
  ///
  /// In en, this message translates to:
  /// **'+10 tokens and daily streak progress'**
  String get dailyRewardDescription;

  /// No description provided for @dailyChallengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed today\'s challenge. Come back tomorrow for a new one!'**
  String get dailyChallengeCompleted;

  /// No description provided for @playTodaysChallenge.
  ///
  /// In en, this message translates to:
  /// **'Play Today\'s Challenge'**
  String get playTodaysChallenge;

  /// No description provided for @savingCompletion.
  ///
  /// In en, this message translates to:
  /// **'Saving completion...'**
  String get savingCompletion;

  /// No description provided for @iCompletedIt.
  ///
  /// In en, this message translates to:
  /// **'I Completed It'**
  String get iCompletedIt;

  /// No description provided for @openChallengeBeforeClaiming.
  ///
  /// In en, this message translates to:
  /// **'Open today\'s challenge before claiming the reward.'**
  String get openChallengeBeforeClaiming;

  /// No description provided for @welcomePrivateFamilySpace.
  ///
  /// In en, this message translates to:
  /// **'A private family space for shared stories, playful challenges, and the moments that keep everyone connected.'**
  String get welcomePrivateFamilySpace;

  /// No description provided for @uaeYearOfFamily2026.
  ///
  /// In en, this message translates to:
  /// **'UAE YEAR OF FAMILY 2026'**
  String get uaeYearOfFamily2026;

  /// No description provided for @everyBondHelpsFamilyGrow.
  ///
  /// In en, this message translates to:
  /// **'Every bond helps a family grow'**
  String get everyBondHelpsFamilyGrow;

  /// No description provided for @silaEverydayMoments.
  ///
  /// In en, this message translates to:
  /// **'Sila turns everyday moments into stronger roots, closer bonds, and shared growth.'**
  String get silaEverydayMoments;

  /// No description provided for @familyMomentsStayPrivate.
  ///
  /// In en, this message translates to:
  /// **'Your family moments stay with your family.'**
  String get familyMomentsStayPrivate;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @welcomeBackToSila.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Sila'**
  String get welcomeBackToSila;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Reconnect with your family circle and continue where you left off.'**
  String get loginDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailAddressHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @passwordRecoveryComing.
  ///
  /// In en, this message translates to:
  /// **'Password recovery will be added with Firebase.'**
  String get passwordRecoveryComing;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging In...'**
  String get loggingIn;

  /// No description provided for @enterDeveloperFamily.
  ///
  /// In en, this message translates to:
  /// **'Enter Developer Family'**
  String get enterDeveloperFamily;

  /// No description provided for @debugPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Debug preview only • Uses read-only demo data'**
  String get debugPreviewDescription;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @incorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get incorrectEmailOrPassword;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get pleaseEnterValidEmail;

  /// No description provided for @tooManyLoginAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyLoginAttempts;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get noInternetConnection;

  /// No description provided for @couldNotLogIn.
  ///
  /// In en, this message translates to:
  /// **'Could not log in. Please try again.'**
  String get couldNotLogIn;

  /// No description provided for @joinSila.
  ///
  /// In en, this message translates to:
  /// **'Join Sila'**
  String get joinSila;

  /// No description provided for @signupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your account and bring your family circle closer.'**
  String get signupDescription;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateOfBirthHint;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'8+ characters, uppercase, lowercase, and number'**
  String get passwordRequirements;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get acceptTerms;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating Account...'**
  String get creatingAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required.'**
  String get dateOfBirthRequired;

  /// No description provided for @selectValidDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select a valid date of birth.'**
  String get selectValidDateOfBirth;

  /// No description provided for @dateOfBirthFuture.
  ///
  /// In en, this message translates to:
  /// **'Date of birth cannot be in the future.'**
  String get dateOfBirthFuture;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Service and Privacy Policy.'**
  String get acceptTermsRequired;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak.'**
  String get weakPassword;

  /// No description provided for @couldNotCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Please try again.'**
  String get couldNotCreateAccount;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @familySetup.
  ///
  /// In en, this message translates to:
  /// **'Family Setup'**
  String get familySetup;

  /// No description provided for @connectWithFamily.
  ///
  /// In en, this message translates to:
  /// **'Connect with your family'**
  String get connectWithFamily;

  /// No description provided for @createOrJoinFamily.
  ///
  /// In en, this message translates to:
  /// **'Create a new family group or join an existing one.'**
  String get createOrJoinFamily;

  /// No description provided for @createFamily.
  ///
  /// In en, this message translates to:
  /// **'Create a Family'**
  String get createFamily;

  /// No description provided for @joinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join a Family'**
  String get joinFamily;

  /// No description provided for @createFamilyGroup.
  ///
  /// In en, this message translates to:
  /// **'Create your family group'**
  String get createFamilyGroup;

  /// No description provided for @createFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Give your family a name and invite relatives to join.'**
  String get createFamilyDescription;

  /// No description provided for @createFamilyLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a family.'**
  String get createFamilyLoginRequired;

  /// No description provided for @familyCreated.
  ///
  /// In en, this message translates to:
  /// **'Family created successfully.'**
  String get familyCreated;

  /// No description provided for @couldNotCreateFamily.
  ///
  /// In en, this message translates to:
  /// **'Could not create the family. Please try again.'**
  String get couldNotCreateFamily;

  /// No description provided for @familyImageComing.
  ///
  /// In en, this message translates to:
  /// **'Family image upload will be added later.'**
  String get familyImageComing;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alagha Family'**
  String get familyNameHint;

  /// No description provided for @familyDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Family description (optional)'**
  String get familyDescriptionOptional;

  /// No description provided for @familyDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'A short message about your family'**
  String get familyDescriptionHint;

  /// No description provided for @creatingFamily.
  ///
  /// In en, this message translates to:
  /// **'Creating Family...'**
  String get creatingFamily;

  /// No description provided for @yourInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your invitation code'**
  String get yourInvitationCode;

  /// No description provided for @shareInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with relatives so they can join your family.'**
  String get shareInvitationCode;

  /// No description provided for @copyingComing.
  ///
  /// In en, this message translates to:
  /// **'Copying will be connected next.'**
  String get copyingComing;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue to Home'**
  String get continueToHome;

  /// No description provided for @joinYourFamily.
  ///
  /// In en, this message translates to:
  /// **'Join your family'**
  String get joinYourFamily;

  /// No description provided for @joinFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-character invitation code shared by your family.'**
  String get joinFamilyDescription;

  /// No description provided for @joinFamilyLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to join a family.'**
  String get joinFamilyLoginRequired;

  /// No description provided for @invitationCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invitation code not found.'**
  String get invitationCodeNotFound;

  /// No description provided for @couldNotJoinFamily.
  ///
  /// In en, this message translates to:
  /// **'Could not join the family. Please try again.'**
  String get couldNotJoinFamily;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get invitationCode;

  /// No description provided for @invitationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'A7K9Q2'**
  String get invitationCodeHint;

  /// No description provided for @joiningFamily.
  ///
  /// In en, this message translates to:
  /// **'Joining Family...'**
  String get joiningFamily;

  /// No description provided for @validationFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get validationFullNameRequired;

  /// No description provided for @validationNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must contain at least 2 characters.'**
  String get validationNameMinLength;

  /// No description provided for @validationNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Name cannot contain more than 40 characters.'**
  String get validationNameMaxLength;

  /// No description provided for @validationNameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters.'**
  String get validationNameLettersOnly;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'Email address cannot contain spaces.'**
  String get validationEmailNoSpaces;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 8 characters.'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter.'**
  String get validationPasswordUppercase;

  /// No description provided for @validationPasswordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a lowercase letter.'**
  String get validationPasswordLowercase;

  /// No description provided for @validationPasswordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number.'**
  String get validationPasswordNumber;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationFamilyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Family name is required.'**
  String get validationFamilyNameRequired;

  /// No description provided for @validationFamilyNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Family name must contain at least 2 characters.'**
  String get validationFamilyNameMinLength;

  /// No description provided for @validationFamilyNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Family name cannot contain more than 40 characters.'**
  String get validationFamilyNameMaxLength;

  /// No description provided for @validationFamilyNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Family name contains invalid characters.'**
  String get validationFamilyNameInvalid;

  /// No description provided for @validationInvitationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Invitation code is required.'**
  String get validationInvitationCodeRequired;

  /// No description provided for @validationInvitationCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Invitation code must contain exactly 6 characters.'**
  String get validationInvitationCodeLength;

  /// No description provided for @validationInvitationCodeCharacters.
  ///
  /// In en, this message translates to:
  /// **'Invitation code can only contain letters and numbers.'**
  String get validationInvitationCodeCharacters;

  /// No description provided for @memoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memoriesTitle;

  /// No description provided for @memoryTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoryTitleGeneric;

  /// No description provided for @memoriesFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family to view memories.'**
  String get memoriesFamilyRequired;

  /// No description provided for @memoriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load memories.'**
  String get memoriesLoadError;

  /// No description provided for @noMemoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get noMemoriesYet;

  /// No description provided for @memoriesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Save photos, videos, and stories from your family moments.'**
  String get memoriesEmptyDescription;

  /// No description provided for @addFirstMemory.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Memory'**
  String get addFirstMemory;

  /// No description provided for @developerMemoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Family memories'**
  String get developerMemoriesTitle;

  /// No description provided for @developerMemoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Sample moments for reviewing the experience. They are not stored in Firebase.'**
  String get developerMemoriesDescription;

  /// No description provided for @developerMemoriesReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Developer preview is read-only. No data was changed.'**
  String get developerMemoriesReadOnly;

  /// No description provided for @previewPicnicTitle.
  ///
  /// In en, this message translates to:
  /// **'Family picnic at Mushrif Park'**
  String get previewPicnicTitle;

  /// No description provided for @previewPicnicDescription.
  ///
  /// In en, this message translates to:
  /// **'A sunny afternoon full of games, stories, and laughter.'**
  String get previewPicnicDescription;

  /// No description provided for @previewPicnicDetails.
  ///
  /// In en, this message translates to:
  /// **'02/08/2026 • Dubai'**
  String get previewPicnicDetails;

  /// No description provided for @previewLunchTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday lunch together'**
  String get previewLunchTitle;

  /// No description provided for @previewLunchDescription.
  ///
  /// In en, this message translates to:
  /// **'Grandma shared her favorite family recipe with everyone.'**
  String get previewLunchDescription;

  /// No description provided for @previewLunchDetails.
  ///
  /// In en, this message translates to:
  /// **'31/07/2026 • Home'**
  String get previewLunchDetails;

  /// No description provided for @previewSunsetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunset walk'**
  String get previewSunsetTitle;

  /// No description provided for @previewSunsetDescription.
  ///
  /// In en, this message translates to:
  /// **'We watched the sunset and planned our next family day.'**
  String get previewSunsetDescription;

  /// No description provided for @previewSunsetDetails.
  ///
  /// In en, this message translates to:
  /// **'25/07/2026 • Abu Dhabi Corniche'**
  String get previewSunsetDetails;

  /// No description provided for @addMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Memory'**
  String get addMemoryTitle;

  /// No description provided for @captureFamilyMoment.
  ///
  /// In en, this message translates to:
  /// **'Capture a family moment'**
  String get captureFamilyMoment;

  /// No description provided for @addMemoryScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a photo and save a moment your family can revisit together.'**
  String get addMemoryScreenDescription;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That photo is still too large. Please choose another photo.'**
  String get photoTooLarge;

  /// No description provided for @memoryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Memory date is required.'**
  String get memoryDateRequired;

  /// No description provided for @selectValidMemoryDate.
  ///
  /// In en, this message translates to:
  /// **'Select a valid memory date.'**
  String get selectValidMemoryDate;

  /// No description provided for @saveMemorySignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to save a memory.'**
  String get saveMemorySignInRequired;

  /// No description provided for @addMemoryFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before adding memories.'**
  String get addMemoryFamilyRequired;

  /// No description provided for @memorySaved.
  ///
  /// In en, this message translates to:
  /// **'Memory saved successfully.'**
  String get memorySaved;

  /// No description provided for @couldNotSaveMemoryTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save this memory. Please try again.'**
  String get couldNotSaveMemoryTryAgain;

  /// No description provided for @couldNotSaveMemory.
  ///
  /// In en, this message translates to:
  /// **'Could not save the memory: {error}'**
  String couldNotSaveMemory(String error);

  /// No description provided for @memoryTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Memory title'**
  String get memoryTitleLabel;

  /// No description provided for @memoryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Day at the Zoo'**
  String get memoryTitleHint;

  /// No description provided for @memoryDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get memoryDescriptionLabel;

  /// No description provided for @memoryDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell the story behind this memory'**
  String get memoryDescriptionHint;

  /// No description provided for @memoryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get memoryDateLabel;

  /// No description provided for @memoryDateHint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get memoryDateHint;

  /// No description provided for @memoryLocationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get memoryLocationOptional;

  /// No description provided for @memoryLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Al Ain Zoo'**
  String get memoryLocationHint;

  /// No description provided for @saveMemory.
  ///
  /// In en, this message translates to:
  /// **'Save Memory'**
  String get saveMemory;

  /// No description provided for @editMemory.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get editMemory;

  /// No description provided for @enterMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the memory.'**
  String get enterMemoryTitle;

  /// No description provided for @couldNotSaveMemoryChangesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save these changes. Please try again.'**
  String get couldNotSaveMemoryChangesTryAgain;

  /// No description provided for @couldNotSaveMemoryChanges.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes: {error}'**
  String couldNotSaveMemoryChanges(String error);

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @storyLabel.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storyLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @deleteMemoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete memory?'**
  String get deleteMemoryQuestion;

  /// No description provided for @deleteMemoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This memory will be permanently removed from your family memories.'**
  String get deleteMemoryWarning;

  /// No description provided for @deletingMemory.
  ///
  /// In en, this message translates to:
  /// **'Deleting memory...'**
  String get deletingMemory;

  /// No description provided for @couldNotDeleteMemory.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this memory. Please try again.'**
  String get couldNotDeleteMemory;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @memoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Memory not found.'**
  String get memoryNotFound;

  /// No description provided for @memoryDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this memory. Please try again.'**
  String get memoryDetailsLoadError;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @editMemoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit memory'**
  String get editMemoryTooltip;

  /// No description provided for @deleteMemoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete memory'**
  String get deleteMemoryTooltip;

  /// No description provided for @validationMemoryTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Memory title is required.'**
  String get validationMemoryTitleRequired;

  /// No description provided for @validationMemoryTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Memory title must contain at least 2 characters.'**
  String get validationMemoryTitleMinLength;

  /// No description provided for @validationMemoryTitleMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Memory title cannot exceed 60 characters.'**
  String get validationMemoryTitleMaxLength;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFamilySection.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get profileFamilySection;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @familyWishes.
  ///
  /// In en, this message translates to:
  /// **'Family Wishes'**
  String get familyWishes;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @silaDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Sila Developer'**
  String get silaDeveloper;

  /// No description provided for @developerFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Developer Family'**
  String get developerFamilyName;

  /// No description provided for @familyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Family: {name}'**
  String familyNameLabel(String name);

  /// No description provided for @noFamilyJoinedYet.
  ///
  /// In en, this message translates to:
  /// **'No family joined yet'**
  String get noFamilyJoinedYet;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @profileDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String profileDayCount(int count);

  /// No description provided for @memoryKeeper.
  ///
  /// In en, this message translates to:
  /// **'Memory Keeper'**
  String get memoryKeeper;

  /// No description provided for @memoryKeeperDescription.
  ///
  /// In en, this message translates to:
  /// **'Save 100 family memories.'**
  String get memoryKeeperDescription;

  /// No description provided for @quizMaster.
  ///
  /// In en, this message translates to:
  /// **'Quiz Master'**
  String get quizMaster;

  /// No description provided for @quizMasterDescription.
  ///
  /// In en, this message translates to:
  /// **'Win 20 Family Quizzes.'**
  String get quizMasterDescription;

  /// No description provided for @teamPlayer.
  ///
  /// In en, this message translates to:
  /// **'Team Player'**
  String get teamPlayer;

  /// No description provided for @teamPlayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 30 Family Missions.'**
  String get teamPlayerDescription;

  /// No description provided for @noFamilyWishesYet.
  ///
  /// In en, this message translates to:
  /// **'No Family Wishes yet'**
  String get noFamilyWishesYet;

  /// No description provided for @familyWishesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Family Wishes earned from major competitions will appear here.'**
  String get familyWishesEmptyDescription;

  /// No description provided for @noTrophiesYet.
  ///
  /// In en, this message translates to:
  /// **'No trophies yet'**
  String get noTrophiesYet;

  /// No description provided for @trophiesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Weekly and monthly championship trophies will appear here.'**
  String get trophiesEmptyDescription;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @appSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Language, notifications, and preferences'**
  String get appSettingsDescription;

  /// No description provided for @youHaveNotJoinedFamily.
  ///
  /// In en, this message translates to:
  /// **'You have not joined a family yet.'**
  String get youHaveNotJoinedFamily;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeLabel;

  /// No description provided for @copyInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Copy invite code'**
  String get copyInviteCode;

  /// No description provided for @familyInviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Family invite code copied.'**
  String get familyInviteCodeCopied;

  /// No description provided for @profileFamilyMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No family members} =1{1 family member} other{{count} family members}}'**
  String profileFamilyMemberCount(int count);

  /// No description provided for @shareFamilyInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with relatives so they can join this family.'**
  String get shareFamilyInviteCode;

  /// No description provided for @missionsSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to view missions.'**
  String get missionsSignInRequired;

  /// No description provided for @missionsFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before completing missions.'**
  String get missionsFamilyRequired;

  /// No description provided for @missionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load Family Missions. Please try again.'**
  String get missionsLoadError;

  /// No description provided for @missionGeneric.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get missionGeneric;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @whoParticipated.
  ///
  /// In en, this message translates to:
  /// **'Who participated?'**
  String get whoParticipated;

  /// No description provided for @participantSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the family members who actually took part. Family missions require at least 2 participants.'**
  String get participantSelectionDescription;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @useCameraAsProof.
  ///
  /// In en, this message translates to:
  /// **'Use the camera as proof'**
  String get useCameraAsProof;

  /// No description provided for @choosePhotoOrScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo or Screenshot'**
  String get choosePhotoOrScreenshot;

  /// No description provided for @chooseExistingImage.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing image from your device'**
  String get chooseExistingImage;

  /// No description provided for @missionImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That image is too large. Please choose a smaller image.'**
  String get missionImageTooLarge;

  /// No description provided for @reviewYourProof.
  ///
  /// In en, this message translates to:
  /// **'Review Your Proof'**
  String get reviewYourProof;

  /// No description provided for @missionProofPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Your image is sent securely to Google Gemini through Sila\'s server only to verify this mission. Sila stores the verdict, not a copy of the image.'**
  String get missionProofPrivacyNotice;

  /// No description provided for @missionProofConsent.
  ///
  /// In en, this message translates to:
  /// **'I consent to AI verification of this image.'**
  String get missionProofConsent;

  /// No description provided for @participantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants: {names}'**
  String participantsLabel(String names);

  /// No description provided for @explanationOptional.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get explanationOptional;

  /// No description provided for @missionExplanationHint.
  ///
  /// In en, this message translates to:
  /// **'Add useful context that the image may not show clearly.'**
  String get missionExplanationHint;

  /// No description provided for @verifyProof.
  ///
  /// In en, this message translates to:
  /// **'Verify Proof'**
  String get verifyProof;

  /// No description provided for @aiCheckingMissionProof.
  ///
  /// In en, this message translates to:
  /// **'AI is checking your mission proof...'**
  String get aiCheckingMissionProof;

  /// No description provided for @couldNotVerifyMissionProof.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the mission proof. Please try again.'**
  String get couldNotVerifyMissionProof;

  /// No description provided for @needClearerProof.
  ///
  /// In en, this message translates to:
  /// **'We Need Clearer Proof'**
  String get needClearerProof;

  /// No description provided for @proofNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Proof Not Verified'**
  String get proofNotVerified;

  /// No description provided for @verificationFailureDescription.
  ///
  /// In en, this message translates to:
  /// **'{reason}\n\nYou can submit another image or add a clearer explanation.'**
  String verificationFailureDescription(String reason);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @missionAlreadyRewarded.
  ///
  /// In en, this message translates to:
  /// **'This mission has already been rewarded.'**
  String get missionAlreadyRewarded;

  /// No description provided for @missionRewardSaveError.
  ///
  /// In en, this message translates to:
  /// **'The proof was verified, but the reward could not be saved. Please try again.'**
  String get missionRewardSaveError;

  /// No description provided for @familyMissionMinimumParticipants.
  ///
  /// In en, this message translates to:
  /// **'A family mission needs at least 2 participants.'**
  String get familyMissionMinimumParticipants;

  /// No description provided for @missionVerified.
  ///
  /// In en, this message translates to:
  /// **'Mission Verified!'**
  String get missionVerified;

  /// No description provided for @familyMissionRewardSuccess.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens were awarded to each participant.\n\n{participants}\n\nYour family\'s weekly mission progress has been updated.'**
  String familyMissionRewardSuccess(int tokens, String participants);

  /// No description provided for @personalMissionRewardSuccess.
  ///
  /// In en, this message translates to:
  /// **'You earned {tokens} tokens.\n\nYour weekly mission progress has been updated.'**
  String personalMissionRewardSuccess(int tokens);

  /// No description provided for @nice.
  ///
  /// In en, this message translates to:
  /// **'Nice!'**
  String get nice;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get difficultyChallenge;

  /// No description provided for @yourMissions.
  ///
  /// In en, this message translates to:
  /// **'Your Missions'**
  String get yourMissions;

  /// No description provided for @personalMissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} personal missions remaining this week'**
  String personalMissionsSubtitle(int count);

  /// No description provided for @sharedMissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} shared missions remaining this week'**
  String sharedMissionsSubtitle(int count);

  /// No description provided for @recentlyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Recently Completed'**
  String get recentlyCompleted;

  /// No description provided for @doMoreTogether.
  ///
  /// In en, this message translates to:
  /// **'Do More Together'**
  String get doMoreTogether;

  /// No description provided for @missionsHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'{count} missions remain on this week\'s board. Verified completions stay complete until the board resets.'**
  String missionsHeaderDescription(int count);

  /// No description provided for @missionsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed} other{{count} completed}}'**
  String missionsCompletedCount(int count);

  /// No description provided for @missionTokensEarnedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mission token earned} other{{count} mission tokens earned}}'**
  String missionTokensEarnedCount(int count);

  /// No description provided for @missionWeekWindow.
  ///
  /// In en, this message translates to:
  /// **'This week • {start}–{end}'**
  String missionWeekWindow(String start, String end);

  /// No description provided for @personalWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Personal progress • {completed}/{total}'**
  String personalWeeklyProgress(int completed, int total);

  /// No description provided for @familyWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Family progress • {completed}/{total}'**
  String familyWeeklyProgress(int completed, int total);

  /// No description provided for @personalWeekComplete.
  ///
  /// In en, this message translates to:
  /// **'Your personal missions are complete!'**
  String get personalWeekComplete;

  /// No description provided for @familyWeekComplete.
  ///
  /// In en, this message translates to:
  /// **'Your family completed every shared mission!'**
  String get familyWeekComplete;

  /// No description provided for @missionsResetMonday.
  ///
  /// In en, this message translates to:
  /// **'A fresh mission board arrives next Monday.'**
  String get missionsResetMonday;

  /// No description provided for @aiProofRequired.
  ///
  /// In en, this message translates to:
  /// **'AI proof required'**
  String get aiProofRequired;

  /// No description provided for @personalLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalLabel;

  /// No description provided for @missionCategoryOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get missionCategoryOutdoor;

  /// No description provided for @missionCategoryTogetherTime.
  ///
  /// In en, this message translates to:
  /// **'Together Time'**
  String get missionCategoryTogetherTime;

  /// No description provided for @missionCategoryMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get missionCategoryMemories;

  /// No description provided for @missionCategoryKindness.
  ///
  /// In en, this message translates to:
  /// **'Kindness'**
  String get missionCategoryKindness;

  /// No description provided for @missionCategoryConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get missionCategoryConnection;

  /// No description provided for @missionCategoryFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get missionCategoryFun;

  /// No description provided for @missionCategoryTeamwork.
  ///
  /// In en, this message translates to:
  /// **'Teamwork'**
  String get missionCategoryTeamwork;

  /// No description provided for @missionTokenReward.
  ///
  /// In en, this message translates to:
  /// **'+{count} tokens'**
  String missionTokenReward(int count);

  /// No description provided for @aiProofFamilyReward.
  ///
  /// In en, this message translates to:
  /// **'AI proof • reward for each participant'**
  String get aiProofFamilyReward;

  /// No description provided for @aiProofPersonalReward.
  ///
  /// In en, this message translates to:
  /// **'AI proof • reward for you'**
  String get aiProofPersonalReward;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed {date}'**
  String completedOn(String date);

  /// No description provided for @familyMissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Family Mission'**
  String get familyMissionLabel;

  /// No description provided for @personalMissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Mission'**
  String get personalMissionLabel;

  /// No description provided for @familyMissionDetailsReward.
  ///
  /// In en, this message translates to:
  /// **'Choose who participated. The mission can be claimed once by the family, and each participant earns {tokens} tokens.'**
  String familyMissionDetailsReward(int tokens);

  /// No description provided for @personalMissionDetailsReward.
  ///
  /// In en, this message translates to:
  /// **'Complete this yourself and earn {tokens} tokens.'**
  String personalMissionDetailsReward(int tokens);

  /// No description provided for @proofGuidance.
  ///
  /// In en, this message translates to:
  /// **'Proof guidance'**
  String get proofGuidance;

  /// No description provided for @cooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get cooldown;

  /// No description provided for @missionCooldownDescription.
  ///
  /// In en, this message translates to:
  /// **'After completion, this mission cannot return for {count} days.'**
  String missionCooldownDescription(int count);

  /// No description provided for @submitProof.
  ///
  /// In en, this message translates to:
  /// **'Submit Proof'**
  String get submitProof;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get notYet;

  /// No description provided for @missionPersonalAppreciationTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Some Appreciation'**
  String get missionPersonalAppreciationTitle;

  /// No description provided for @missionPersonalAppreciationDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell one family member something specific that you genuinely appreciate about them.'**
  String get missionPersonalAppreciationDescription;

  /// No description provided for @missionPersonalAppreciationProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a relevant photo or screenshot and briefly explain what you said or did.'**
  String get missionPersonalAppreciationProofHint;

  /// No description provided for @missionPersonalHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Without Being Asked'**
  String get missionPersonalHelpTitle;

  /// No description provided for @missionPersonalHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Do one genuinely helpful thing for a family member before they ask you.'**
  String get missionPersonalHelpDescription;

  /// No description provided for @missionPersonalHelpProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a relevant or before-and-after photo and explain what you helped with.'**
  String get missionPersonalHelpProofHint;

  /// No description provided for @missionPersonalCallRelativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Someone You Love'**
  String get missionPersonalCallRelativeTitle;

  /// No description provided for @missionPersonalCallRelativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Call or video chat with a relative you have not spoken to recently.'**
  String get missionPersonalCallRelativeDescription;

  /// No description provided for @missionPersonalCallRelativeProofHint.
  ///
  /// In en, this message translates to:
  /// **'A call screenshot is ideal. Avoid exposing private phone numbers when possible.'**
  String get missionPersonalCallRelativeProofHint;

  /// No description provided for @missionPersonalFamilyStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover a Family Story'**
  String get missionPersonalFamilyStoryTitle;

  /// No description provided for @missionPersonalFamilyStoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask a family member to tell you a funny, meaningful, or memorable story from their past.'**
  String get missionPersonalFamilyStoryDescription;

  /// No description provided for @missionPersonalFamilyStoryProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a relevant photo and briefly explain what story you learned.'**
  String get missionPersonalFamilyStoryProofHint;

  /// No description provided for @missionPersonalMakeDrinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Something for Someone'**
  String get missionPersonalMakeDrinkTitle;

  /// No description provided for @missionPersonalMakeDrinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Prepare a drink, snack, or small treat for a family member.'**
  String get missionPersonalMakeDrinkDescription;

  /// No description provided for @missionPersonalMakeDrinkProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo of what you prepared.'**
  String get missionPersonalMakeDrinkProofHint;

  /// No description provided for @missionPersonalMemoryQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask About an Old Memory'**
  String get missionPersonalMemoryQuestionTitle;

  /// No description provided for @missionPersonalMemoryQuestionDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask an older family member about a memorable moment from their childhood.'**
  String get missionPersonalMemoryQuestionDescription;

  /// No description provided for @missionPersonalMemoryQuestionProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a relevant photo and use the explanation box to briefly describe what you learned.'**
  String get missionPersonalMemoryQuestionProofHint;

  /// No description provided for @missionPersonalSmallCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Fix One Messy Spot'**
  String get missionPersonalSmallCleanupTitle;

  /// No description provided for @missionPersonalSmallCleanupDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one small messy area at home and organize it properly.'**
  String get missionPersonalSmallCleanupDescription;

  /// No description provided for @missionPersonalSmallCleanupProofHint.
  ///
  /// In en, this message translates to:
  /// **'A before-and-after photo is the strongest proof.'**
  String get missionPersonalSmallCleanupProofHint;

  /// No description provided for @missionPersonalKindMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Kind Message'**
  String get missionPersonalKindMessageTitle;

  /// No description provided for @missionPersonalKindMessageDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a thoughtful message to a family member just to make their day better.'**
  String get missionPersonalKindMessageDescription;

  /// No description provided for @missionPersonalKindMessageProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a screenshot with private or sensitive details hidden if necessary.'**
  String get missionPersonalKindMessageProofHint;

  /// No description provided for @missionPersonalLearnRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn a Family Recipe'**
  String get missionPersonalLearnRecipeTitle;

  /// No description provided for @missionPersonalLearnRecipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask a relative how to make a family recipe and learn something about where it came from.'**
  String get missionPersonalLearnRecipeDescription;

  /// No description provided for @missionPersonalLearnRecipeProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo of the recipe, ingredients, preparation, or finished food.'**
  String get missionPersonalLearnRecipeProofHint;

  /// No description provided for @missionPersonalMemorySaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a Family Memory'**
  String get missionPersonalMemorySaveTitle;

  /// No description provided for @missionPersonalMemorySaveDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one meaningful family photo and add it to your memories with a useful description.'**
  String get missionPersonalMemorySaveDescription;

  /// No description provided for @missionPersonalMemorySaveProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit the family photo or a screenshot showing the memory you saved.'**
  String get missionPersonalMemorySaveProofHint;

  /// No description provided for @missionPersonalLongHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Take Over a Chore'**
  String get missionPersonalLongHelpTitle;

  /// No description provided for @missionPersonalLongHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Take over a useful household chore for a family member and complete it properly.'**
  String get missionPersonalLongHelpDescription;

  /// No description provided for @missionPersonalLongHelpProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a relevant before, during, or after photo.'**
  String get missionPersonalLongHelpProofHint;

  /// No description provided for @missionPersonalSurpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a Small Surprise'**
  String get missionPersonalSurpriseTitle;

  /// No description provided for @missionPersonalSurpriseDescription.
  ///
  /// In en, this message translates to:
  /// **'Do something thoughtful and unexpected for someone in your family.'**
  String get missionPersonalSurpriseDescription;

  /// No description provided for @missionPersonalSurpriseProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit reasonable proof and explain what the surprise was.'**
  String get missionPersonalSurpriseProofHint;

  /// No description provided for @missionFamilyWalkTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a Family Walk'**
  String get missionFamilyWalkTitle;

  /// No description provided for @missionFamilyWalkDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend at least 20 minutes walking together and enjoy the time without rushing.'**
  String get missionFamilyWalkDescription;

  /// No description provided for @missionFamilyWalkProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo from the walk showing the activity or location.'**
  String get missionFamilyWalkProofHint;

  /// No description provided for @missionFamilyMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Share a Meal Together'**
  String get missionFamilyMealTitle;

  /// No description provided for @missionFamilyMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Sit together for a proper meal and keep phones away while you eat.'**
  String get missionFamilyMealDescription;

  /// No description provided for @missionFamilyMealProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo showing the meal, table, or family activity.'**
  String get missionFamilyMealProofHint;

  /// No description provided for @missionFamilyPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture Today'**
  String get missionFamilyPhotoTitle;

  /// No description provided for @missionFamilyPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a new family photo together and turn an ordinary day into a memory.'**
  String get missionFamilyPhotoDescription;

  /// No description provided for @missionFamilyPhotoProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit the new family photo created for this mission.'**
  String get missionFamilyPhotoProofHint;

  /// No description provided for @missionFamilyPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Play Together'**
  String get missionFamilyPlayTitle;

  /// No description provided for @missionFamilyPlayDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend at least 30 minutes playing a game together.'**
  String get missionFamilyPlayDescription;

  /// No description provided for @missionFamilyPlayProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo showing the game setup or family activity.'**
  String get missionFamilyPlayProofHint;

  /// No description provided for @missionFamilyCookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook Something Together'**
  String get missionFamilyCookTitle;

  /// No description provided for @missionFamilyCookDescription.
  ///
  /// In en, this message translates to:
  /// **'Prepare a meal, dessert, or snack together instead of leaving all the work to one person.'**
  String get missionFamilyCookDescription;

  /// No description provided for @missionFamilyCookProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo of the preparation or finished food.'**
  String get missionFamilyCookProofHint;

  /// No description provided for @missionFamilyGameNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Game Night'**
  String get missionFamilyGameNightTitle;

  /// No description provided for @missionFamilyGameNightDescription.
  ///
  /// In en, this message translates to:
  /// **'Set aside at least 45 minutes for everyone to play games together.'**
  String get missionFamilyGameNightDescription;

  /// No description provided for @missionFamilyGameNightProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo of the game setup or family playing together.'**
  String get missionFamilyGameNightProofHint;

  /// No description provided for @missionFamilyScreenFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'One Screen-Free Hour'**
  String get missionFamilyScreenFreeTitle;

  /// No description provided for @missionFamilyScreenFreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend a full hour together without phones, television, tablets, or computers.'**
  String get missionFamilyScreenFreeDescription;

  /// No description provided for @missionFamilyScreenFreeProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo of what your family did during the screen-free time.'**
  String get missionFamilyScreenFreeProofHint;

  /// No description provided for @missionFamilyCleanupTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Cleanup'**
  String get missionFamilyCleanupTitle;

  /// No description provided for @missionFamilyCleanupDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one messy area and clean or organize it together from start to finish.'**
  String get missionFamilyCleanupDescription;

  /// No description provided for @missionFamilyCleanupProofHint.
  ///
  /// In en, this message translates to:
  /// **'A before-and-after photo is ideal.'**
  String get missionFamilyCleanupProofHint;

  /// No description provided for @missionFamilyOutdoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Family Time'**
  String get missionFamilyOutdoorTitle;

  /// No description provided for @missionFamilyOutdoorDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend at least 45 minutes doing an outdoor activity together.'**
  String get missionFamilyOutdoorDescription;

  /// No description provided for @missionFamilyOutdoorProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo showing your outdoor activity or location.'**
  String get missionFamilyOutdoorProofHint;

  /// No description provided for @missionFamilyOldPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Old Family Photos'**
  String get missionFamilyOldPhotosTitle;

  /// No description provided for @missionFamilyOldPhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Look through older family photos together and talk about the stories behind them.'**
  String get missionFamilyOldPhotosDescription;

  /// No description provided for @missionFamilyOldPhotosProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo showing the album, older photos, or memory activity.'**
  String get missionFamilyOldPhotosProofHint;

  /// No description provided for @missionFamilyDessertTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Dessert Together'**
  String get missionFamilyDessertTitle;

  /// No description provided for @missionFamilyDessertDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a dessert and make it together from preparation to the final result.'**
  String get missionFamilyDessertDescription;

  /// No description provided for @missionFamilyDessertProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a preparation or finished-dessert photo.'**
  String get missionFamilyDessertProofHint;

  /// No description provided for @missionFamilyPicnicTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a Family Picnic'**
  String get missionFamilyPicnicTitle;

  /// No description provided for @missionFamilyPicnicDescription.
  ///
  /// In en, this message translates to:
  /// **'Prepare something to eat and enjoy a picnic together away from your normal dining table.'**
  String get missionFamilyPicnicDescription;

  /// No description provided for @missionFamilyPicnicProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a photo showing the picnic setup, food, or location.'**
  String get missionFamilyPicnicProofHint;

  /// No description provided for @missionFamilyVisitRelativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit a Relative'**
  String get missionFamilyVisitRelativeTitle;

  /// No description provided for @missionFamilyVisitRelativeDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend meaningful face-to-face time visiting a relative you do not see every day.'**
  String get missionFamilyVisitRelativeDescription;

  /// No description provided for @missionFamilyVisitRelativeProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit respectful evidence from the visit without exposing unnecessary private information.'**
  String get missionFamilyVisitRelativeProofHint;

  /// No description provided for @missionFamilyRecreatePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Recreate an Old Family Photo'**
  String get missionFamilyRecreatePhotoTitle;

  /// No description provided for @missionFamilyRecreatePhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose an older family picture and recreate its pose or scene together.'**
  String get missionFamilyRecreatePhotoDescription;

  /// No description provided for @missionFamilyRecreatePhotoProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit the recreated photo and explain which old photo inspired it.'**
  String get missionFamilyRecreatePhotoProofHint;

  /// No description provided for @missionFamilyKindnessProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a Kindness Project'**
  String get missionFamilyKindnessProjectTitle;

  /// No description provided for @missionFamilyKindnessProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Work together on something genuinely helpful for another person without expecting a reward from them.'**
  String get missionFamilyKindnessProjectDescription;

  /// No description provided for @missionFamilyKindnessProjectProofHint.
  ///
  /// In en, this message translates to:
  /// **'Submit safe and respectful proof of what your family made or did.'**
  String get missionFamilyKindnessProjectProofHint;

  /// No description provided for @officialWins.
  ///
  /// In en, this message translates to:
  /// **'Official Wins'**
  String get officialWins;

  /// No description provided for @dailyWins.
  ///
  /// In en, this message translates to:
  /// **'Daily Wins'**
  String get dailyWins;

  /// No description provided for @weeklyWins.
  ///
  /// In en, this message translates to:
  /// **'Weekly Wins'**
  String get weeklyWins;

  /// No description provided for @monthlyWins.
  ///
  /// In en, this message translates to:
  /// **'Monthly Wins'**
  String get monthlyWins;

  /// No description provided for @missionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Missions completed'**
  String get missionsCompleted;

  /// No description provided for @memoriesAdded.
  ///
  /// In en, this message translates to:
  /// **'Memories Added'**
  String get memoriesAdded;

  /// No description provided for @rankingPoints.
  ///
  /// In en, this message translates to:
  /// **'Ranking Points'**
  String get rankingPoints;

  /// No description provided for @homeRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get homeRewards;

  /// No description provided for @homeRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Spend Tokens on family and digital rewards.'**
  String get homeRewardsDescription;

  /// No description provided for @officialCompetitionRule.
  ///
  /// In en, this message translates to:
  /// **'One official result per family per day. Quick Play results do not affect these rewards.'**
  String get officialCompetitionRule;

  /// No description provided for @dailyWinnerRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Winner: +{tokens} Tokens + {points} Ranking Points'**
  String dailyWinnerRewardSummary(int tokens, int points);

  /// No description provided for @dailyRunnerUpRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Runner-up: +{points} Ranking Points'**
  String dailyRunnerUpRewardSummary(int points);

  /// No description provided for @savingOfficialResult.
  ///
  /// In en, this message translates to:
  /// **'Saving official result...'**
  String get savingOfficialResult;

  /// No description provided for @dailyOfficialCompleteEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge complete'**
  String get dailyOfficialCompleteEyebrow;

  /// No description provided for @familyChallengeCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Family challenge complete'**
  String get familyChallengeCompleteTitle;

  /// No description provided for @dailyCompleteWithoutWinner.
  ///
  /// In en, this message translates to:
  /// **'Your family showed up, played together, and completed today\'s official challenge.'**
  String get dailyCompleteWithoutWinner;

  /// No description provided for @dailyCompleteWithWinner.
  ///
  /// In en, this message translates to:
  /// **'{name} takes today\'s family crown. Come back tomorrow for a fresh challenge.'**
  String dailyCompleteWithWinner(String name);

  /// No description provided for @tokenBonus.
  ///
  /// In en, this message translates to:
  /// **'+{count} Tokens'**
  String tokenBonus(int count);

  /// No description provided for @rankingPointBonus.
  ///
  /// In en, this message translates to:
  /// **'+{count} RP'**
  String rankingPointBonus(int count);

  /// No description provided for @familyMoment.
  ///
  /// In en, this message translates to:
  /// **'Family moment'**
  String get familyMoment;

  /// No description provided for @tieDetected.
  ///
  /// In en, this message translates to:
  /// **'Tie detected'**
  String get tieDetected;

  /// No description provided for @tieRewardPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'No Tokens or Ranking Points have been awarded. Only the tied leaders advance to sudden death. No reward is granted until one winner remains.'**
  String get tieRewardPendingDescription;

  /// No description provided for @startSuddenDeathTieBreak.
  ///
  /// In en, this message translates to:
  /// **'Start Sudden-Death Tie-Break'**
  String get startSuddenDeathTieBreak;

  /// No description provided for @latestResult.
  ///
  /// In en, this message translates to:
  /// **'Latest Result'**
  String get latestResult;

  /// No description provided for @pointsAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String pointsAbbreviation(int count);

  /// No description provided for @weeklyCompetitionDescription.
  ///
  /// In en, this message translates to:
  /// **'Four official games. Championship Points accumulate across every round.'**
  String get weeklyCompetitionDescription;

  /// No description provided for @championshipRewards.
  ///
  /// In en, this message translates to:
  /// **'Championship rewards'**
  String get championshipRewards;

  /// No description provided for @championRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Champion: +{tokens} Tokens + {points} RP'**
  String championRewardSummary(int tokens, int points);

  /// No description provided for @runnerUpRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Runner-up: +{points} RP'**
  String runnerUpRewardSummary(int points);

  /// No description provided for @thirdPlaceRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Third place: +{points} RP'**
  String thirdPlaceRewardSummary(int points);

  /// No description provided for @championshipScoringDescription.
  ///
  /// In en, this message translates to:
  /// **'Individual rounds: 1st 10 • 2nd 7 • 3rd 5 • 4th 3 • participation 1\nTeam rounds: winning-team members +1 • losing-team members +0'**
  String get championshipScoringDescription;

  /// No description provided for @thisWeeksGames.
  ///
  /// In en, this message translates to:
  /// **'This week\'s games'**
  String get thisWeeksGames;

  /// No description provided for @roundComplete.
  ///
  /// In en, this message translates to:
  /// **'Round complete'**
  String get roundComplete;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @roundLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked until previous round is complete'**
  String get roundLocked;

  /// No description provided for @savingRound.
  ///
  /// In en, this message translates to:
  /// **'Saving round...'**
  String get savingRound;

  /// No description provided for @playGameNumber.
  ///
  /// In en, this message translates to:
  /// **'Play Game {number}: {name}'**
  String playGameNumber(int number, String name);

  /// No description provided for @finalizingChampionship.
  ///
  /// In en, this message translates to:
  /// **'Finalizing championship...'**
  String get finalizingChampionship;

  /// No description provided for @finalizeWeeklyChampionship.
  ///
  /// In en, this message translates to:
  /// **'Finalize Weekly Championship'**
  String get finalizeWeeklyChampionship;

  /// No description provided for @championshipStandings.
  ///
  /// In en, this message translates to:
  /// **'Championship Standings'**
  String get championshipStandings;

  /// No description provided for @roundsPlayed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 round played} other{{count} rounds played}}'**
  String roundsPlayed(int count);

  /// No description provided for @weeklyOfficialCompleteEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Weekly Championship complete'**
  String get weeklyOfficialCompleteEyebrow;

  /// No description provided for @newFamilyChampion.
  ///
  /// In en, this message translates to:
  /// **'A new family champion'**
  String get newFamilyChampion;

  /// No description provided for @weeklyCompleteWithoutChampion.
  ///
  /// In en, this message translates to:
  /// **'Four games, one shared week, and a family story worth remembering.'**
  String get weeklyCompleteWithoutChampion;

  /// No description provided for @weeklyCompleteWithChampion.
  ///
  /// In en, this message translates to:
  /// **'{name} is this week\'s Family Champion after four games together.'**
  String weeklyCompleteWithChampion(String name);

  /// No description provided for @weeklyCrown.
  ///
  /// In en, this message translates to:
  /// **'Weekly crown'**
  String get weeklyCrown;

  /// No description provided for @monthlyCompetitionDescription.
  ///
  /// In en, this message translates to:
  /// **'Four family members. Two semifinals. One final. One champion.'**
  String get monthlyCompetitionDescription;

  /// No description provided for @monthlyRewards.
  ///
  /// In en, this message translates to:
  /// **'Monthly rewards'**
  String get monthlyRewards;

  /// No description provided for @monthlyChampionRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Champion: +{tokens} Tokens + {points} RP + Trophy'**
  String monthlyChampionRewardSummary(int tokens, int points);

  /// No description provided for @semifinalistRewardSummary.
  ///
  /// In en, this message translates to:
  /// **'Semifinalists: +{points} RP'**
  String semifinalistRewardSummary(int points);

  /// No description provided for @chooseFourCompetitors.
  ///
  /// In en, this message translates to:
  /// **'Choose exactly 4 competitors'**
  String get chooseFourCompetitors;

  /// No description provided for @startingMonthlyCup.
  ///
  /// In en, this message translates to:
  /// **'Starting Monthly Cup...'**
  String get startingMonthlyCup;

  /// No description provided for @startMonthlyCup.
  ///
  /// In en, this message translates to:
  /// **'Start Monthly Cup'**
  String get startMonthlyCup;

  /// No description provided for @monthlyParticipantIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cup participant data is incomplete.'**
  String get monthlyParticipantIncomplete;

  /// No description provided for @monthlyCupBracket.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cup Bracket'**
  String get monthlyCupBracket;

  /// No description provided for @semifinalNumber.
  ///
  /// In en, this message translates to:
  /// **'Semifinal {number}'**
  String semifinalNumber(int number);

  /// No description provided for @finalRound.
  ///
  /// In en, this message translates to:
  /// **'FINAL'**
  String get finalRound;

  /// No description provided for @gameNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Game: {name}'**
  String gameNameLabel(String name);

  /// No description provided for @versusPlayers.
  ///
  /// In en, this message translates to:
  /// **'{first} vs {second}'**
  String versusPlayers(String first, String second);

  /// No description provided for @winnerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Winner: {name}'**
  String winnerNameLabel(String name);

  /// No description provided for @playNamedRound.
  ///
  /// In en, this message translates to:
  /// **'Play {round}'**
  String playNamedRound(String round);

  /// No description provided for @monthlyCupChampion.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cup Champion'**
  String get monthlyCupChampion;

  /// No description provided for @champion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get champion;

  /// No description provided for @monthlyCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'The family\'s biggest competition ends with a trophy and a memory for the cabinet.'**
  String get monthlyCompleteDescription;

  /// No description provided for @cupTrophy.
  ///
  /// In en, this message translates to:
  /// **'Cup trophy'**
  String get cupTrophy;

  /// No description provided for @tieBreak.
  ///
  /// In en, this message translates to:
  /// **'Tie-Break'**
  String get tieBreak;

  /// No description provided for @suddenDeathRound.
  ///
  /// In en, this message translates to:
  /// **'Sudden Death • Round {number}'**
  String suddenDeathRound(int number);

  /// No description provided for @counting.
  ///
  /// In en, this message translates to:
  /// **'Counting...'**
  String get counting;

  /// No description provided for @passPhoneTo.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone to {name}'**
  String passPhoneTo(String name);

  /// No description provided for @stopAtFiveSeconds.
  ///
  /// In en, this message translates to:
  /// **'Stop when you think exactly 5 seconds have passed.'**
  String get stopAtFiveSeconds;

  /// No description provided for @goalFiveSeconds.
  ///
  /// In en, this message translates to:
  /// **'Your goal is to stop as close as possible to exactly 5 seconds.'**
  String get goalFiveSeconds;

  /// No description provided for @hiddenTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'The timer stays hidden. Closest result wins.'**
  String get hiddenTimerDescription;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get stop;

  /// No description provided for @tieBreakWinner.
  ///
  /// In en, this message translates to:
  /// **'{name} wins the tie-break!'**
  String tieBreakWinner(String name);

  /// No description provided for @secondsFromTarget.
  ///
  /// In en, this message translates to:
  /// **'Only {seconds} seconds away from exactly 5.000 seconds.'**
  String secondsFromTarget(String seconds);

  /// No description provided for @confirmWinner.
  ///
  /// In en, this message translates to:
  /// **'Confirm Winner'**
  String get confirmWinner;

  /// No description provided for @stillTied.
  ///
  /// In en, this message translates to:
  /// **'Still tied!'**
  String get stillTied;

  /// No description provided for @tiedPlayersContinue.
  ///
  /// In en, this message translates to:
  /// **'{count} players were equally close. Only those players continue to Round {round}.'**
  String tiedPlayersContinue(int count, int round);

  /// No description provided for @startTieBreakRound.
  ///
  /// In en, this message translates to:
  /// **'Start Tie-Break Round {number}'**
  String startTieBreakRound(int number);

  /// No description provided for @gameFamilyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SILA FAMILY GAME'**
  String get gameFamilyEyebrow;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @roundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a quick round or play a longer 3 or 5-round game.'**
  String get roundsDescription;

  /// No description provided for @roundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} round} other{{count} rounds}}'**
  String roundCount(int count);

  /// No description provided for @mustBeLoggedInToPlay.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to play.'**
  String get mustBeLoggedInToPlay;

  /// No description provided for @emojiFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before playing Emoji Guess.'**
  String get emojiFamilyRequired;

  /// No description provided for @couldNotLoadFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Could not load your family members.'**
  String get couldNotLoadFamilyMembers;

  /// No description provided for @familyMemberFallback.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMemberFallback;

  /// No description provided for @emojiGuessSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Build two teams and decode playful emoji clues before time runs out.'**
  String get emojiGuessSetupDescription;

  /// No description provided for @whoIsPlaying.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get whoIsPlaying;

  /// No description provided for @chooseAtLeastTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose at least 2 players for the family match.'**
  String get chooseAtLeastTwoPlayers;

  /// No description provided for @chooseTeams.
  ///
  /// In en, this message translates to:
  /// **'Choose teams'**
  String get chooseTeams;

  /// No description provided for @assignPlayersToTeams.
  ///
  /// In en, this message translates to:
  /// **'Assign every selected player to Team A or Team B.'**
  String get assignPlayersToTeams;

  /// No description provided for @teamA.
  ///
  /// In en, this message translates to:
  /// **'Team A'**
  String get teamA;

  /// No description provided for @teamB.
  ///
  /// In en, this message translates to:
  /// **'Team B'**
  String get teamB;

  /// No description provided for @shuffleTeams.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Teams'**
  String get shuffleTeams;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get categoryMovies;

  /// No description provided for @categoryAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get categoryAnimals;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get categoryPlaces;

  /// No description provided for @categoryMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get categoryMixed;

  /// No description provided for @matchPace.
  ///
  /// In en, this message translates to:
  /// **'Match pace'**
  String get matchPace;

  /// No description provided for @puzzlesPerRound.
  ///
  /// In en, this message translates to:
  /// **'Puzzles per round'**
  String get puzzlesPerRound;

  /// No description provided for @timePerPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Time per puzzle'**
  String get timePerPuzzle;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sec'**
  String secondsShort(int count);

  /// No description provided for @preparingNamedGame.
  ///
  /// In en, this message translates to:
  /// **'Preparing {game}...'**
  String preparingNamedGame(String game);

  /// No description provided for @startNamedGame.
  ///
  /// In en, this message translates to:
  /// **'Start {game}'**
  String startNamedGame(String game);

  /// No description provided for @teamTurn.
  ///
  /// In en, this message translates to:
  /// **'{team}\'s turn'**
  String teamTurn(String team);

  /// No description provided for @stealTeam.
  ///
  /// In en, this message translates to:
  /// **'Steal — {team}'**
  String stealTeam(String team);

  /// No description provided for @roundPuzzleProgress.
  ///
  /// In en, this message translates to:
  /// **'Round {round} of {totalRounds} • Puzzle {puzzle} of {totalPuzzles}'**
  String roundPuzzleProgress(int round, int totalRounds, int puzzle, int totalPuzzles);

  /// No description provided for @secondsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} s'**
  String secondsRemaining(int count);

  /// No description provided for @hintLabel.
  ///
  /// In en, this message translates to:
  /// **'Hint: {hint}'**
  String hintLabel(String hint);

  /// No description provided for @typeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer'**
  String get typeYourAnswer;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @submitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get submitAnswer;

  /// No description provided for @teamScore.
  ///
  /// In en, this message translates to:
  /// **'{team}: {score}'**
  String teamScore(String team, int score);

  /// No description provided for @puzzleComplete.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Complete'**
  String get puzzleComplete;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String answerLabel(String answer);

  /// No description provided for @roundResults.
  ///
  /// In en, this message translates to:
  /// **'Round Results'**
  String get roundResults;

  /// No description provided for @nextPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Next Puzzle'**
  String get nextPuzzle;

  /// No description provided for @roundNumberComplete.
  ///
  /// In en, this message translates to:
  /// **'Round {number} Complete'**
  String roundNumberComplete(int number);

  /// No description provided for @startTieBreaker.
  ///
  /// In en, this message translates to:
  /// **'Start Tie-Breaker'**
  String get startTieBreaker;

  /// No description provided for @seeFinalResults.
  ///
  /// In en, this message translates to:
  /// **'See Final Results'**
  String get seeFinalResults;

  /// No description provided for @startRound.
  ///
  /// In en, this message translates to:
  /// **'Start Round {number}'**
  String startRound(int number);

  /// No description provided for @tieBreakerTeam.
  ///
  /// In en, this message translates to:
  /// **'Tie-Breaker — {team}'**
  String tieBreakerTeam(String team);

  /// No description provided for @teamWins.
  ///
  /// In en, this message translates to:
  /// **'{team} Wins!'**
  String teamWins(String team);

  /// No description provided for @returnToCompetition.
  ///
  /// In en, this message translates to:
  /// **'Return to {competition}'**
  String returnToCompetition(String competition);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backToGames.
  ///
  /// In en, this message translates to:
  /// **'Back to Games'**
  String get backToGames;

  /// No description provided for @noStealAnswer.
  ///
  /// In en, this message translates to:
  /// **'No steal.\n\nAnswer: {answer}'**
  String noStealAnswer(String answer);

  /// No description provided for @teamGuessedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'{team} guessed correctly!\n\n+{points} points'**
  String teamGuessedCorrectly(String team, int points);

  /// No description provided for @teamStolePuzzle.
  ///
  /// In en, this message translates to:
  /// **'{team} stole the puzzle!\n\n+{points} point'**
  String teamStolePuzzle(String team, int points);

  /// No description provided for @stealMissedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Steal missed.\n\nAnswer: {answer}'**
  String stealMissedAnswer(String answer);

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// No description provided for @categoryFamilyFun.
  ///
  /// In en, this message translates to:
  /// **'Family Fun'**
  String get categoryFamilyFun;

  /// No description provided for @categoryFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get categoryFavorites;

  /// No description provided for @categoryHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get categoryHabits;

  /// No description provided for @categoryMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get categoryMemories;

  /// No description provided for @categoryMostLikelyTo.
  ///
  /// In en, this message translates to:
  /// **'Most Likely To'**
  String get categoryMostLikelyTo;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryAtHome.
  ///
  /// In en, this message translates to:
  /// **'At Home'**
  String get categoryAtHome;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get categoryActions;

  /// No description provided for @categoryObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get categoryObjects;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryFunny.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get categoryFunny;

  /// No description provided for @categoryFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get categoryFriends;

  /// No description provided for @categoryScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get categoryScience;

  /// No description provided for @categoryGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get categoryGeography;

  /// No description provided for @categoryHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get categoryHistory;

  /// No description provided for @categoryGeneralKnowledge.
  ///
  /// In en, this message translates to:
  /// **'General Knowledge'**
  String get categoryGeneralKnowledge;

  /// No description provided for @categoryActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get categoryActivities;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get categoryTechnology;

  /// No description provided for @categoryUaeHeritage.
  ///
  /// In en, this message translates to:
  /// **'UAE & Heritage'**
  String get categoryUaeHeritage;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get pickCategory;

  /// No description provided for @couldNotReachAiOfflinePrompts.
  ///
  /// In en, this message translates to:
  /// **'Could not reach AI. Using offline prompts instead.'**
  String get couldNotReachAiOfflinePrompts;

  /// No description provided for @couldNotReachAiOfflineQuestions.
  ///
  /// In en, this message translates to:
  /// **'Could not reach AI. Using offline questions instead.'**
  String get couldNotReachAiOfflineQuestions;

  /// No description provided for @generatingPrompts.
  ///
  /// In en, this message translates to:
  /// **'Generating prompts...'**
  String get generatingPrompts;

  /// No description provided for @generatingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Generating questions...'**
  String get generatingQuestions;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @startCharades.
  ///
  /// In en, this message translates to:
  /// **'Start Charades'**
  String get startCharades;

  /// No description provided for @promptProgress.
  ///
  /// In en, this message translates to:
  /// **'Prompt {current} of {total}'**
  String promptProgress(int current, int total);

  /// No description provided for @roundProgress.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String roundProgress(int current, int total);

  /// No description provided for @gameProgress.
  ///
  /// In en, this message translates to:
  /// **'Game progress'**
  String get gameProgress;

  /// No description provided for @nextPrompt.
  ///
  /// In en, this message translates to:
  /// **'Next Prompt'**
  String get nextPrompt;

  /// No description provided for @charadesRoundComplete.
  ///
  /// In en, this message translates to:
  /// **'Charades round complete!'**
  String get charadesRoundComplete;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @iHave.
  ///
  /// In en, this message translates to:
  /// **'I Have'**
  String get iHave;

  /// No description provided for @roundCompleteCelebration.
  ///
  /// In en, this message translates to:
  /// **'Round Complete!'**
  String get roundCompleteCelebration;

  /// No description provided for @iHaveCount.
  ///
  /// In en, this message translates to:
  /// **'I Have: {count}'**
  String iHaveCount(int count);

  /// No description provided for @neverCount.
  ///
  /// In en, this message translates to:
  /// **'Never: {count}'**
  String neverCount(int count);

  /// No description provided for @changeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change Category'**
  String get changeCategory;

  /// No description provided for @truth.
  ///
  /// In en, this message translates to:
  /// **'TRUTH'**
  String get truth;

  /// No description provided for @dare.
  ///
  /// In en, this message translates to:
  /// **'DARE'**
  String get dare;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @truthsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Truths completed: {count}'**
  String truthsCompleted(int count);

  /// No description provided for @daresCompleted.
  ///
  /// In en, this message translates to:
  /// **'Dares completed: {count}'**
  String daresCompleted(int count);

  /// No description provided for @charadesSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme and a 1, 3, or 5-round game, then act out each prompt without saying the answer.'**
  String get charadesSetupDescription;

  /// No description provided for @neverSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a family-friendly theme and choose 1, 3, or 5 prompts for a quick round of surprising stories.'**
  String get neverSetupDescription;

  /// No description provided for @truthDareSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a playful theme and a 1, 3, or 5-round game of safe truths and family-friendly dares.'**
  String get truthDareSetupDescription;

  /// No description provided for @wouldRatherSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a category, choose 1, 3, or 5 rounds, then discover which playful choices your family makes.'**
  String get wouldRatherSetupDescription;

  /// No description provided for @wouldYouRatherPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you rather...'**
  String get wouldYouRatherPrompt;

  /// No description provided for @chooseMostFunAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the answer that sounds the most fun to you.'**
  String get chooseMostFunAnswer;

  /// No description provided for @tapAnswerToLock.
  ///
  /// In en, this message translates to:
  /// **'Tap one answer to lock it in.'**
  String get tapAnswerToLock;

  /// No description provided for @youSelectedAnswer.
  ///
  /// In en, this message translates to:
  /// **'You selected: {answer}'**
  String youSelectedAnswer(String answer);

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next Round'**
  String get nextRound;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @completedRoundsCategory.
  ///
  /// In en, this message translates to:
  /// **'You completed {rounds} rounds in the {category} category.'**
  String completedRoundsCategory(int rounds, String category);

  /// No description provided for @changeSettings.
  ///
  /// In en, this message translates to:
  /// **'Change Settings'**
  String get changeSettings;

  /// No description provided for @triviaFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before playing Trivia.'**
  String get triviaFamilyRequired;

  /// No description provided for @couldNotPrepareTrivia.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare Trivia. Please try again.'**
  String get couldNotPrepareTrivia;

  /// No description provided for @triviaSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Build two teams, pick a category, and race through family-friendly questions.'**
  String get triviaSetupDescription;

  /// No description provided for @questionsPerRound.
  ///
  /// In en, this message translates to:
  /// **'Questions per round'**
  String get questionsPerRound;

  /// No description provided for @timePerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Time per question'**
  String get timePerQuestion;

  /// No description provided for @questionRoundProgress.
  ///
  /// In en, this message translates to:
  /// **'Round {round} of {totalRounds} • Question {question} of {totalQuestions}'**
  String questionRoundProgress(int round, int totalRounds, int question, int totalQuestions);

  /// No description provided for @questionComplete.
  ///
  /// In en, this message translates to:
  /// **'Question Complete'**
  String get questionComplete;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @noStealCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'No steal.\n\nCorrect answer: {answer}'**
  String noStealCorrectAnswer(String answer);

  /// No description provided for @teamAnsweredCorrectly.
  ///
  /// In en, this message translates to:
  /// **'{team} answered correctly!\n\n+{points} points'**
  String teamAnsweredCorrectly(String team, int points);

  /// No description provided for @teamStoleQuestion.
  ///
  /// In en, this message translates to:
  /// **'{team} stole the question!\n\n+{points} point'**
  String teamStoleQuestion(String team, int points);

  /// No description provided for @stealMissedCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Steal missed.\n\nCorrect answer: {answer}'**
  String stealMissedCorrectAnswer(String answer);

  /// No description provided for @triviaTie.
  ///
  /// In en, this message translates to:
  /// **'Trivia Tie!'**
  String get triviaTie;

  /// No description provided for @tieBreaker.
  ///
  /// In en, this message translates to:
  /// **'TIE-BREAKER'**
  String get tieBreaker;

  /// No description provided for @oneFinalQuestion.
  ///
  /// In en, this message translates to:
  /// **'One final question decides the winner.'**
  String get oneFinalQuestion;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @joinFamilyWishlist.
  ///
  /// In en, this message translates to:
  /// **'Join a family to use Wishlist rewards.'**
  String get joinFamilyWishlist;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @familyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Family not found.'**
  String get familyNotFound;

  /// No description provided for @noOtherFamilyRewardMembers.
  ///
  /// In en, this message translates to:
  /// **'There are no other family members to request a reward from.'**
  String get noOtherFamilyRewardMembers;

  /// No description provided for @wishlistRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Wishlist request sent to {name}.'**
  String wishlistRequestSent(String name);

  /// No description provided for @noSentRequests.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get noSentRequests;

  /// No description provided for @noSentRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'Wishlist requests you send to family members will appear here.'**
  String get noSentRequestsDescription;

  /// No description provided for @noReceivedRequests.
  ///
  /// In en, this message translates to:
  /// **'No received requests'**
  String get noReceivedRequests;

  /// No description provided for @noReceivedRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'When a family member requests a reward from you, it will appear here.'**
  String get noReceivedRequestsDescription;

  /// No description provided for @requestedFrom.
  ///
  /// In en, this message translates to:
  /// **'Requested from'**
  String get requestedFrom;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get requestedBy;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Make Offer'**
  String get makeOffer;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @confirmFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Fulfillment'**
  String get confirmFulfillment;

  /// No description provided for @rewardMarkedFulfilled.
  ///
  /// In en, this message translates to:
  /// **'{reward} marked as fulfilled.'**
  String rewardMarkedFulfilled(String reward);

  /// No description provided for @rewardAddedToGoals.
  ///
  /// In en, this message translates to:
  /// **'{reward} was added to your Rewards goals.'**
  String rewardAddedToGoals(String reward);

  /// No description provided for @offerRejected.
  ///
  /// In en, this message translates to:
  /// **'Offer rejected.'**
  String get offerRejected;

  /// No description provided for @wishlistRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Wishlist request declined.'**
  String get wishlistRequestDeclined;

  /// No description provided for @offerForReward.
  ///
  /// In en, this message translates to:
  /// **'Offer for {reward}'**
  String offerForReward(String reward);

  /// No description provided for @offerRequirementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the progress they must complete after accepting to earn this reward.'**
  String get offerRequirementsDescription;

  /// No description provided for @tokensRequired.
  ///
  /// In en, this message translates to:
  /// **'Tokens required'**
  String get tokensRequired;

  /// No description provided for @dailyChallengeWins.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge wins'**
  String get dailyChallengeWins;

  /// No description provided for @weeklyChampionshipWins.
  ///
  /// In en, this message translates to:
  /// **'Weekly Championship wins'**
  String get weeklyChampionshipWins;

  /// No description provided for @monthlyCupWins.
  ///
  /// In en, this message translates to:
  /// **'Monthly Cup wins'**
  String get monthlyCupWins;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send Offer'**
  String get sendOffer;

  /// No description provided for @addOfferRequirement.
  ///
  /// In en, this message translates to:
  /// **'Add at least one requirement to the offer.'**
  String get addOfferRequirement;

  /// No description provided for @offerSentTo.
  ///
  /// In en, this message translates to:
  /// **'Offer sent to {name}.'**
  String offerSentTo(String name);

  /// No description provided for @chooseRewardRecipient.
  ///
  /// In en, this message translates to:
  /// **'Choose who you want to request this reward from.'**
  String get chooseRewardRecipient;

  /// No description provided for @rewardMinimumLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a reward with at least 3 characters.'**
  String get rewardMinimumLength;

  /// No description provided for @whatWouldYouLikeToEarn.
  ///
  /// In en, this message translates to:
  /// **'What would you like to earn?'**
  String get whatWouldYouLikeToEarn;

  /// No description provided for @chooseMemberForOffer.
  ///
  /// In en, this message translates to:
  /// **'Choose a family member and ask them to make you an offer.'**
  String get chooseMemberForOffer;

  /// No description provided for @requestFrom.
  ///
  /// In en, this message translates to:
  /// **'Request from'**
  String get requestFrom;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @rewardExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Family day out'**
  String get rewardExample;

  /// No description provided for @optionalMessage.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get optionalMessage;

  /// No description provided for @wishlistMessageExample.
  ///
  /// In en, this message translates to:
  /// **'Example: I would like to earn this as a long-term goal.'**
  String get wishlistMessageExample;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @personLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}: {name}'**
  String personLabel(String label, String name);

  /// No description provided for @requirementTokens.
  ///
  /// In en, this message translates to:
  /// **'{count} Tokens'**
  String requirementTokens(int count);

  /// No description provided for @requirementDailyWins.
  ///
  /// In en, this message translates to:
  /// **'{count} Daily Challenge wins'**
  String requirementDailyWins(int count);

  /// No description provided for @requirementWeeklyWins.
  ///
  /// In en, this message translates to:
  /// **'{count} Weekly Championship wins'**
  String requirementWeeklyWins(int count);

  /// No description provided for @requirementMonthlyWins.
  ///
  /// In en, this message translates to:
  /// **'{count} Monthly Cup wins'**
  String requirementMonthlyWins(int count);

  /// No description provided for @requirementMissions.
  ///
  /// In en, this message translates to:
  /// **'{count} missions completed'**
  String requirementMissions(int count);

  /// No description provided for @noRequirementsSet.
  ///
  /// In en, this message translates to:
  /// **'No requirements set.'**
  String get noRequirementsSet;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @statusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// No description provided for @statusOfferMade.
  ///
  /// In en, this message translates to:
  /// **'Offer Made'**
  String get statusOfferMade;

  /// No description provided for @statusActiveGoal.
  ///
  /// In en, this message translates to:
  /// **'Active Goal'**
  String get statusActiveGoal;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusRedeeming.
  ///
  /// In en, this message translates to:
  /// **'Redeeming'**
  String get statusRedeeming;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @wishlistRequests.
  ///
  /// In en, this message translates to:
  /// **'Wishlist Requests'**
  String get wishlistRequests;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// No description provided for @myGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Accepted Wishlist offers appear here and update as you make progress.'**
  String get myGoalsDescription;

  /// No description provided for @noActiveGoals.
  ///
  /// In en, this message translates to:
  /// **'No active goals'**
  String get noActiveGoals;

  /// No description provided for @noActiveGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Accept a Wishlist offer and your goal will appear here.'**
  String get noActiveGoalsDescription;

  /// No description provided for @redemptionRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Redemption request sent to {name}.'**
  String redemptionRequestSent(String name);

  /// No description provided for @agreedWith.
  ///
  /// In en, this message translates to:
  /// **'Agreed with {name}'**
  String agreedWith(String name);

  /// No description provided for @openedFromNotification.
  ///
  /// In en, this message translates to:
  /// **'Opened from notification'**
  String get openedFromNotification;

  /// No description provided for @allRequirementsCompleted.
  ///
  /// In en, this message translates to:
  /// **'All requirements completed!'**
  String get allRequirementsCompleted;

  /// No description provided for @redeemReward.
  ///
  /// In en, this message translates to:
  /// **'Redeem Reward'**
  String get redeemReward;

  /// No description provided for @waitingForFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other family member to confirm fulfillment.'**
  String get waitingForFulfillment;

  /// No description provided for @rewardCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reward completed.'**
  String get rewardCompleted;

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {required}'**
  String progressCount(int current, int required);

  /// No description provided for @milestonesComplete.
  ///
  /// In en, this message translates to:
  /// **'{complete} of {total} milestones complete'**
  String milestonesComplete(int complete, int total);

  /// No description provided for @goalInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get goalInProgress;

  /// No description provided for @goalReadyToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Ready to redeem'**
  String get goalReadyToRedeem;

  /// No description provided for @goalAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get goalAwaitingConfirmation;

  /// No description provided for @goalFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get goalFulfilled;

  /// No description provided for @couldNotLoadRewardsAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not load your Rewards account.'**
  String get couldNotLoadRewardsAccount;

  /// No description provided for @joinFamilyFirst.
  ///
  /// In en, this message translates to:
  /// **'Join a family first'**
  String get joinFamilyFirst;

  /// No description provided for @joinFamilyRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family to use Wishlist goals and rewards.'**
  String get joinFamilyRewardsDescription;

  /// No description provided for @yourTokens.
  ///
  /// In en, this message translates to:
  /// **'Your Tokens'**
  String get yourTokens;

  /// No description provided for @rewardsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your progress into rewards'**
  String get rewardsIntroTitle;

  /// No description provided for @rewardsIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn Tokens from competitions and family missions, then use them for family experiences or digital unlocks.'**
  String get rewardsIntroDescription;

  /// No description provided for @gameNoValidResult.
  ///
  /// In en, this message translates to:
  /// **'The game finished without a valid player result.'**
  String get gameNoValidResult;

  /// No description provided for @dailyResultMismatch.
  ///
  /// In en, this message translates to:
  /// **'The returned game result does not match today\'s challenge.'**
  String get dailyResultMismatch;

  /// No description provided for @dailyTieRewardPending.
  ///
  /// In en, this message translates to:
  /// **'The top score is tied. No Daily reward has been granted yet.'**
  String get dailyTieRewardPending;

  /// No description provided for @dailyAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Daily Challenge has already been completed.'**
  String get dailyAlreadyCompleted;

  /// No description provided for @dailyWinnerAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'{name} won today\'s Daily Challenge! +{tokens} Tokens and +{points} Ranking Points.'**
  String dailyWinnerAnnouncement(String name, int tokens, int points);

  /// No description provided for @dailyOfficialSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save today\'s official result. Please try again.'**
  String get dailyOfficialSaveError;

  /// No description provided for @weeklySignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to use Weekly Championship.'**
  String get weeklySignInRequired;

  /// No description provided for @weeklyFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before playing Weekly Championship.'**
  String get weeklyFamilyRequired;

  /// No description provided for @weeklyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this week\'s championship. Please try again.'**
  String get weeklyLoadError;

  /// No description provided for @weeklyResultMismatch.
  ///
  /// In en, this message translates to:
  /// **'The returned result does not match this championship round.'**
  String get weeklyResultMismatch;

  /// No description provided for @weeklyRoundSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save this championship round. Please try again.'**
  String get weeklyRoundSaveError;

  /// No description provided for @weeklyWinnerAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'{name} is this week\'s Family Champion! +{tokens} Tokens and +{points} Ranking Points.'**
  String weeklyWinnerAnnouncement(String name, int tokens, int points);

  /// No description provided for @weeklyFinalizeError.
  ///
  /// In en, this message translates to:
  /// **'Could not finalize the Weekly Championship. Please try again.'**
  String get weeklyFinalizeError;

  /// No description provided for @competitionProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} official rounds complete'**
  String competitionProgress(int completed, int total);

  /// No description provided for @backToCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Back to Competitions'**
  String get backToCompetitions;

  /// No description provided for @monthlySignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to use Monthly Cup.'**
  String get monthlySignInRequired;

  /// No description provided for @monthlyFamilyRequired.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before starting Monthly Cup.'**
  String get monthlyFamilyRequired;

  /// No description provided for @monthlyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this month\'s cup. Please try again.'**
  String get monthlyLoadError;

  /// No description provided for @selectExactlyFourMembers.
  ///
  /// In en, this message translates to:
  /// **'Select exactly 4 family members.'**
  String get selectExactlyFourMembers;

  /// No description provided for @monthlyStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start Monthly Cup. Please try again.'**
  String get monthlyStartError;

  /// No description provided for @monthlyResultMismatch.
  ///
  /// In en, this message translates to:
  /// **'The returned result does not match this Monthly Cup match.'**
  String get monthlyResultMismatch;

  /// No description provided for @monthlyMatchSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save this Monthly Cup match. Please try again.'**
  String get monthlyMatchSaveError;

  /// No description provided for @monthlyWinnerAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'{name} won the Monthly Cup! +{tokens} Tokens and +{points} Ranking Points.'**
  String monthlyWinnerAnnouncement(String name, int tokens, int points);

  /// No description provided for @monthlyFinalizeError.
  ///
  /// In en, this message translates to:
  /// **'Could not finalize Monthly Cup. Please try again.'**
  String get monthlyFinalizeError;

  /// No description provided for @competitorsSelected.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} competitors selected'**
  String competitorsSelected(int selected, int total);

  /// No description provided for @finalStandings.
  ///
  /// In en, this message translates to:
  /// **'Final Standings'**
  String get finalStandings;

  /// No description provided for @runnerUp.
  ///
  /// In en, this message translates to:
  /// **'Runner-up'**
  String get runnerUp;

  /// No description provided for @semifinalist.
  ///
  /// In en, this message translates to:
  /// **'Semifinalist'**
  String get semifinalist;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistory;

  /// No description provided for @officialResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'{competition} Results'**
  String officialResultsTitle(String competition);

  /// No description provided for @officialGameResultsReady.
  ///
  /// In en, this message translates to:
  /// **'Official game results are ready. Return to the competition to continue.'**
  String get officialGameResultsReady;

  /// No description provided for @quickPlayLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Quick Play Leaderboard'**
  String get quickPlayLeaderboard;

  /// No description provided for @quickPlayResultsOnly.
  ///
  /// In en, this message translates to:
  /// **'Session scores only — no Tokens or official Ranking Points change.'**
  String get quickPlayResultsOnly;

  /// No description provided for @gameCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{game} Complete!'**
  String gameCompleteTitle(String game);

  /// No description provided for @backToQuickPlay.
  ///
  /// In en, this message translates to:
  /// **'Back to Quick Play'**
  String get backToQuickPlay;

  /// No description provided for @playerWins.
  ///
  /// In en, this message translates to:
  /// **'{name} Wins!'**
  String playerWins(String name);

  /// No description provided for @gameTie.
  ///
  /// In en, this message translates to:
  /// **'It\'s a tie!'**
  String get gameTie;

  /// No description provided for @missionProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} missions completed'**
  String missionProgressSummary(int completed, int total);

  /// No description provided for @captionFinalLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Every vote counted. Here is the final local leaderboard.'**
  String get captionFinalLeaderboard;

  /// No description provided for @monthlyInvalidWinner.
  ///
  /// In en, this message translates to:
  /// **'The match returned a winner who was not one of the two selected competitors. Please replay the match.'**
  String get monthlyInvalidWinner;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
