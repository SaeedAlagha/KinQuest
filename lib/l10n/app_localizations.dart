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
  /// **'Heritage arches, majlis warmth, and colors of unity'**
  String get uaeFamilyYearThemeDescription;

  /// No description provided for @spaceTheme.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Family'**
  String get spaceTheme;

  /// No description provided for @spaceThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Starlit adventures, glowing orbits, and deep-space wonder'**
  String get spaceThemeDescription;

  /// No description provided for @khalifaUniversityTheme.
  ///
  /// In en, this message translates to:
  /// **'KU Future Lab'**
  String get khalifaUniversityTheme;

  /// No description provided for @khalifaUniversityThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A precise blue innovation system inspired by Khalifa University'**
  String get khalifaUniversityThemeDescription;

  /// No description provided for @desertNightsTheme.
  ///
  /// In en, this message translates to:
  /// **'Desert Nights'**
  String get desertNightsTheme;

  /// No description provided for @desertNightsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Moonlit dunes, copper sunsets, and luxurious night skies'**
  String get desertNightsThemeDescription;

  /// No description provided for @pearlLagoonTheme.
  ///
  /// In en, this message translates to:
  /// **'Pearl Lagoon'**
  String get pearlLagoonTheme;

  /// No description provided for @pearlLagoonThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Luminous pearls, coral accents, and calm Gulf waters'**
  String get pearlLagoonThemeDescription;

  /// No description provided for @themeStudio.
  ///
  /// In en, this message translates to:
  /// **'Theme Studio'**
  String get themeStudio;

  /// No description provided for @themeStudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn Family Tokens together and unlock a look the whole family loves.'**
  String get themeStudioDescription;

  /// No description provided for @themeTokenBalance.
  ///
  /// In en, this message translates to:
  /// **'{tokens} Family Tokens'**
  String themeTokenBalance(int tokens);

  /// No description provided for @themeIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get themeIncluded;

  /// No description provided for @themeOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get themeOwned;

  /// No description provided for @themeTokenPrice.
  ///
  /// In en, this message translates to:
  /// **'{tokens} Tokens'**
  String themeTokenPrice(int tokens);

  /// No description provided for @unlockThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock {theme}?'**
  String unlockThemeTitle(String theme);

  /// No description provided for @unlockThemeMessage.
  ///
  /// In en, this message translates to:
  /// **'Spend {tokens} Family Tokens for a permanent family theme unlock?'**
  String unlockThemeMessage(int tokens);

  /// No description provided for @unlockForTokens.
  ///
  /// In en, this message translates to:
  /// **'Unlock for {tokens}'**
  String unlockForTokens(int tokens);

  /// No description provided for @notEnoughTokensTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep playing together'**
  String get notEnoughTokensTitle;

  /// No description provided for @notEnoughTokensMessage.
  ///
  /// In en, this message translates to:
  /// **'This theme costs {cost} Tokens. Your family currently has {balance}.'**
  String notEnoughTokensMessage(int cost, int balance);

  /// No description provided for @themeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{theme} is now yours!'**
  String themeUnlocked(String theme);

  /// No description provided for @themeUnlockFailed.
  ///
  /// In en, this message translates to:
  /// **'The theme could not be unlocked. Your Tokens were not spent.'**
  String get themeUnlockFailed;

  /// No description provided for @signInToUnlockThemes.
  ///
  /// In en, this message translates to:
  /// **'Sign in and join a family to unlock reward themes.'**
  String get signInToUnlockThemes;

  /// No description provided for @themeUnlockBenefit.
  ///
  /// In en, this message translates to:
  /// **'One-time unlock • Yours across signed-in devices'**
  String get themeUnlockBenefit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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
  /// **'Account email'**
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

  /// No description provided for @navSila.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get navSila;

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

  /// No description provided for @navRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get navRewards;

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

  /// No description provided for @mascotName.
  ///
  /// In en, this message translates to:
  /// **'Sila'**
  String get mascotName;

  /// No description provided for @mascotSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Sila, your family companion'**
  String get mascotSemanticLabel;

  /// No description provided for @silaLogoSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Sila family connection logo'**
  String get silaLogoSemanticLabel;

  /// No description provided for @familyYearSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'UAE Year of Family 2026, Growing in Unity'**
  String get familyYearSemanticLabel;

  /// No description provided for @uaeFlagSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates flag'**
  String get uaeFlagSemanticLabel;

  /// No description provided for @profileFrameEquippedSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile frame equipped'**
  String get profileFrameEquippedSemanticLabel;

  /// No description provided for @mascotWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I’m Sila. I’ll help your family play, create, and grow closer.'**
  String get mascotWelcomeMessage;

  /// No description provided for @mascotHomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Ready for a small family moment together, {name}?'**
  String mascotHomeMessage(String name);

  /// No description provided for @mascotGameSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'I’ll guide everyone. Choose your setup and let’s play!'**
  String get mascotGameSetupMessage;

  /// No description provided for @mascotThinkingMessage.
  ///
  /// In en, this message translates to:
  /// **'I’m preparing something special for your family...'**
  String get mascotThinkingMessage;

  /// No description provided for @mascotOopsMessage.
  ///
  /// In en, this message translates to:
  /// **'That did not work yet. Let’s try again together!'**
  String get mascotOopsMessage;

  /// No description provided for @mascotCelebrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Amazing teamwork! Every moment together makes your bond stronger.'**
  String get mascotCelebrationMessage;

  /// No description provided for @silaMissionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Pick a mission, help each other, and turn a small action into a family win!'**
  String get silaMissionsMessage;

  /// No description provided for @silaStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Sila Studio'**
  String get silaStudioTitle;

  /// No description provided for @silaStudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make your family companion feel uniquely yours.'**
  String get silaStudioSubtitle;

  /// No description provided for @silaStudioTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Sila or choose a reaction to bring him to life.'**
  String get silaStudioTapHint;

  /// No description provided for @silaStudioCloset.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get silaStudioCloset;

  /// No description provided for @silaStudioClosetDescription.
  ///
  /// In en, this message translates to:
  /// **'Try combinations before unlocking them permanently with Family Tokens.'**
  String get silaStudioClosetDescription;

  /// No description provided for @silaStudioHeadwear.
  ///
  /// In en, this message translates to:
  /// **'Headwear'**
  String get silaStudioHeadwear;

  /// No description provided for @silaStudioOutfits.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get silaStudioOutfits;

  /// No description provided for @silaStudioAuras.
  ///
  /// In en, this message translates to:
  /// **'Auras'**
  String get silaStudioAuras;

  /// No description provided for @silaStudioOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get silaStudioOwned;

  /// No description provided for @silaStudioEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get silaStudioEquipped;

  /// No description provided for @silaStudioEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get silaStudioEquip;

  /// No description provided for @silaStudioUnequip.
  ///
  /// In en, this message translates to:
  /// **'Unequip'**
  String get silaStudioUnequip;

  /// No description provided for @silaStudioUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock for {tokens}'**
  String silaStudioUnlock(int tokens);

  /// No description provided for @silaStudioNotEnoughTokens.
  ///
  /// In en, this message translates to:
  /// **'Need {tokens} more Tokens'**
  String silaStudioNotEnoughTokens(int tokens);

  /// No description provided for @silaStudioPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get silaStudioPermanent;

  /// No description provided for @silaStudioTryOn.
  ///
  /// In en, this message translates to:
  /// **'Try on'**
  String get silaStudioTryOn;

  /// No description provided for @silaStudioReactionHover.
  ///
  /// In en, this message translates to:
  /// **'Hover'**
  String get silaStudioReactionHover;

  /// No description provided for @silaStudioReactionReady.
  ///
  /// In en, this message translates to:
  /// **'Game ready'**
  String get silaStudioReactionReady;

  /// No description provided for @silaStudioReactionThink.
  ///
  /// In en, this message translates to:
  /// **'Think'**
  String get silaStudioReactionThink;

  /// No description provided for @silaStudioReactionCelebrate.
  ///
  /// In en, this message translates to:
  /// **'Celebrate'**
  String get silaStudioReactionCelebrate;

  /// No description provided for @silaStudioWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to my studio! Mix a look, test a reaction, and take me into your next game.'**
  String get silaStudioWelcomeMessage;

  /// No description provided for @silaStudioUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sila\'s look is ready everywhere.'**
  String get silaStudioUpdateSuccess;

  /// No description provided for @silaStudioUnlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'Unlocked and equipped! Sila has a new look.'**
  String get silaStudioUnlockSuccess;

  /// No description provided for @silaStudioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Sila\'s closet could not be loaded. Please try again.'**
  String get silaStudioLoadError;

  /// No description provided for @silaGameCoachMessage.
  ///
  /// In en, this message translates to:
  /// **'I’m right here with you—play fair, cheer loudly, and have fun together!'**
  String get silaGameCoachMessage;

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

  /// No description provided for @alreadyInFamily.
  ///
  /// In en, this message translates to:
  /// **'Leave your current family before creating another one.'**
  String get alreadyInFamily;

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

  /// No description provided for @alreadyFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this family.'**
  String get alreadyFamilyMember;

  /// No description provided for @leaveCurrentFamilyFirst.
  ///
  /// In en, this message translates to:
  /// **'Leave your current family before joining another one.'**
  String get leaveCurrentFamilyFirst;

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

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTooltip;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Your personal details'**
  String get personalDetails;

  /// No description provided for @personalDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your name recognizable so your family knows who is playing and contributing.'**
  String get personalDetailsDescription;

  /// No description provided for @emailManagedSecurely.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in email is managed through account security.'**
  String get emailManagedSecurely;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @savingProfile.
  ///
  /// In en, this message translates to:
  /// **'Saving Profile...'**
  String get savingProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile. Please try again.'**
  String get couldNotLoadProfile;

  /// No description provided for @couldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Please try again.'**
  String get couldNotSaveProfile;

  /// No description provided for @developerPreviewReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Developer preview is read-only. No data was changed.'**
  String get developerPreviewReadOnly;

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

  /// No description provided for @couldNotLoadTrophies.
  ///
  /// In en, this message translates to:
  /// **'Could not load family trophies. Please try again.'**
  String get couldNotLoadTrophies;

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

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage Family'**
  String get manageFamily;

  /// No description provided for @familyManagement.
  ///
  /// In en, this message translates to:
  /// **'Family Management'**
  String get familyManagement;

  /// No description provided for @familyManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite relatives, understand roles, and keep your family group organized.'**
  String get familyManagementDescription;

  /// No description provided for @familyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your family. Please try again.'**
  String get familyLoadError;

  /// No description provided for @familyMembersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load family members. Please try again.'**
  String get familyMembersLoadError;

  /// No description provided for @createOrJoinFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Create or Join a Family'**
  String get createOrJoinFamilyAction;

  /// No description provided for @inviteRelatives.
  ///
  /// In en, this message translates to:
  /// **'Invite relatives'**
  String get inviteRelatives;

  /// No description provided for @familyInviteDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this private code only with relatives you want in your family space.'**
  String get familyInviteDescription;

  /// No description provided for @familyMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembersTitle;

  /// No description provided for @familyMembersDescription.
  ///
  /// In en, this message translates to:
  /// **'Roles explain what each person can manage in your family space.'**
  String get familyMembersDescription;

  /// No description provided for @familyRoles.
  ///
  /// In en, this message translates to:
  /// **'Family roles'**
  String get familyRoles;

  /// No description provided for @familyRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get familyRoleOwner;

  /// No description provided for @familyRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Reward Admin'**
  String get familyRoleAdmin;

  /// No description provided for @familyRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get familyRoleMember;

  /// No description provided for @familyOwnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Manages family details, members, roles, and ownership.'**
  String get familyOwnerDescription;

  /// No description provided for @familyAdminDescription.
  ///
  /// In en, this message translates to:
  /// **'Can review and approve family reward requests.'**
  String get familyAdminDescription;

  /// No description provided for @familyMemberDescription.
  ///
  /// In en, this message translates to:
  /// **'Can join family games, missions, memories, and shared activities.'**
  String get familyMemberDescription;

  /// No description provided for @familyMemberYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (You)'**
  String familyMemberYou(String name);

  /// No description provided for @memberActions.
  ///
  /// In en, this message translates to:
  /// **'Member actions'**
  String get memberActions;

  /// No description provided for @editFamily.
  ///
  /// In en, this message translates to:
  /// **'Edit family'**
  String get editFamily;

  /// No description provided for @editFamilyDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Details'**
  String get editFamilyDetails;

  /// No description provided for @saveFamily.
  ///
  /// In en, this message translates to:
  /// **'Save Family'**
  String get saveFamily;

  /// No description provided for @familyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Family details updated.'**
  String get familyUpdated;

  /// No description provided for @couldNotUpdateFamily.
  ///
  /// In en, this message translates to:
  /// **'Could not update the family. Please try again.'**
  String get couldNotUpdateFamily;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Reward Admin'**
  String get makeAdmin;

  /// No description provided for @removeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Reward Admin'**
  String get removeAdmin;

  /// No description provided for @adminRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Family role updated.'**
  String get adminRoleUpdated;

  /// No description provided for @couldNotUpdateAdminRole.
  ///
  /// In en, this message translates to:
  /// **'Could not update this family role. Please try again.'**
  String get couldNotUpdateAdminRole;

  /// No description provided for @transferOwnership.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership'**
  String get transferOwnership;

  /// No description provided for @transferOwnershipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Make {name} the owner?'**
  String transferOwnershipQuestion(String name);

  /// No description provided for @transferOwnershipWarning.
  ///
  /// In en, this message translates to:
  /// **'They will receive full family controls and you will become a regular member. This can be changed again by the new owner.'**
  String get transferOwnershipWarning;

  /// No description provided for @ownershipTransferred.
  ///
  /// In en, this message translates to:
  /// **'Family ownership transferred.'**
  String get ownershipTransferred;

  /// No description provided for @couldNotTransferOwnership.
  ///
  /// In en, this message translates to:
  /// **'Could not transfer ownership. Please try again.'**
  String get couldNotTransferOwnership;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberQuestion(String name);

  /// No description provided for @removeMemberWarning.
  ///
  /// In en, this message translates to:
  /// **'They will lose access to this family\'s private content and can join or create another family.'**
  String get removeMemberWarning;

  /// No description provided for @familyMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Family member removed.'**
  String get familyMemberRemoved;

  /// No description provided for @couldNotRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Could not remove this family member. Please try again.'**
  String get couldNotRemoveMember;

  /// No description provided for @leaveFamily.
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get leaveFamily;

  /// No description provided for @leaveFamilyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave this family?'**
  String get leaveFamilyQuestion;

  /// No description provided for @leaveFamilyWarning.
  ///
  /// In en, this message translates to:
  /// **'You will lose access to this family\'s private content. You can join again later with an invitation code.'**
  String get leaveFamilyWarning;

  /// No description provided for @leftFamilySuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You left the family.'**
  String get leftFamilySuccessfully;

  /// No description provided for @couldNotLeaveFamily.
  ///
  /// In en, this message translates to:
  /// **'Could not leave the family. Please try again.'**
  String get couldNotLeaveFamily;

  /// No description provided for @transferBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'Transfer Ownership to Leave'**
  String get transferBeforeLeaving;

  /// No description provided for @ownerCannotLeave.
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership first'**
  String get ownerCannotLeave;

  /// No description provided for @ownerCannotLeaveDescription.
  ///
  /// In en, this message translates to:
  /// **'The owner protects the family space. Transfer ownership to another member before leaving. If you are the only member, invite a trusted relative first.'**
  String get ownerCannotLeaveDescription;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @developerFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'A warm private space for playing, sharing, and growing together.'**
  String get developerFamilyDescription;

  /// No description provided for @developerFamilyMemberName.
  ///
  /// In en, this message translates to:
  /// **'Mariam'**
  String get developerFamilyMemberName;

  /// No description provided for @developerFamilyMemberTwoName.
  ///
  /// In en, this message translates to:
  /// **'Omar'**
  String get developerFamilyMemberTwoName;

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

  /// No description provided for @couldNotLoadWishlist.
  ///
  /// In en, this message translates to:
  /// **'Could not load Wishlist requests.'**
  String get couldNotLoadWishlist;

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

  /// No description provided for @couldNotLoadGoals.
  ///
  /// In en, this message translates to:
  /// **'Could not load your goals.'**
  String get couldNotLoadGoals;

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

  /// No description provided for @minimumPlayersForGame.
  ///
  /// In en, this message translates to:
  /// **'{game} needs at least {count} players.'**
  String minimumPlayersForGame(String game, int count);

  /// No description provided for @minimumFamilyMembersForGame.
  ///
  /// In en, this message translates to:
  /// **'{game} needs at least {count} family members.'**
  String minimumFamilyMembersForGame(String game, int count);

  /// No description provided for @joinOrCreateFamilyBeforeGame.
  ///
  /// In en, this message translates to:
  /// **'Join or create a family before playing {game}.'**
  String joinOrCreateFamilyBeforeGame(String game);

  /// No description provided for @couldNotStartGame.
  ///
  /// In en, this message translates to:
  /// **'Could not start {game}. Please try again.'**
  String couldNotStartGame(String game);

  /// No description provided for @preparingGame.
  ///
  /// In en, this message translates to:
  /// **'Preparing game...'**
  String get preparingGame;

  /// No description provided for @selectedPlayersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player selected} other{{count} players selected}}'**
  String selectedPlayersCount(int count);

  /// No description provided for @everyoneElseLookAway.
  ///
  /// In en, this message translates to:
  /// **'Everyone else should look away.'**
  String get everyoneElseLookAway;

  /// No description provided for @iAmPlayer.
  ///
  /// In en, this message translates to:
  /// **'I\'m {name}'**
  String iAmPlayer(String name);

  /// No description provided for @roundNumber.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(int number);

  /// No description provided for @viewFinalLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'View Final Leaderboard'**
  String get viewFinalLeaderboard;

  /// No description provided for @impostorSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your mystery'**
  String get impostorSetupTitle;

  /// No description provided for @impostorSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick one category for every secret word, or keep everyone guessing with a random mix.'**
  String get impostorSetupDescription;

  /// No description provided for @chooseAtLeastThreePlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose at least 3 family members who are together with you.'**
  String get chooseAtLeastThreePlayers;

  /// No description provided for @randomMix.
  ///
  /// In en, this message translates to:
  /// **'Random mix'**
  String get randomMix;

  /// No description provided for @randomMixDescription.
  ///
  /// In en, this message translates to:
  /// **'Every round can surprise you with a different category.'**
  String get randomMixDescription;

  /// No description provided for @selectedCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'All secret words will come from {category}.'**
  String selectedCategoryDescription(String category);

  /// No description provided for @youAreTheImpostor.
  ///
  /// In en, this message translates to:
  /// **'You are the IMPOSTOR'**
  String get youAreTheImpostor;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String categoryLabel(String category);

  /// No description provided for @impostorRoleInstructions.
  ///
  /// In en, this message translates to:
  /// **'You do not know the secret word.\nBlend in and avoid getting caught.'**
  String get impostorRoleInstructions;

  /// No description provided for @secretWord.
  ///
  /// In en, this message translates to:
  /// **'Secret word'**
  String get secretWord;

  /// No description provided for @rememberSecretWord.
  ///
  /// In en, this message translates to:
  /// **'Remember it. Do not show anyone else.'**
  String get rememberSecretWord;

  /// No description provided for @hideMyRole.
  ///
  /// In en, this message translates to:
  /// **'Hide My Role'**
  String get hideMyRole;

  /// No description provided for @clueRoundNumber.
  ///
  /// In en, this message translates to:
  /// **'Clue Round {number}'**
  String clueRoundNumber(int number);

  /// No description provided for @takeTurnsGivingClues.
  ///
  /// In en, this message translates to:
  /// **'Take turns giving one clue aloud.'**
  String get takeTurnsGivingClues;

  /// No description provided for @clueRules.
  ///
  /// In en, this message translates to:
  /// **'Do not say the secret word.\nDo not make your clue too obvious.'**
  String get clueRules;

  /// No description provided for @impostorBluffInstructions.
  ///
  /// In en, this message translates to:
  /// **'The Impostor must bluff and try to blend in.'**
  String get impostorBluffInstructions;

  /// No description provided for @everyoneGaveClue.
  ///
  /// In en, this message translates to:
  /// **'Everyone Gave a Clue'**
  String get everyoneGaveClue;

  /// No description provided for @knowTheImpostorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you know who the Impostor is?'**
  String get knowTheImpostorQuestion;

  /// No description provided for @clueRoundComplete.
  ///
  /// In en, this message translates to:
  /// **'Clue round {number} is complete.'**
  String clueRoundComplete(int number);

  /// No description provided for @anotherClueRound.
  ///
  /// In en, this message translates to:
  /// **'Another Clue Round'**
  String get anotherClueRound;

  /// No description provided for @startVoting.
  ///
  /// In en, this message translates to:
  /// **'Start Voting'**
  String get startVoting;

  /// No description provided for @privateVoteInstructions.
  ///
  /// In en, this message translates to:
  /// **'Your vote is private. Everyone else should look away.'**
  String get privateVoteInstructions;

  /// No description provided for @whoIsTheImpostor.
  ///
  /// In en, this message translates to:
  /// **'{name}, who is the Impostor?'**
  String whoIsTheImpostor(String name);

  /// No description provided for @votingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Choose one family member. You cannot vote for yourself.'**
  String get votingInstructions;

  /// No description provided for @voteResults.
  ///
  /// In en, this message translates to:
  /// **'Vote Results'**
  String get voteResults;

  /// No description provided for @voteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote} other{{count} votes}}'**
  String voteCount(int count);

  /// No description provided for @tieVoteAgain.
  ///
  /// In en, this message translates to:
  /// **'Tie — Vote Again'**
  String get tieVoteAgain;

  /// No description provided for @revealPlayer.
  ///
  /// In en, this message translates to:
  /// **'Reveal {name}'**
  String revealPlayer(String name);

  /// No description provided for @innocentImpostorEscaped.
  ///
  /// In en, this message translates to:
  /// **'{innocent} was innocent!\n\n{impostor} was the Impostor and escaped detection.'**
  String innocentImpostorEscaped(String innocent, String impostor);

  /// No description provided for @impostorWasCaught.
  ///
  /// In en, this message translates to:
  /// **'The Impostor Was Caught!'**
  String get impostorWasCaught;

  /// No description provided for @playerIsImpostor.
  ///
  /// In en, this message translates to:
  /// **'{name} is the Impostor.'**
  String playerIsImpostor(String name);

  /// No description provided for @impostorFinalChance.
  ///
  /// In en, this message translates to:
  /// **'You have one final chance.\nGuess the secret word to steal the round.'**
  String get impostorFinalChance;

  /// No description provided for @submitGuess.
  ///
  /// In en, this message translates to:
  /// **'Submit Guess'**
  String get submitGuess;

  /// No description provided for @enterGuessFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your guess first.'**
  String get enterGuessFirst;

  /// No description provided for @caughtButGuessedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'{name} was caught, but guessed “{word}” correctly and stole the round!'**
  String caughtButGuessedCorrectly(String name, String word);

  /// No description provided for @incorrectImpostorGuess.
  ///
  /// In en, this message translates to:
  /// **'{name} guessed “{guess}”.\n\nThe secret word was “{word}”.\n\nThe family wins this round!'**
  String incorrectImpostorGuess(String name, String guess, String word);

  /// No description provided for @impostorWins.
  ///
  /// In en, this message translates to:
  /// **'Impostor Wins!'**
  String get impostorWins;

  /// No description provided for @familyWins.
  ///
  /// In en, this message translates to:
  /// **'Family Wins!'**
  String get familyWins;

  /// No description provided for @secretWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret word: {word}'**
  String secretWordLabel(String word);

  /// No description provided for @drawingTurnEachRound.
  ///
  /// In en, this message translates to:
  /// **'Every selected artist gets one drawing turn in each round.'**
  String get drawingTurnEachRound;

  /// No description provided for @artistDrawingPrompt.
  ///
  /// In en, this message translates to:
  /// **'{name}, your drawing prompt is:'**
  String artistDrawingPrompt(String name);

  /// No description provided for @rememberDrawingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remember the prompt. Do not show it to the other players.'**
  String get rememberDrawingPrompt;

  /// No description provided for @startDrawing.
  ///
  /// In en, this message translates to:
  /// **'Start Drawing'**
  String get startDrawing;

  /// No description provided for @drawingTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!\n\nNobody guessed the drawing this round.'**
  String get drawingTimeUp;

  /// No description provided for @playerIsDrawing.
  ///
  /// In en, this message translates to:
  /// **'{name} is drawing'**
  String playerIsDrawing(String name);

  /// No description provided for @guessAloud.
  ///
  /// In en, this message translates to:
  /// **'Everyone else: guess aloud!'**
  String get guessAloud;

  /// No description provided for @brush.
  ///
  /// In en, this message translates to:
  /// **'Brush:'**
  String get brush;

  /// No description provided for @thin.
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get thin;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @thick.
  ///
  /// In en, this message translates to:
  /// **'Thick'**
  String get thick;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraser;

  /// No description provided for @eraserOn.
  ///
  /// In en, this message translates to:
  /// **'Eraser On'**
  String get eraserOn;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @someoneGuessedIt.
  ///
  /// In en, this message translates to:
  /// **'Someone Guessed It'**
  String get someoneGuessedIt;

  /// No description provided for @whoGuessedIt.
  ///
  /// In en, this message translates to:
  /// **'Who guessed it?'**
  String get whoGuessedIt;

  /// No description provided for @chooseCorrectGuesser.
  ///
  /// In en, this message translates to:
  /// **'Choose the family member who guessed the drawing correctly.'**
  String get chooseCorrectGuesser;

  /// No description provided for @drawingCorrectPoints.
  ///
  /// In en, this message translates to:
  /// **'{guesser} guessed correctly!\n\n{artist} +1 point\n{guesser} +1 point'**
  String drawingCorrectPoints(String guesser, String artist);

  /// No description provided for @promptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt: {prompt}'**
  String promptLabel(String prompt);

  /// No description provided for @nextArtist.
  ///
  /// In en, this message translates to:
  /// **'Next Artist'**
  String get nextArtist;

  /// No description provided for @officialMatchInvalidPlayers.
  ///
  /// In en, this message translates to:
  /// **'This official {game} match does not have enough valid family members.'**
  String officialMatchInvalidPlayers(String game);

  /// No description provided for @timePerTurn.
  ///
  /// In en, this message translates to:
  /// **'Time per turn'**
  String get timePerTurn;

  /// No description provided for @playerSecretWord.
  ///
  /// In en, this message translates to:
  /// **'{name}, your word is:'**
  String playerSecretWord(String name);

  /// No description provided for @dontSayHeading.
  ///
  /// In en, this message translates to:
  /// **'DON\'T SAY:'**
  String get dontSayHeading;

  /// No description provided for @rememberWordCard.
  ///
  /// In en, this message translates to:
  /// **'Remember the card. Don\'t let anyone else see it.'**
  String get rememberWordCard;

  /// No description provided for @startTurn.
  ///
  /// In en, this message translates to:
  /// **'Start Turn'**
  String get startTurn;

  /// No description provided for @turnTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! No points this turn.'**
  String get turnTimeUp;

  /// No description provided for @playerIsDescribing.
  ///
  /// In en, this message translates to:
  /// **'{name} is describing'**
  String playerIsDescribing(String name);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @turnSkipped.
  ///
  /// In en, this message translates to:
  /// **'Turn skipped. No points awarded.'**
  String get turnSkipped;

  /// No description provided for @chooseSecretWordGuesser.
  ///
  /// In en, this message translates to:
  /// **'Choose the player who guessed the secret word correctly.'**
  String get chooseSecretWordGuesser;

  /// No description provided for @clueGiverPointResult.
  ///
  /// In en, this message translates to:
  /// **'{guesser} guessed correctly!\n\n{clueGiver} +1 point'**
  String clueGiverPointResult(String guesser, String clueGiver);

  /// No description provided for @sharedPointResult.
  ///
  /// In en, this message translates to:
  /// **'{guesser} guessed correctly!\n\n{clueGiver} +1 point\n{guesser} +1 point'**
  String sharedPointResult(String guesser, String clueGiver);

  /// No description provided for @turnComplete.
  ///
  /// In en, this message translates to:
  /// **'Turn Complete'**
  String get turnComplete;

  /// No description provided for @answerAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'That answer was already used this round! Try another one.'**
  String get answerAlreadyUsed;

  /// No description provided for @answerDoesNotFitCategory.
  ///
  /// In en, this message translates to:
  /// **'That does not fit the category. Try again!'**
  String get answerDoesNotFitCategory;

  /// No description provided for @reasonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'{reason} Try again!'**
  String reasonTryAgain(String reason);

  /// No description provided for @couldNotCheckAnswer.
  ///
  /// In en, this message translates to:
  /// **'Could not check that answer. Please try again.'**
  String get couldNotCheckAnswer;

  /// No description provided for @chooseTogetherPlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose the family members who are together with you. Everyone will share this phone.'**
  String get chooseTogetherPlayers;

  /// No description provided for @bombSetupInstructions.
  ///
  /// In en, this message translates to:
  /// **'Answer quickly, pass the phone, and do not repeat an answer.'**
  String get bombSetupInstructions;

  /// No description provided for @generatingCategories.
  ///
  /// In en, this message translates to:
  /// **'Generating categories...'**
  String get generatingCategories;

  /// No description provided for @playerTurn.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn'**
  String playerTurn(String name);

  /// No description provided for @sayTypePass.
  ///
  /// In en, this message translates to:
  /// **'Say your answer aloud, type it below, then immediately pass the phone.'**
  String get sayTypePass;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @checkingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Checking answer...'**
  String get checkingAnswer;

  /// No description provided for @typeSpokenAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type the answer you just said'**
  String get typeSpokenAnswer;

  /// No description provided for @submitAndPassPhone.
  ///
  /// In en, this message translates to:
  /// **'Submit & Pass Phone'**
  String get submitAndPassPhone;

  /// No description provided for @bombHiddenTimer.
  ///
  /// In en, this message translates to:
  /// **'The bomb can explode at any moment. The timer is hidden!'**
  String get bombHiddenTimer;

  /// No description provided for @answersUsedThisRound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No answers used this round} =1{1 answer used this round} other{{count} answers used this round}}'**
  String answersUsedThisRound(int count);

  /// No description provided for @boom.
  ///
  /// In en, this message translates to:
  /// **'BOOM!'**
  String get boom;

  /// No description provided for @playerHeldBomb.
  ///
  /// In en, this message translates to:
  /// **'{name} was holding the bomb!'**
  String playerHeldBomb(String name);

  /// No description provided for @bombSurvivorPoint.
  ///
  /// In en, this message translates to:
  /// **'Everyone else earns 1 point for surviving the round.'**
  String get bombSurvivorPoint;

  /// No description provided for @choosePlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose Players'**
  String get choosePlayers;

  /// No description provided for @chooseQuickPlayMembers.
  ///
  /// In en, this message translates to:
  /// **'Choose the family members who are together for this Quick Play session.'**
  String get chooseQuickPlayMembers;

  /// No description provided for @chooseGame.
  ///
  /// In en, this message translates to:
  /// **'Choose Game'**
  String get chooseGame;

  /// No description provided for @memoryChallenge.
  ///
  /// In en, this message translates to:
  /// **'Memory Challenge'**
  String get memoryChallenge;

  /// No description provided for @memoryNeedsPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your family needs at least one memory with a photo before playing.'**
  String get memoryNeedsPhoto;

  /// No description provided for @memoryChallengeCreateError.
  ///
  /// In en, this message translates to:
  /// **'We could not create a Memory Challenge right now. Please try again.'**
  String get memoryChallengeCreateError;

  /// No description provided for @familyMemoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Family Memory'**
  String get familyMemoryFallback;

  /// No description provided for @howWellRemember.
  ///
  /// In en, this message translates to:
  /// **'How well do you remember?'**
  String get howWellRemember;

  /// No description provided for @memoryChallengeSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Sila uses your family photos and stories to create unique questions from moments you shared together.'**
  String get memoryChallengeSetupDescription;

  /// No description provided for @creatingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Creating your challenge...'**
  String get creatingChallenge;

  /// No description provided for @startMemoryChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start Memory Challenge'**
  String get startMemoryChallenge;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswerLabel(String answer);

  /// No description provided for @nextMemory.
  ///
  /// In en, this message translates to:
  /// **'Next Memory'**
  String get nextMemory;

  /// No description provided for @memoryChallengeComplete.
  ///
  /// In en, this message translates to:
  /// **'Memory Challenge Complete!'**
  String get memoryChallengeComplete;

  /// No description provided for @scoreProgress.
  ///
  /// In en, this message translates to:
  /// **'Score: {score} / {total}'**
  String scoreProgress(int score, int total);

  /// No description provided for @couldNotLoadCaptionBattle.
  ///
  /// In en, this message translates to:
  /// **'Could not load Caption Battle'**
  String get couldNotLoadCaptionBattle;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @captionBattleSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyone captions the same family photo. Then the captions are shuffled and the family votes anonymously.'**
  String get captionBattleSetupDescription;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @captionRulePhoto.
  ///
  /// In en, this message translates to:
  /// **'A real family Memory photo appears each round.'**
  String get captionRulePhoto;

  /// No description provided for @captionRuleWrite.
  ///
  /// In en, this message translates to:
  /// **'Each player secretly writes one caption.'**
  String get captionRuleWrite;

  /// No description provided for @captionRuleShuffle.
  ///
  /// In en, this message translates to:
  /// **'Captions are shuffled so authors stay hidden.'**
  String get captionRuleShuffle;

  /// No description provided for @captionRuleVote.
  ///
  /// In en, this message translates to:
  /// **'Everyone votes, but cannot vote for themselves.'**
  String get captionRuleVote;

  /// No description provided for @captionRulePoint.
  ///
  /// In en, this message translates to:
  /// **'Each vote is worth 1 local Quick Play point.'**
  String get captionRulePoint;

  /// No description provided for @promptVariety.
  ///
  /// In en, this message translates to:
  /// **'Prompt variety'**
  String get promptVariety;

  /// No description provided for @promptVarietyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the kind of creative challenge your family wants.'**
  String get promptVarietyDescription;

  /// No description provided for @captionStyleSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise Me'**
  String get captionStyleSurprise;

  /// No description provided for @captionStyleStorytelling.
  ///
  /// In en, this message translates to:
  /// **'Storytelling'**
  String get captionStyleStorytelling;

  /// No description provided for @captionStyleHeadlines.
  ///
  /// In en, this message translates to:
  /// **'Headlines & Posts'**
  String get captionStyleHeadlines;

  /// No description provided for @captionStyleWild.
  ///
  /// In en, this message translates to:
  /// **'Wild Ideas'**
  String get captionStyleWild;

  /// No description provided for @familyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Family photos'**
  String get familyPhotos;

  /// No description provided for @noPhotoMemories.
  ///
  /// In en, this message translates to:
  /// **'No Memories with photos were found.'**
  String get noPhotoMemories;

  /// No description provided for @photoMemoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo memory available.} other{{count} photo memories available.}}'**
  String photoMemoriesAvailable(int count);

  /// No description provided for @addPhotoMemoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a Memory with a photo first, then return here.'**
  String get addPhotoMemoryFirst;

  /// No description provided for @captionBattleRoundCount.
  ///
  /// In en, this message translates to:
  /// **'This game will play {count, plural, =1{1 round.} other{{count} rounds.}}'**
  String captionBattleRoundCount(int count);

  /// No description provided for @captionRoundPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Each round uses a different family photo. More photos unlock the 3 and 5-round options.'**
  String get captionRoundPhotoDescription;

  /// No description provided for @selectAtLeastTwoFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Select at least 2 family members.'**
  String get selectAtLeastTwoFamilyMembers;

  /// No description provided for @captionBattleNeedsPhoto.
  ///
  /// In en, this message translates to:
  /// **'Caption Battle needs at least one Memory with a photo.'**
  String get captionBattleNeedsPhoto;

  /// No description provided for @quickPlayNoRanking.
  ///
  /// In en, this message translates to:
  /// **'Quick Play only • No Tokens or global ranking'**
  String get quickPlayNoRanking;

  /// No description provided for @takeThePhone.
  ///
  /// In en, this message translates to:
  /// **'{name}, take the phone'**
  String takeThePhone(String name);

  /// No description provided for @keepCaptionPrivate.
  ///
  /// In en, this message translates to:
  /// **'Make sure nobody else can see your caption.'**
  String get keepCaptionPrivate;

  /// No description provided for @imReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m Ready'**
  String get imReady;

  /// No description provided for @yourChallenge.
  ///
  /// In en, this message translates to:
  /// **'Your challenge'**
  String get yourChallenge;

  /// No description provided for @writeYourCaption.
  ///
  /// In en, this message translates to:
  /// **'Write your caption'**
  String get writeYourCaption;

  /// No description provided for @writeCaptionFirst.
  ///
  /// In en, this message translates to:
  /// **'Write a caption before continuing.'**
  String get writeCaptionFirst;

  /// No description provided for @submitFinalCaption.
  ///
  /// In en, this message translates to:
  /// **'Submit Final Caption'**
  String get submitFinalCaption;

  /// No description provided for @privateCaptionVote.
  ///
  /// In en, this message translates to:
  /// **'Vote privately for your favorite caption. You will not be able to vote for your own.'**
  String get privateCaptionVote;

  /// No description provided for @showCaptions.
  ///
  /// In en, this message translates to:
  /// **'Show Captions'**
  String get showCaptions;

  /// No description provided for @chooseFavoriteCaption.
  ///
  /// In en, this message translates to:
  /// **'{name}, choose your favorite'**
  String chooseFavoriteCaption(String name);

  /// No description provided for @captionAuthorsHidden.
  ///
  /// In en, this message translates to:
  /// **'Authors stay hidden until everyone votes.'**
  String get captionAuthorsHidden;

  /// No description provided for @cannotVoteOwnCaption.
  ///
  /// In en, this message translates to:
  /// **'You cannot vote for your own caption.'**
  String get cannotVoteOwnCaption;

  /// No description provided for @captionReveal.
  ///
  /// In en, this message translates to:
  /// **'Caption reveal'**
  String get captionReveal;

  /// No description provided for @finalLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Final Leaderboard'**
  String get finalLeaderboard;

  /// No description provided for @developerFamilyMemory.
  ///
  /// In en, this message translates to:
  /// **'Developer Family Memory {number}'**
  String developerFamilyMemory(int number);

  /// No description provided for @subjectPrivateAnswer.
  ///
  /// In en, this message translates to:
  /// **'Everyone else should look away while {name} chooses a private answer.'**
  String subjectPrivateAnswer(String name);

  /// No description provided for @guesserPrivateGuess.
  ///
  /// In en, this message translates to:
  /// **'{guesser} will privately guess what {subject} chose.'**
  String guesserPrivateGuess(String guesser, String subject);

  /// No description provided for @votesArePrivate.
  ///
  /// In en, this message translates to:
  /// **'Votes are private. Everyone else should look away.'**
  String get votesArePrivate;

  /// No description provided for @chooseRealAnswer.
  ///
  /// In en, this message translates to:
  /// **'{name}, choose your real answer'**
  String chooseRealAnswer(String name);

  /// No description provided for @predictTheirChoice.
  ///
  /// In en, this message translates to:
  /// **'Everyone else will try to predict what you chose.'**
  String get predictTheirChoice;

  /// No description provided for @whatDidPlayerChoose.
  ///
  /// In en, this message translates to:
  /// **'What did {name} choose?'**
  String whatDidPlayerChoose(String name);

  /// No description provided for @makePrivateGuess.
  ///
  /// In en, this message translates to:
  /// **'{name}, make your private guess.'**
  String makePrivateGuess(String name);

  /// No description provided for @playerChose.
  ///
  /// In en, this message translates to:
  /// **'{name} chose:'**
  String playerChose(String name);

  /// No description provided for @nobodyGuessedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Nobody guessed correctly!'**
  String get nobodyGuessedCorrectly;

  /// No description provided for @playersGuessedCorrectly.
  ///
  /// In en, this message translates to:
  /// **'{names} guessed correctly!'**
  String playersGuessedCorrectly(String names);

  /// No description provided for @onePointEach.
  ///
  /// In en, this message translates to:
  /// **'+1 point each'**
  String get onePointEach;

  /// No description provided for @choosePrivately.
  ///
  /// In en, this message translates to:
  /// **'{name}, choose privately.'**
  String choosePrivately(String name);

  /// No description provided for @submitPrivateVote.
  ///
  /// In en, this message translates to:
  /// **'Submit Private Vote'**
  String get submitPrivateVote;

  /// No description provided for @playerReceivedMostVotes.
  ///
  /// In en, this message translates to:
  /// **'{name} received the most votes!'**
  String playerReceivedMostVotes(String name);

  /// No description provided for @nextVote.
  ///
  /// In en, this message translates to:
  /// **'Next Vote'**
  String get nextVote;

  /// No description provided for @couldNotGenerateMissions.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare Secret Missions. Please try again in a moment.'**
  String get couldNotGenerateMissions;

  /// No description provided for @couldNotGenerateNextRound.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the next round. Please try again.'**
  String get couldNotGenerateNextRound;

  /// No description provided for @missionTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up! Time to reveal and judge the missions.'**
  String get missionTimeUp;

  /// No description provided for @finishRoundEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish round early?'**
  String get finishRoundEarlyTitle;

  /// No description provided for @finishRoundEarlyDescription.
  ///
  /// In en, this message translates to:
  /// **'The timer will stop and everyone will move to mission judging.'**
  String get finishRoundEarlyDescription;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep Playing'**
  String get keepPlaying;

  /// No description provided for @finishRound.
  ///
  /// In en, this message translates to:
  /// **'Finish Round'**
  String get finishRound;

  /// No description provided for @chooseMissionPlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose the family members playing together on this phone.'**
  String get chooseMissionPlayers;

  /// No description provided for @secretMissionSetupSummary.
  ///
  /// In en, this message translates to:
  /// **'{rounds, plural, =1{1 round} other{{rounds} rounds}} • 10 minutes per round • 1 secret mission per player each round.'**
  String secretMissionSetupSummary(int rounds);

  /// No description provided for @secretMissionSetupInstructions.
  ///
  /// In en, this message translates to:
  /// **'Complete your mission naturally without letting the others figure it out.'**
  String get secretMissionSetupInstructions;

  /// No description provided for @generatingRound.
  ///
  /// In en, this message translates to:
  /// **'Generating Round {number}...'**
  String generatingRound(int number);

  /// No description provided for @playerProgress.
  ///
  /// In en, this message translates to:
  /// **'Player {current} of {total}'**
  String playerProgress(int current, int total);

  /// No description provided for @keepScreenPrivate.
  ///
  /// In en, this message translates to:
  /// **'Make sure nobody else can see the screen.'**
  String get keepScreenPrivate;

  /// No description provided for @revealMyMission.
  ///
  /// In en, this message translates to:
  /// **'Reveal My Mission'**
  String get revealMyMission;

  /// No description provided for @yourSecretMission.
  ///
  /// In en, this message translates to:
  /// **'YOUR SECRET MISSION'**
  String get yourSecretMission;

  /// No description provided for @rememberMission.
  ///
  /// In en, this message translates to:
  /// **'Remember it. Do not tell anyone.'**
  String get rememberMission;

  /// No description provided for @hideMissionStartRound.
  ///
  /// In en, this message translates to:
  /// **'Hide Mission & Start 10-Minute Round'**
  String get hideMissionStartRound;

  /// No description provided for @hideMissionPassPhone.
  ///
  /// In en, this message translates to:
  /// **'Hide Mission & Pass Phone'**
  String get hideMissionPassPhone;

  /// No description provided for @missionsAreLive.
  ///
  /// In en, this message translates to:
  /// **'Missions are live!'**
  String get missionsAreLive;

  /// No description provided for @missionsLiveInstructions.
  ///
  /// In en, this message translates to:
  /// **'Put the phone down and act naturally. Complete your mission without making it obvious.'**
  String get missionsLiveInstructions;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'TIME REMAINING'**
  String get timeRemaining;

  /// No description provided for @missionAutoJudge.
  ///
  /// In en, this message translates to:
  /// **'The round will automatically move to judging when the timer reaches 00:00.'**
  String get missionAutoJudge;

  /// No description provided for @finishRoundEarly.
  ///
  /// In en, this message translates to:
  /// **'Finish Round Early'**
  String get finishRoundEarly;

  /// No description provided for @judgeProgress.
  ///
  /// In en, this message translates to:
  /// **'Judge {current} of {total}'**
  String judgeProgress(int current, int total);

  /// No description provided for @missionCompletedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did they successfully complete the mission during this round?'**
  String get missionCompletedQuestion;

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not Completed'**
  String get notCompleted;

  /// No description provided for @completedPlusOne.
  ///
  /// In en, this message translates to:
  /// **'Completed +1'**
  String get completedPlusOne;

  /// No description provided for @roundsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No rounds remaining} =1{1 round remaining} other{{count} rounds remaining}}'**
  String roundsRemaining(int count);

  /// No description provided for @missionCompletedThisRound.
  ///
  /// In en, this message translates to:
  /// **'Mission completed this round'**
  String get missionCompletedThisRound;

  /// No description provided for @missionNotCompletedThisRound.
  ///
  /// In en, this message translates to:
  /// **'Mission not completed this round'**
  String get missionNotCompletedThisRound;

  /// No description provided for @previewPlayer.
  ///
  /// In en, this message translates to:
  /// **'Preview Player'**
  String get previewPlayer;

  /// No description provided for @monthlyInvalidWinner.
  ///
  /// In en, this message translates to:
  /// **'The match returned a winner who was not one of the two selected competitors. Please replay the match.'**
  String get monthlyInvalidWinner;

  /// No description provided for @myDigitalRewards.
  ///
  /// In en, this message translates to:
  /// **'My Digital Rewards'**
  String get myDigitalRewards;

  /// No description provided for @tokenHistory.
  ///
  /// In en, this message translates to:
  /// **'Token History'**
  String get tokenHistory;

  /// No description provided for @unlockRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock reward?'**
  String get unlockRewardTitle;

  /// No description provided for @unlockRewardMessage.
  ///
  /// In en, this message translates to:
  /// **'Spend {cost} Tokens to permanently unlock \"{reward}\"?'**
  String unlockRewardMessage(int cost, String reward);

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @rewardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{reward} unlocked!'**
  String rewardUnlocked(String reward);

  /// No description provided for @rewardEquippedOnSila.
  ///
  /// In en, this message translates to:
  /// **'{reward} equipped across Sila.'**
  String rewardEquippedOnSila(String reward);

  /// No description provided for @rewardUnequipped.
  ///
  /// In en, this message translates to:
  /// **'{reward} unequipped.'**
  String rewardUnequipped(String reward);

  /// No description provided for @collectionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your collection could not be loaded'**
  String get collectionLoadFailed;

  /// No description provided for @restartAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app and try again.'**
  String get restartAndTryAgain;

  /// No description provided for @checkConnectionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkConnectionTryAgain;

  /// No description provided for @noDigitalRewards.
  ///
  /// In en, this message translates to:
  /// **'No digital rewards yet'**
  String get noDigitalRewards;

  /// No description provided for @noDigitalRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock cosmetics from Rewards and they will appear here.'**
  String get noDigitalRewardsDescription;

  /// No description provided for @yourSilaStyle.
  ///
  /// In en, this message translates to:
  /// **'Your Sila style'**
  String get yourSilaStyle;

  /// No description provided for @silaStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Equip one reward from each category. Changes appear everywhere immediately.'**
  String get silaStyleDescription;

  /// No description provided for @legacyRewardsSafe.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 legacy reward kept safe} other{{count} legacy rewards kept safe}}'**
  String legacyRewardsSafe(int count);

  /// No description provided for @legacyRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'These purchases remain owned but are no longer in the active catalog.'**
  String get legacyRewardsDescription;

  /// No description provided for @currentlyEquipped.
  ///
  /// In en, this message translates to:
  /// **'Currently equipped'**
  String get currentlyEquipped;

  /// No description provided for @ownedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Owned permanently'**
  String get ownedPermanently;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updating;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get equip;

  /// No description provided for @unequip.
  ///
  /// In en, this message translates to:
  /// **'Unequip'**
  String get unequip;

  /// No description provided for @digitalRewards.
  ///
  /// In en, this message translates to:
  /// **'Digital Rewards'**
  String get digitalRewards;

  /// No description provided for @digitalRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock permanent Sila cosmetics instantly. No approval needed.'**
  String get digitalRewardsDescription;

  /// No description provided for @digitalRewardsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Digital Rewards could not be loaded'**
  String get digitalRewardsLoadFailed;

  /// No description provided for @profileFrames.
  ///
  /// In en, this message translates to:
  /// **'Profile Frames'**
  String get profileFrames;

  /// No description provided for @profileBadges.
  ///
  /// In en, this message translates to:
  /// **'Profile Badges'**
  String get profileBadges;

  /// No description provided for @profileThemes.
  ///
  /// In en, this message translates to:
  /// **'Profile Themes'**
  String get profileThemes;

  /// No description provided for @celebrationEffects.
  ///
  /// In en, this message translates to:
  /// **'Celebration Effects'**
  String get celebrationEffects;

  /// No description provided for @nameplates.
  ///
  /// In en, this message translates to:
  /// **'Nameplates'**
  String get nameplates;

  /// No description provided for @silaWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Sila Wardrobe'**
  String get silaWardrobe;

  /// No description provided for @silaOutfits.
  ///
  /// In en, this message translates to:
  /// **'Sila Outfits'**
  String get silaOutfits;

  /// No description provided for @silaAuras.
  ///
  /// In en, this message translates to:
  /// **'Sila Auras'**
  String get silaAuras;

  /// No description provided for @tokensAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} Tokens'**
  String tokensAmount(int count);

  /// No description provided for @limited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limited;

  /// No description provided for @permanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get permanent;

  /// No description provided for @needMoreTokens.
  ///
  /// In en, this message translates to:
  /// **'Need {count} more Tokens'**
  String needMoreTokens(int count);

  /// No description provided for @buyForTokens.
  ///
  /// In en, this message translates to:
  /// **'Buy for {count}'**
  String buyForTokens(int count);

  /// No description provided for @noTokenActivity.
  ///
  /// In en, this message translates to:
  /// **'No Token activity yet'**
  String get noTokenActivity;

  /// No description provided for @tokenActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Token earnings and spending will appear here.'**
  String get tokenActivityDescription;

  /// No description provided for @tokenHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load Token history.'**
  String get tokenHistoryLoadFailed;

  /// No description provided for @tokenEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get tokenEarned;

  /// No description provided for @tokenSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get tokenSpent;

  /// No description provided for @tokenRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get tokenRefunded;

  /// No description provided for @tokenAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get tokenAdjusted;

  /// No description provided for @codeBreakerTitle.
  ///
  /// In en, this message translates to:
  /// **'Code Breaker'**
  String get codeBreakerTitle;

  /// No description provided for @codeBreakerDescription.
  ///
  /// In en, this message translates to:
  /// **'Crack the hidden code using logic. Fewer attempts and faster solves earn more points.'**
  String get codeBreakerDescription;

  /// No description provided for @chooseExactlyTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'Choose exactly 2 players.'**
  String get chooseExactlyTwoPlayers;

  /// No description provided for @codeBreakerRoundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Both players crack a new code in every round.'**
  String get codeBreakerRoundsDescription;

  /// No description provided for @startCodeBreaker.
  ///
  /// In en, this message translates to:
  /// **'Start Code Breaker'**
  String get startCodeBreaker;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @codeEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'3-symbol codes with no repeated symbols.'**
  String get codeEasyDescription;

  /// No description provided for @codeMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'4-symbol codes with a larger symbol pool.'**
  String get codeMediumDescription;

  /// No description provided for @codeHardDescription.
  ///
  /// In en, this message translates to:
  /// **'5-symbol codes where symbols may repeat.'**
  String get codeHardDescription;

  /// No description provided for @difficultyValue.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} Difficulty'**
  String difficultyValue(String difficulty);

  /// No description provided for @otherPlayerLookAway.
  ///
  /// In en, this message translates to:
  /// **'The other player should look away until this turn is finished.'**
  String get otherPlayerLookAway;

  /// No description provided for @playerRound.
  ///
  /// In en, this message translates to:
  /// **'{name} — Round {round}'**
  String playerRound(String name, int round);

  /// No description provided for @codeDifficultySummary.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} • {length}-symbol code'**
  String codeDifficultySummary(String difficulty, int length);

  /// No description provided for @chooseSymbols.
  ///
  /// In en, this message translates to:
  /// **'Choose symbols'**
  String get chooseSymbols;

  /// No description provided for @tryCode.
  ///
  /// In en, this message translates to:
  /// **'Try Code'**
  String get tryCode;

  /// No description provided for @attemptsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String attemptsCount(int count);

  /// No description provided for @previousGuesses.
  ///
  /// In en, this message translates to:
  /// **'Previous Guesses'**
  String get previousGuesses;

  /// No description provided for @correctPositions.
  ///
  /// In en, this message translates to:
  /// **'✅ {count} in the correct position'**
  String correctPositions(int count);

  /// No description provided for @misplacedSymbols.
  ///
  /// In en, this message translates to:
  /// **'🔄 {count} correct but in the wrong position'**
  String misplacedSymbols(int count);

  /// No description provided for @codeCracked.
  ///
  /// In en, this message translates to:
  /// **'Code Cracked!'**
  String get codeCracked;

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String secondsCount(int count);

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{count} points'**
  String pointsEarned(int count);

  /// No description provided for @passToPlayer.
  ///
  /// In en, this message translates to:
  /// **'Pass to {name}'**
  String passToPlayer(String name);

  /// No description provided for @roundDifficultySummary.
  ///
  /// In en, this message translates to:
  /// **'{rounds, plural, =1{1 round} other{{rounds} rounds}} • {difficulty}'**
  String roundDifficultySummary(int rounds, String difficulty);

  /// No description provided for @attemptTimeSummary.
  ///
  /// In en, this message translates to:
  /// **'{attempts, plural, =1{1 attempt} other{{attempts} attempts}} • {seconds} s'**
  String attemptTimeSummary(int attempts, int seconds);

  /// No description provided for @returnToCompetitionAction.
  ///
  /// In en, this message translates to:
  /// **'Return to Competition'**
  String get returnToCompetitionAction;

  /// No description provided for @riskItTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk It'**
  String get riskItTitle;

  /// No description provided for @riskItDescription.
  ///
  /// In en, this message translates to:
  /// **'Build a points pot, bank it safely, or risk everything for a bigger score.'**
  String get riskItDescription;

  /// No description provided for @riskItRoundsDescription.
  ///
  /// In en, this message translates to:
  /// **'Both players get one private turn per round.'**
  String get riskItRoundsDescription;

  /// No description provided for @startRiskIt.
  ///
  /// In en, this message translates to:
  /// **'Start Risk It'**
  String get startRiskIt;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @preparingAiQuestions.
  ///
  /// In en, this message translates to:
  /// **'AI is preparing your questions...'**
  String get preparingAiQuestions;

  /// No description provided for @privateTurnLookAway.
  ///
  /// In en, this message translates to:
  /// **'The other player should look away during this turn.'**
  String get privateTurnLookAway;

  /// No description provided for @roundDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Round {round} • {difficulty}'**
  String roundDifficulty(int round, String difficulty);

  /// No description provided for @currentPot.
  ///
  /// In en, this message translates to:
  /// **'CURRENT POT'**
  String get currentPot;

  /// No description provided for @questionWorth.
  ///
  /// In en, this message translates to:
  /// **'This question is worth +{points}'**
  String questionWorth(int points);

  /// No description provided for @unbankedPot.
  ///
  /// In en, this message translates to:
  /// **'Unbanked Pot'**
  String get unbankedPot;

  /// No description provided for @nextCorrectWorth.
  ///
  /// In en, this message translates to:
  /// **'Next correct answer: +{points}'**
  String nextCorrectWorth(int points);

  /// No description provided for @bankPoints.
  ///
  /// In en, this message translates to:
  /// **'Bank {points} Points'**
  String bankPoints(int points);

  /// No description provided for @riskItAction.
  ///
  /// In en, this message translates to:
  /// **'RISK IT'**
  String get riskItAction;

  /// No description provided for @riskWarning.
  ///
  /// In en, this message translates to:
  /// **'One wrong answer and your entire unbanked pot is lost.'**
  String get riskWarning;

  /// No description provided for @bust.
  ///
  /// In en, this message translates to:
  /// **'BUST!'**
  String get bust;

  /// No description provided for @pointsBanked.
  ///
  /// In en, this message translates to:
  /// **'Points Banked!'**
  String get pointsBanked;

  /// No description provided for @playerLostPot.
  ///
  /// In en, this message translates to:
  /// **'{name} lost the unbanked pot.'**
  String playerLostPot(String name);

  /// No description provided for @playerBankedPoints.
  ///
  /// In en, this message translates to:
  /// **'{name} banked {points} points.'**
  String playerBankedPoints(String name, int points);

  /// No description provided for @seeRoundResults.
  ///
  /// In en, this message translates to:
  /// **'See Round Results'**
  String get seeRoundResults;

  /// No description provided for @playerScore.
  ///
  /// In en, this message translates to:
  /// **'{name}: {score}'**
  String playerScore(String name, int score);

  /// No description provided for @riskFinalSummary.
  ///
  /// In en, this message translates to:
  /// **'{rounds, plural, =1{1 round} other{{rounds} rounds}} • {difficulty} • {category}'**
  String riskFinalSummary(int rounds, String difficulty, String category);

  /// No description provided for @couldNotPrepareAiQuestions.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the AI questions. Please try again.'**
  String get couldNotPrepareAiQuestions;

  /// No description provided for @attackOrDefendTitle.
  ///
  /// In en, this message translates to:
  /// **'Attack or Defend'**
  String get attackOrDefendTitle;

  /// No description provided for @attackOrDefendDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer AI challenges, build energy, attack your rival, and defend your hearts.'**
  String get attackOrDefendDescription;

  /// No description provided for @whoIsBattling.
  ///
  /// In en, this message translates to:
  /// **'Who is battling?'**
  String get whoIsBattling;

  /// No description provided for @bestOf.
  ///
  /// In en, this message translates to:
  /// **'Best Of'**
  String get bestOf;

  /// No description provided for @bestOfDescription.
  ///
  /// In en, this message translates to:
  /// **'Best of 1, 3, or 5 battles. The match ends as soon as someone reaches the required wins.'**
  String get bestOfDescription;

  /// No description provided for @startBattle.
  ///
  /// In en, this message translates to:
  /// **'Start Battle'**
  String get startBattle;

  /// No description provided for @preparingAiBattle.
  ///
  /// In en, this message translates to:
  /// **'AI is preparing your battle...'**
  String get preparingAiBattle;

  /// No description provided for @battleBestOf.
  ///
  /// In en, this message translates to:
  /// **'Battle {battle} • Best of {rounds}'**
  String battleBestOf(int battle, int rounds);

  /// No description provided for @playerIsAttacking.
  ///
  /// In en, this message translates to:
  /// **'{name} is attacking!'**
  String playerIsAttacking(String name);

  /// No description provided for @playerMustBlock.
  ///
  /// In en, this message translates to:
  /// **'{name} must answer correctly to block the attack.'**
  String playerMustBlock(String name);

  /// No description provided for @otherPlayerLookAwayShort.
  ///
  /// In en, this message translates to:
  /// **'The other player should look away.'**
  String get otherPlayerLookAwayShort;

  /// No description provided for @defendAction.
  ///
  /// In en, this message translates to:
  /// **'🛡️ DEFEND!'**
  String get defendAction;

  /// No description provided for @earnEnergyAction.
  ///
  /// In en, this message translates to:
  /// **'⚡ EARN ENERGY'**
  String get earnEnergyAction;

  /// No description provided for @shieldActive.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Shield'**
  String get shieldActive;

  /// No description provided for @chooseYourMove.
  ///
  /// In en, this message translates to:
  /// **'{name}, choose your move'**
  String chooseYourMove(String name);

  /// No description provided for @energyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Energy available: ⚡ {count}'**
  String energyAvailable(int count);

  /// No description provided for @attackMove.
  ///
  /// In en, this message translates to:
  /// **'⚔️ Attack'**
  String get attackMove;

  /// No description provided for @attackMoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Costs 1 energy • Defender gets 10 seconds'**
  String get attackMoveDescription;

  /// No description provided for @shieldMove.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Shield'**
  String get shieldMove;

  /// No description provided for @shieldMoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Costs 1 energy • Blocks your next failed defense'**
  String get shieldMoveDescription;

  /// No description provided for @powerAttackMove.
  ///
  /// In en, this message translates to:
  /// **'🔥 Power Attack'**
  String get powerAttackMove;

  /// No description provided for @powerAttackMoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Costs 2 energy • Defender gets 7 seconds'**
  String get powerAttackMoveDescription;

  /// No description provided for @superAttackMove.
  ///
  /// In en, this message translates to:
  /// **'💥 Super Attack'**
  String get superAttackMove;

  /// No description provided for @superAttackMoveDescription.
  ///
  /// In en, this message translates to:
  /// **'Costs 3 energy • 5 seconds • 2 damage if missed'**
  String get superAttackMoveDescription;

  /// No description provided for @saveEnergyEndTurn.
  ///
  /// In en, this message translates to:
  /// **'Save Energy & End Turn'**
  String get saveEnergyEndTurn;

  /// No description provided for @battleNumberComplete.
  ///
  /// In en, this message translates to:
  /// **'Battle {number} Complete!'**
  String battleNumberComplete(int number);

  /// No description provided for @startBattleNumber.
  ///
  /// In en, this message translates to:
  /// **'Start Battle {number}'**
  String startBattleNumber(int number);

  /// No description provided for @playerWinsBattle.
  ///
  /// In en, this message translates to:
  /// **'{name} wins the battle!'**
  String playerWinsBattle(String name);

  /// No description provided for @battleFinalSummary.
  ///
  /// In en, this message translates to:
  /// **'Best of {rounds} • {difficulty} • {category}'**
  String battleFinalSummary(int rounds, String difficulty, String category);

  /// No description provided for @couldNotPrepareAiBattle.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the AI battle. Please try again.'**
  String get couldNotPrepareAiBattle;

  /// No description provided for @duelGames.
  ///
  /// In en, this message translates to:
  /// **'Duel Games'**
  String get duelGames;

  /// No description provided for @duelGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Head-to-head games built specifically for 2 players.'**
  String get duelGamesSubtitle;

  /// No description provided for @familyGames.
  ///
  /// In en, this message translates to:
  /// **'Family Games'**
  String get familyGames;

  /// No description provided for @familyGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play together with 2 or more family members.'**
  String get familyGamesSubtitle;

  /// No description provided for @partyGamesSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Casual games made for laughs and group fun.'**
  String get partyGamesSectionSubtitle;

  /// No description provided for @logicDuel.
  ///
  /// In en, this message translates to:
  /// **'LOGIC DUEL'**
  String get logicDuel;

  /// No description provided for @battleDuel.
  ///
  /// In en, this message translates to:
  /// **'BATTLE DUEL'**
  String get battleDuel;

  /// No description provided for @highStakesDuel.
  ///
  /// In en, this message translates to:
  /// **'HIGH-STAKES DUEL'**
  String get highStakesDuel;
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
