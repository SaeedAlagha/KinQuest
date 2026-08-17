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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
