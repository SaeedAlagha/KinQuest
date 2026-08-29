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
  String get preferences => 'Preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceDescription => 'Choose how Sila looks across the app';

  @override
  String get selectAppearance => 'Choose your Sila theme';

  @override
  String get silaLightTheme => 'Sila Light';

  @override
  String get silaLightThemeDescription => 'Bright, calm, and familiar';

  @override
  String get darkTheme => 'Dark';

  @override
  String get darkThemeDescription => 'A comfortable palette for evenings';

  @override
  String get uaeFamilyYearTheme => 'UAE Family Year 2026';

  @override
  String get uaeFamilyYearThemeDescription => 'Heritage arches, majlis warmth, and colors of unity';

  @override
  String get spaceTheme => 'Cosmic Family';

  @override
  String get spaceThemeDescription => 'Starlit adventures, glowing orbits, and deep-space wonder';

  @override
  String get khalifaUniversityTheme => 'KU Future Lab';

  @override
  String get khalifaUniversityThemeDescription => 'A precise blue innovation system inspired by Khalifa University';

  @override
  String get desertNightsTheme => 'Desert Nights';

  @override
  String get desertNightsThemeDescription => 'Moonlit dunes, copper sunsets, and luxurious night skies';

  @override
  String get pearlLagoonTheme => 'Pearl Lagoon';

  @override
  String get pearlLagoonThemeDescription => 'Luminous pearls, coral accents, and calm Gulf waters';

  @override
  String get themeStudio => 'Theme Studio';

  @override
  String get themeStudioDescription => 'Earn Family Tokens together and unlock a look the whole family loves.';

  @override
  String themeTokenBalance(int tokens) {
    return '$tokens Family Tokens';
  }

  @override
  String get themeIncluded => 'Included';

  @override
  String get themeOwned => 'Owned';

  @override
  String themeTokenPrice(int tokens) {
    return '$tokens Tokens';
  }

  @override
  String unlockThemeTitle(String theme) {
    return 'Unlock $theme?';
  }

  @override
  String unlockThemeMessage(int tokens) {
    return 'Spend $tokens Family Tokens for a permanent family theme unlock?';
  }

  @override
  String unlockForTokens(int tokens) {
    return 'Unlock for $tokens';
  }

  @override
  String get notEnoughTokensTitle => 'Keep playing together';

  @override
  String notEnoughTokensMessage(int cost, int balance) {
    return 'This theme costs $cost Tokens. Your family currently has $balance.';
  }

  @override
  String themeUnlocked(String theme) {
    return '$theme is now yours!';
  }

  @override
  String get themeUnlockFailed => 'The theme could not be unlocked. Your Tokens were not spent.';

  @override
  String get signInToUnlockThemes => 'Sign in and join a family to unlock reward themes.';

  @override
  String get themeUnlockBenefit => 'One-time unlock • Yours across signed-in devices';

  @override
  String get close => 'Close';

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
  String get accountEmail => 'Account email';

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

  @override
  String get navHome => 'Home';

  @override
  String get navSila => 'Wardrobe';

  @override
  String get navMemories => 'Memories';

  @override
  String get navPlay => 'Play';

  @override
  String get navMissions => 'Missions';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navProfile => 'Profile';

  @override
  String get developerFamilyPreview => 'Developer Family preview • Demo data only';

  @override
  String get exit => 'Exit';

  @override
  String get noUserSignedIn => 'No user is currently signed in.';

  @override
  String get silaMember => 'Sila Member';

  @override
  String get noFamilyJoined => 'No family joined';

  @override
  String get yourFamily => 'Your Family';

  @override
  String get developerPreviewMemoryReadOnly => 'Developer preview is read-only. No memory was added.';

  @override
  String get todaysDailyChallenge => 'Today\'s Daily Challenge';

  @override
  String get dailyChallengeHomeDescription => 'Complete today\'s family challenge and earn bonus tokens.';

  @override
  String get growingInUnity => 'GROWING IN UNITY';

  @override
  String get smallMomentsStrongerBonds => 'Small moments, stronger bonds';

  @override
  String get homeBondDescription => 'Create a memory or play together—simple ways to stay close every day.';

  @override
  String get addMemory => 'Add a Memory';

  @override
  String get addMemoryDescription => 'Save a photo, video, or story from today.';

  @override
  String get challengeFamily => 'Challenge the Family';

  @override
  String get challengeFamilyDescription => 'Start a friendly match and share a laugh.';

  @override
  String welcomeName(String name) {
    return 'Welcome, $name';
  }

  @override
  String get silaFamilySpace => 'SILA FAMILY SPACE • صِلَة';

  @override
  String get rootsBondsGrowth => 'ROOTS • BONDS • GROWTH';

  @override
  String familyMembersConnected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count family members connected through stories, play, and moments together.',
      one: '1 family member connected through stories, play, and moments together.',
      zero: 'No family members connected yet.',
    );
    return '$_temp0';
  }

  @override
  String get familyOverview => 'Family Overview';

  @override
  String get familyMembers => 'Family members';

  @override
  String get familyTokens => 'Family tokens';

  @override
  String get games => 'Games';

  @override
  String get gamesEyebrow => 'FAMILY YEAR • BONDS THROUGH PLAY';

  @override
  String get gamesHeading => 'Find your next family favorite';

  @override
  String get gamesDescription => 'Share a quick laugh, a thoughtful question, or a challenge that brings every generation closer.';

  @override
  String get familyQuiz => 'Family Quiz';

  @override
  String get familyQuizDescription => 'Share real answers and discover how well your family knows one another.';

  @override
  String get connectedPlay => 'CONNECTED PLAY';

  @override
  String get trivia => 'Trivia';

  @override
  String get triviaDescription => 'Challenge your family with questions and compete for the highest score.';

  @override
  String get knowledge => 'KNOWLEDGE';

  @override
  String get emojiGuess => 'Emoji Guess';

  @override
  String get emojiGuessDescription => 'Decode emoji clues and compete to get the highest score.';

  @override
  String get guessingGame => 'GUESSING GAME';

  @override
  String get partyGames => 'Party Games';

  @override
  String get partyGamesDescription => 'Quick family games for laughs and fun.';

  @override
  String get fourGamesInside => '4 GAMES INSIDE';

  @override
  String get familyImpostor => 'Family Impostor';

  @override
  String get familyImpostorDescription => 'Find the hidden impostor through clues, discussion, and family voting.';

  @override
  String get socialDeduction => 'SOCIAL DEDUCTION';

  @override
  String get secretMission => 'Secret Mission';

  @override
  String get secretMissionDescription => 'Complete a hidden mission without your family figuring out what you are doing.';

  @override
  String get secretChallenge => 'SECRET CHALLENGE';

  @override
  String get captionBattle => 'Caption Battle';

  @override
  String get captionBattleDescription => 'Caption real family photos, vote anonymously, and crown the funniest family member.';

  @override
  String get photoParty => 'PHOTO PARTY';

  @override
  String get passTheBomb => 'Pass the Bomb';

  @override
  String get passTheBombDescription => 'Answer quickly, pass the phone, and avoid being caught when the hidden timer explodes.';

  @override
  String get fastFamilyFun => 'FAST FAMILY FUN';

  @override
  String get drawAndGuess => 'Draw & Guess';

  @override
  String get drawAndGuessDescription => 'Draw AI-generated prompts while your family guesses aloud.';

  @override
  String get creativePlay => 'CREATIVE PLAY';

  @override
  String get dontSayIt => 'Don\'t Say It';

  @override
  String get dontSayItDescription => 'Describe the secret word without saying any of the forbidden words.';

  @override
  String get wordChallenge => 'WORD CHALLENGE';

  @override
  String get openGame => 'Open game';

  @override
  String get preview => 'Preview';

  @override
  String get wouldYouRather => 'Would You Rather';

  @override
  String get wouldYouRatherDescription => 'Choose between two playful options.';

  @override
  String get charades => 'Charades';

  @override
  String get charadesDescription => 'Act out creative prompts for the whole family.';

  @override
  String get neverHaveIEver => 'Never Have I Ever';

  @override
  String get neverHaveIEverDescription => 'Share family-friendly moments and surprises.';

  @override
  String get truthOrDare => 'Truth or Dare';

  @override
  String get truthOrDareDescription => 'Pick a friendly truth or a fun challenge.';

  @override
  String get partyGamesHeading => 'Quick games. Big laughs.';

  @override
  String get partyGamesSubtitle => 'Pick a game and pass the device around—no setup required.';

  @override
  String get gameFutureUpdate => 'This game will be implemented in a future update.';

  @override
  String get playTogether => 'Play Together';

  @override
  String get playTogetherDescription => 'Gather around, choose how you want to play, then pick a game.';

  @override
  String get quickPlay => 'Quick Play';

  @override
  String get quickPlayDescription => 'Choose any game and play together on one phone. No Tokens or official ranking.';

  @override
  String get quickPlayReward => 'Just for fun • No Tokens';

  @override
  String get dailyChallengeCompetitionDescription => 'Compete in today\'s selected game. The winner earns Tokens.';

  @override
  String get dailyChallengeCompetitionReward => 'Winner Tokens';

  @override
  String get weeklyChampionship => 'Weekly Championship';

  @override
  String get weeklyChampionshipDescription => 'Compete across several game rounds and become this week\'s Family Champion.';

  @override
  String get weeklyChampionshipReward => 'Family Wish';

  @override
  String get monthlyCup => 'Monthly Cup';

  @override
  String get monthlyCupDescription => 'The family\'s biggest monthly competition. Win a trophy and bonus Tokens.';

  @override
  String get monthlyCupReward => 'Trophy and Bonus Tokens';

  @override
  String rewardLabel(String reward) {
    return 'Reward: $reward';
  }

  @override
  String get view => 'View';

  @override
  String get familyTrophyCabinet => 'Family Trophy Cabinet';

  @override
  String get familyTrophyCabinetDescription => 'Previous weekly and monthly champions will appear here.';

  @override
  String get trophyCabinetSignIn => 'Sign in to see the trophies your family has earned.';

  @override
  String get trophyCabinetJoinFamily => 'Join or create a family to start filling this cabinet.';

  @override
  String get trophyCabinetLoadError => 'The trophy cabinet could not be loaded.';

  @override
  String get monthlyCupTrophy => 'Monthly Cup Trophy';

  @override
  String get weeklyChampionTrophy => 'Weekly Champion Medal';

  @override
  String trophyWonBy(String name) {
    return 'Won for the family by $name';
  }

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get leaderboardSignIn => 'Sign in to view your family leaderboard.';

  @override
  String get leaderboardJoinFamily => 'Join or create a family to view the leaderboard.';

  @override
  String get leaderboardLoadError => 'Could not load the family leaderboard.';

  @override
  String get leaderboardNoMembers => 'No family members found.';

  @override
  String get familyLeaderboard => 'Family Leaderboard';

  @override
  String get familyMember => 'Family Member';

  @override
  String tokenCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tokens',
      one: '1 token',
    );
    return '$_temp0';
  }

  @override
  String get developerFamilyLeaderboard => 'Developer Family Leaderboard';

  @override
  String get competitionFutureUpdate => 'Competition logic will be implemented in a future update.';

  @override
  String get familyQuizDay => 'Family Quiz Day';

  @override
  String get familyQuizDayDescription => 'See how well your family knows one another in today\'s Family Quiz.';

  @override
  String get memoryChallengeDay => 'Memory Challenge Day';

  @override
  String get memoryChallengeDayDescription => 'Look back at your family moments and test how well you remember them.';

  @override
  String get familyMissionDay => 'Family Mission Day';

  @override
  String get familyMissionDayDescription => 'Complete one meaningful activity together from Family Missions.';

  @override
  String get partyGameDay => 'Party Game Day';

  @override
  String get partyGameDayDescription => 'Pick a quick family game and share a few laughs together.';

  @override
  String get dailyChallengeSignInRequired => 'You must be signed in to use Daily Challenge.';

  @override
  String get dailyChallengeFamilyRequired => 'Join or create a family before playing Daily Challenge.';

  @override
  String get dailyChallengeLoadError => 'Could not load today\'s challenge. Please try again.';

  @override
  String get dailyChallengeCompleteMessage => 'Daily Challenge complete! You earned 10 tokens.';

  @override
  String get dailyChallengeAlreadyClaimed => 'You already claimed today\'s Daily Challenge.';

  @override
  String get dailyChallengeSaveError => 'Could not complete the Daily Challenge. Please try again.';

  @override
  String get todaysFamilyChallenge => 'TODAY\'S FAMILY CHALLENGE';

  @override
  String get dailyReward => 'Daily reward';

  @override
  String get dailyRewardDescription => '+10 tokens and daily streak progress';

  @override
  String get dailyChallengeCompleted => 'You completed today\'s challenge. Come back tomorrow for a new one!';

  @override
  String get playTodaysChallenge => 'Play Today\'s Challenge';

  @override
  String get savingCompletion => 'Saving completion...';

  @override
  String get iCompletedIt => 'I Completed It';

  @override
  String get openChallengeBeforeClaiming => 'Open today\'s challenge before claiming the reward.';

  @override
  String get welcomePrivateFamilySpace => 'A private family space for shared stories, playful challenges, and the moments that keep everyone connected.';

  @override
  String get mascotName => 'Sila';

  @override
  String get mascotSemanticLabel => 'Sila, your family companion';

  @override
  String get silaLogoSemanticLabel => 'Sila family connection logo';

  @override
  String get familyYearSemanticLabel => 'UAE Year of Family 2026, Growing in Unity';

  @override
  String get uaeFlagSemanticLabel => 'United Arab Emirates flag';

  @override
  String get profileFrameEquippedSemanticLabel => 'Profile frame equipped';

  @override
  String get mascotWelcomeMessage => 'Hi! I’m Sila. I’ll help your family play, create, and grow closer.';

  @override
  String mascotHomeMessage(String name) {
    return 'Ready for a small family moment together, $name?';
  }

  @override
  String get mascotGameSetupMessage => 'I’ll guide everyone. Choose your setup and let’s play!';

  @override
  String get mascotThinkingMessage => 'I’m preparing something special for your family...';

  @override
  String get mascotOopsMessage => 'That did not work yet. Let’s try again together!';

  @override
  String get mascotCelebrationMessage => 'Amazing teamwork! Every moment together makes your bond stronger.';

  @override
  String get silaMissionsMessage => 'Pick a mission, help each other, and turn a small action into a family win!';

  @override
  String get silaStudioTitle => 'Sila Studio';

  @override
  String get silaStudioSubtitle => 'Make your family companion feel uniquely yours.';

  @override
  String get silaStudioProfileEntryDescription => 'Play with Sila, grow your bond, and choose his look.';

  @override
  String get silaStudioTapHint => 'Tap Sila or choose a reaction to bring him to life.';

  @override
  String get silaStudioCloset => 'Closet';

  @override
  String get silaStudioClosetDescription => 'Try combinations before unlocking them permanently with Family Tokens.';

  @override
  String get silaStudioHeadwear => 'Headwear';

  @override
  String get silaStudioOutfits => 'Outfits';

  @override
  String get silaStudioAuras => 'Auras';

  @override
  String get silaStudioOwned => 'Owned';

  @override
  String get silaStudioEquipped => 'Equipped';

  @override
  String get silaStudioEquip => 'Equip';

  @override
  String get silaStudioUnequip => 'Unequip';

  @override
  String silaStudioUnlock(int tokens) {
    return 'Unlock for $tokens';
  }

  @override
  String silaStudioNotEnoughTokens(int tokens) {
    return 'Need $tokens more Tokens';
  }

  @override
  String get silaStudioPermanent => 'Permanent';

  @override
  String get silaStudioTryOn => 'Try on';

  @override
  String get silaStudioReactionHover => 'Hover';

  @override
  String get silaStudioReactionReady => 'Game ready';

  @override
  String get silaStudioReactionThink => 'Think';

  @override
  String get silaStudioReactionWave => 'Wave';

  @override
  String get silaStudioReactionCelebrate => 'Celebrate';

  @override
  String get silaStudioWelcomeMessage => 'Welcome to my studio! Mix a look, test a reaction, and take me into your next game.';

  @override
  String get silaStudioUpdateSuccess => 'Sila\'s look is ready everywhere.';

  @override
  String get silaStudioUnlockSuccess => 'Unlocked and equipped! Sila has a new look.';

  @override
  String get silaStudioLoadError => 'Sila\'s closet could not be loaded. Please try again.';

  @override
  String get silaBondTitle => 'Your Family Bond';

  @override
  String get silaBondDescription => 'Sila grows closer as your family plays, completes missions, and celebrates achievements together.';

  @override
  String silaBondPoints(int points) {
    return '$points Bond Points';
  }

  @override
  String silaBondLevel(int level, String name) {
    return 'Level $level: $name';
  }

  @override
  String silaBondPointsToNext(int points, String level) {
    return '$points points until $level';
  }

  @override
  String get silaBondMaxLevel => 'Your family has reached Sila\'s highest bond level!';

  @override
  String silaBondProgressSemantic(int percent) {
    return 'Bond level progress: $percent percent';
  }

  @override
  String get silaBondJourneyTitle => 'Sila\'s bond journey';

  @override
  String get silaBondJourneyDescription => 'These levels celebrate your relationship with Sila. His chosen look stays the same across every app theme.';

  @override
  String get silaBondNewCompanion => 'New Companion';

  @override
  String get silaBondFamilyFriend => 'Family Friend';

  @override
  String get silaBondMemoryKeeper => 'Memory Keeper';

  @override
  String get silaBondFamilyGuardian => 'Family Guardian';

  @override
  String get silaBondLegacyCompanion => 'Legacy Companion';

  @override
  String get silaBondCurrent => 'Current level';

  @override
  String get silaBondReached => 'Reached';

  @override
  String get silaBondLocked => 'Keep bonding';

  @override
  String get silaBondTrophies => 'Trophies';

  @override
  String get silaGameCoachMessage => 'I’m right here with you—play fair, cheer loudly, and have fun together!';

  @override
  String get uaeYearOfFamily2026 => 'UAE YEAR OF FAMILY 2026';

  @override
  String get everyBondHelpsFamilyGrow => 'Every bond helps a family grow';

  @override
  String get silaEverydayMoments => 'Sila turns everyday moments into stronger roots, closer bonds, and shared growth.';

  @override
  String get familyMomentsStayPrivate => 'Your family moments stay with your family.';

  @override
  String get logIn => 'Log In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBackToSila => 'Welcome back to Sila';

  @override
  String get loginDescription => 'Reconnect with your family circle and continue where you left off.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailAddressHint => 'name@example.com';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordRecoveryComing => 'Enter your account email and we’ll send you a secure password reset link.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get loggingIn => 'Logging In...';

  @override
  String get enterDeveloperFamily => 'Enter Developer Family';

  @override
  String get debugPreviewDescription => 'Debug preview only • Uses read-only demo data';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createOne => 'Create one';

  @override
  String get incorrectEmailOrPassword => 'Incorrect email or password.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address.';

  @override
  String get tooManyLoginAttempts => 'Too many attempts. Please try again later.';

  @override
  String get noInternetConnection => 'No internet connection. Please try again.';

  @override
  String get couldNotLogIn => 'Could not log in. Please try again.';

  @override
  String get joinSila => 'Join Sila';

  @override
  String get signupDescription => 'Create your account and bring your family circle closer.';

  @override
  String get fullName => 'Full name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get dateOfBirthHint => 'DD/MM/YYYY';

  @override
  String get passwordRequirements => '8+ characters, uppercase, lowercase, and number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get acceptTerms => 'I agree to the Terms of Service and Privacy Policy.';

  @override
  String get readTermsPrivacy => 'Read Terms & Privacy';

  @override
  String get legalPrivacyCenter => 'Terms & Privacy';

  @override
  String get legalIntro => 'Sila is designed as a private family space. This summary explains how the app handles family information and the rules that keep the experience safe.';

  @override
  String get legalEffectiveDate => 'Effective August 2026';

  @override
  String get legalAccountDataTitle => 'Account information';

  @override
  String get legalAccountDataBody => 'Sila uses the name, email address, date of birth, profile settings, and sign-in information you provide to run and protect your account.';

  @override
  String get legalFamilyDataTitle => 'Private family content';

  @override
  String get legalFamilyDataBody => 'Family profiles, memories, game results, missions, Wishes, Tokens, and invitations are stored with your family account in Firebase and are governed by family membership and roles.';

  @override
  String get legalAiTitle => 'AI-assisted features';

  @override
  String get legalAiBody => 'When you use an AI game or mission proof, Sila sends only the text or selected image needed for that request through its server to Google Gemini. Mission proof images are evaluated without being stored by Sila.';

  @override
  String get legalControlsTitle => 'Your controls';

  @override
  String get legalControlsBody => 'You can edit your profile and memories, manage family membership according to your role, control notifications, and choose the app language and appearance.';

  @override
  String get legalTermsTitle => 'Family-safe use';

  @override
  String get legalTermsBody => 'Use Sila respectfully and only share content you have permission to use. Family Tokens and Ranking Points are in-app progress with no cash value. Owners and admins are responsible for family membership and roles.';

  @override
  String get creatingAccount => 'Creating Account...';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dateOfBirthRequired => 'Date of birth is required.';

  @override
  String get selectValidDateOfBirth => 'Select a valid date of birth.';

  @override
  String get dateOfBirthFuture => 'Date of birth cannot be in the future.';

  @override
  String get acceptTermsRequired => 'You must accept the Terms of Service and Privacy Policy.';

  @override
  String get emailAlreadyInUse => 'An account already exists with this email.';

  @override
  String get weakPassword => 'Your password is too weak.';

  @override
  String get couldNotCreateAccount => 'Could not create your account. Please try again.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get familySetup => 'Family Setup';

  @override
  String get connectWithFamily => 'Connect with your family';

  @override
  String get createOrJoinFamily => 'Create a new family group or join an existing one.';

  @override
  String get createFamily => 'Create a Family';

  @override
  String get joinFamily => 'Join a Family';

  @override
  String get createFamilyGroup => 'Create your family group';

  @override
  String get createFamilyDescription => 'Give your family a name and invite relatives to join.';

  @override
  String get createFamilyLoginRequired => 'You must be logged in to create a family.';

  @override
  String get familyCreated => 'Family created successfully.';

  @override
  String get couldNotCreateFamily => 'Could not create the family. Please try again.';

  @override
  String get alreadyInFamily => 'Leave your current family before creating another one.';

  @override
  String get familyImageComing => 'Family image upload will be added later.';

  @override
  String get familyName => 'Family name';

  @override
  String get familyNameHint => 'Alagha Family';

  @override
  String get familyDescriptionOptional => 'Family description (optional)';

  @override
  String get familyDescriptionHint => 'A short message about your family';

  @override
  String get creatingFamily => 'Creating Family...';

  @override
  String get yourInvitationCode => 'Your invitation code';

  @override
  String get shareInvitationCode => 'Share this code with relatives so they can join your family.';

  @override
  String get copyingComing => 'Copying will be connected next.';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get continueToHome => 'Continue to Home';

  @override
  String get joinYourFamily => 'Join your family';

  @override
  String get joinFamilyDescription => 'Enter the six-character invitation code shared by your family.';

  @override
  String get joinFamilyLoginRequired => 'You must be logged in to join a family.';

  @override
  String get invitationCodeNotFound => 'Invitation code not found.';

  @override
  String get alreadyFamilyMember => 'You are already a member of this family.';

  @override
  String get leaveCurrentFamilyFirst => 'Leave your current family before joining another one.';

  @override
  String get couldNotJoinFamily => 'Could not join the family. Please try again.';

  @override
  String get invitationCode => 'Invitation code';

  @override
  String get invitationCodeHint => 'A7K9Q2';

  @override
  String get joiningFamily => 'Joining Family...';

  @override
  String get validationFullNameRequired => 'Full name is required.';

  @override
  String get validationNameMinLength => 'Name must contain at least 2 characters.';

  @override
  String get validationNameMaxLength => 'Name cannot contain more than 40 characters.';

  @override
  String get validationNameLettersOnly => 'Name can only contain letters.';

  @override
  String get validationEmailRequired => 'Email address is required.';

  @override
  String get validationEmailNoSpaces => 'Email address cannot contain spaces.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Password is required.';

  @override
  String get validationPasswordMinLength => 'Password must contain at least 8 characters.';

  @override
  String get validationPasswordUppercase => 'Password must contain an uppercase letter.';

  @override
  String get validationPasswordLowercase => 'Password must contain a lowercase letter.';

  @override
  String get validationPasswordNumber => 'Password must contain a number.';

  @override
  String get validationConfirmPasswordRequired => 'Please confirm your password.';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match.';

  @override
  String get validationFamilyNameRequired => 'Family name is required.';

  @override
  String get validationFamilyNameMinLength => 'Family name must contain at least 2 characters.';

  @override
  String get validationFamilyNameMaxLength => 'Family name cannot contain more than 40 characters.';

  @override
  String get validationFamilyNameInvalid => 'Family name contains invalid characters.';

  @override
  String get validationInvitationCodeRequired => 'Invitation code is required.';

  @override
  String get validationInvitationCodeLength => 'Invitation code must contain exactly 6 characters.';

  @override
  String get validationInvitationCodeCharacters => 'Invitation code can only contain letters and numbers.';

  @override
  String get memoriesTitle => 'Memories';

  @override
  String get memoryTitleGeneric => 'Memory';

  @override
  String get memoriesFamilyRequired => 'Join or create a family to view memories.';

  @override
  String get memoriesLoadError => 'Could not load memories.';

  @override
  String get noMemoriesYet => 'No memories yet';

  @override
  String get memoriesEmptyDescription => 'Save photos, videos, and stories from your family moments.';

  @override
  String get addFirstMemory => 'Add Your First Memory';

  @override
  String get developerMemoriesTitle => 'Developer Family memories';

  @override
  String get developerMemoriesDescription => 'Sample moments for reviewing the experience. They are not stored in Firebase.';

  @override
  String get developerMemoriesReadOnly => 'Developer preview is read-only. No data was changed.';

  @override
  String get previewPicnicTitle => 'Family picnic at Mushrif Park';

  @override
  String get previewPicnicDescription => 'A sunny afternoon full of games, stories, and laughter.';

  @override
  String get previewPicnicDetails => '02/08/2026 • Dubai';

  @override
  String get previewLunchTitle => 'Friday lunch together';

  @override
  String get previewLunchDescription => 'Grandma shared her favorite family recipe with everyone.';

  @override
  String get previewLunchDetails => '31/07/2026 • Home';

  @override
  String get previewSunsetTitle => 'Sunset walk';

  @override
  String get previewSunsetDescription => 'We watched the sunset and planned our next family day.';

  @override
  String get previewSunsetDetails => '25/07/2026 • Abu Dhabi Corniche';

  @override
  String get addMemoryTitle => 'Add Memory';

  @override
  String get captureFamilyMoment => 'Capture a family moment';

  @override
  String get addMemoryScreenDescription => 'Add a photo and save a moment your family can revisit together.';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get photoTooLarge => 'That photo is still too large. Please choose another photo.';

  @override
  String get memoryDateRequired => 'Memory date is required.';

  @override
  String get selectValidMemoryDate => 'Select a valid memory date.';

  @override
  String get saveMemorySignInRequired => 'You must be signed in to save a memory.';

  @override
  String get addMemoryFamilyRequired => 'Join or create a family before adding memories.';

  @override
  String get memorySaved => 'Memory saved successfully.';

  @override
  String get couldNotSaveMemoryTryAgain => 'Could not save this memory. Please try again.';

  @override
  String couldNotSaveMemory(String error) {
    return 'Could not save the memory: $error';
  }

  @override
  String get memoryTitleLabel => 'Memory title';

  @override
  String get memoryTitleHint => 'Day at the Zoo';

  @override
  String get memoryDescriptionLabel => 'Description';

  @override
  String get memoryDescriptionHint => 'Tell the story behind this memory';

  @override
  String get memoryDateLabel => 'Date';

  @override
  String get memoryDateHint => 'DD/MM/YYYY';

  @override
  String get memoryLocationOptional => 'Location (optional)';

  @override
  String get memoryLocationHint => 'Al Ain Zoo';

  @override
  String get saveMemory => 'Save Memory';

  @override
  String get editMemory => 'Edit Memory';

  @override
  String get enterMemoryTitle => 'Enter a title for the memory.';

  @override
  String get couldNotSaveMemoryChangesTryAgain => 'Could not save these changes. Please try again.';

  @override
  String couldNotSaveMemoryChanges(String error) {
    return 'Could not save changes: $error';
  }

  @override
  String get titleLabel => 'Title';

  @override
  String get storyLabel => 'Story';

  @override
  String get locationLabel => 'Location';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get deleteMemoryQuestion => 'Delete memory?';

  @override
  String get deleteMemoryWarning => 'This memory will be permanently removed from your family memories.';

  @override
  String get deletingMemory => 'Deleting memory...';

  @override
  String get couldNotDeleteMemory => 'Could not delete this memory. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get memoryNotFound => 'Memory not found.';

  @override
  String get memoryDetailsLoadError => 'Could not load this memory. Please try again.';

  @override
  String get noDate => 'No date';

  @override
  String get editMemoryTooltip => 'Edit memory';

  @override
  String get deleteMemoryTooltip => 'Delete memory';

  @override
  String get validationMemoryTitleRequired => 'Memory title is required.';

  @override
  String get validationMemoryTitleMinLength => 'Memory title must contain at least 2 characters.';

  @override
  String get validationMemoryTitleMaxLength => 'Memory title cannot exceed 60 characters.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileTooltip => 'Edit profile';

  @override
  String get personalDetails => 'Your personal details';

  @override
  String get personalDetailsDescription => 'Keep your name recognizable so your family knows who is playing and contributing.';

  @override
  String get emailManagedSecurely => 'Your sign-in email is managed through account security.';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get savingProfile => 'Saving Profile...';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get couldNotLoadProfile => 'Could not load your profile. Please try again.';

  @override
  String get couldNotSaveProfile => 'Could not save your profile. Please try again.';

  @override
  String get developerPreviewReadOnly => 'Developer preview is read-only. No data was changed.';

  @override
  String get profileFamilySection => 'Family';

  @override
  String get statistics => 'Statistics';

  @override
  String get rewards => 'Rewards';

  @override
  String get achievements => 'Achievements';

  @override
  String get familyWishes => 'Family Wishes';

  @override
  String get logOut => 'Log Out';

  @override
  String get silaDeveloper => 'Sila Developer';

  @override
  String get developerFamilyName => 'Developer Family';

  @override
  String familyNameLabel(String name) {
    return 'Family: $name';
  }

  @override
  String get noFamilyJoinedYet => 'No family joined yet';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get wins => 'Wins';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String profileDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get memoryKeeper => 'Memory Keeper';

  @override
  String get memoryKeeperDescription => 'Save 100 family memories.';

  @override
  String get quizMaster => 'Quiz Master';

  @override
  String get quizMasterDescription => 'Win 20 Family Quizzes.';

  @override
  String get teamPlayer => 'Team Player';

  @override
  String get teamPlayerDescription => 'Complete 30 Family Missions.';

  @override
  String get noFamilyWishesYet => 'No Family Wishes yet';

  @override
  String get familyWishesEmptyDescription => 'Family Wishes earned from major competitions will appear here.';

  @override
  String get noTrophiesYet => 'No trophies yet';

  @override
  String get trophiesEmptyDescription => 'Weekly and monthly championship trophies will appear here.';

  @override
  String get couldNotLoadTrophies => 'Could not load family trophies. Please try again.';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appSettingsDescription => 'Language, notifications, and preferences';

  @override
  String get youHaveNotJoinedFamily => 'You have not joined a family yet.';

  @override
  String get inviteCodeLabel => 'Invite Code';

  @override
  String get copyInviteCode => 'Copy invite code';

  @override
  String get familyInviteCodeCopied => 'Family invite code copied.';

  @override
  String profileFamilyMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count family members',
      one: '1 family member',
      zero: 'No family members',
    );
    return '$_temp0';
  }

  @override
  String get shareFamilyInviteCode => 'Share this code with relatives so they can join this family.';

  @override
  String get manageFamily => 'Manage Family';

  @override
  String get familyManagement => 'Family Management';

  @override
  String get familyManagementDescription => 'Invite relatives, understand roles, and keep your family group organized.';

  @override
  String get familyLoadError => 'Could not load your family. Please try again.';

  @override
  String get familyMembersLoadError => 'Could not load family members. Please try again.';

  @override
  String get createOrJoinFamilyAction => 'Create or Join a Family';

  @override
  String get inviteRelatives => 'Invite relatives';

  @override
  String get familyInviteDescription => 'Share this private code only with relatives you want in your family space.';

  @override
  String get familyMembersTitle => 'Family members';

  @override
  String get familyMembersDescription => 'Roles explain what each person can manage in your family space.';

  @override
  String get familyRoles => 'Family roles';

  @override
  String get familyRoleOwner => 'Owner';

  @override
  String get familyRoleAdmin => 'Reward Admin';

  @override
  String get familyRoleMember => 'Member';

  @override
  String get familyOwnerDescription => 'Manages family details, members, roles, and ownership.';

  @override
  String get familyAdminDescription => 'Can review and approve family reward requests.';

  @override
  String get familyMemberDescription => 'Can join family games, missions, memories, and shared activities.';

  @override
  String familyMemberYou(String name) {
    return '$name (You)';
  }

  @override
  String get memberActions => 'Member actions';

  @override
  String get editFamily => 'Edit family';

  @override
  String get editFamilyDetails => 'Edit Family Details';

  @override
  String get saveFamily => 'Save Family';

  @override
  String get familyUpdated => 'Family details updated.';

  @override
  String get couldNotUpdateFamily => 'Could not update the family. Please try again.';

  @override
  String get makeAdmin => 'Make Reward Admin';

  @override
  String get removeAdmin => 'Remove Reward Admin';

  @override
  String get adminRoleUpdated => 'Family role updated.';

  @override
  String get couldNotUpdateAdminRole => 'Could not update this family role. Please try again.';

  @override
  String get transferOwnership => 'Transfer Ownership';

  @override
  String transferOwnershipQuestion(String name) {
    return 'Make $name the owner?';
  }

  @override
  String get transferOwnershipWarning => 'They will receive full family controls and you will become a regular member. This can be changed again by the new owner.';

  @override
  String get ownershipTransferred => 'Family ownership transferred.';

  @override
  String get couldNotTransferOwnership => 'Could not transfer ownership. Please try again.';

  @override
  String get removeMember => 'Remove Member';

  @override
  String removeMemberQuestion(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMemberWarning => 'They will lose access to this family\'s private content and can join or create another family.';

  @override
  String get familyMemberRemoved => 'Family member removed.';

  @override
  String get couldNotRemoveMember => 'Could not remove this family member. Please try again.';

  @override
  String get leaveFamily => 'Leave Family';

  @override
  String get leaveFamilyQuestion => 'Leave this family?';

  @override
  String get leaveFamilyWarning => 'You will lose access to this family\'s private content. You can join again later with an invitation code.';

  @override
  String get leftFamilySuccessfully => 'You left the family.';

  @override
  String get couldNotLeaveFamily => 'Could not leave the family. Please try again.';

  @override
  String get transferBeforeLeaving => 'Transfer Ownership to Leave';

  @override
  String get ownerCannotLeave => 'Transfer ownership first';

  @override
  String get ownerCannotLeaveDescription => 'The owner protects the family space. Transfer ownership to another member before leaving. If you are the only member, invite a trusted relative first.';

  @override
  String get gotIt => 'Got It';

  @override
  String get developerFamilyDescription => 'A warm private space for playing, sharing, and growing together.';

  @override
  String get developerFamilyMemberName => 'Mariam';

  @override
  String get developerFamilyMemberTwoName => 'Omar';

  @override
  String get missionsSignInRequired => 'You must be signed in to view missions.';

  @override
  String get missionsFamilyRequired => 'Join or create a family before completing missions.';

  @override
  String get missionsLoadError => 'Could not load Family Missions. Please try again.';

  @override
  String get missionGeneric => 'Mission';

  @override
  String get you => 'You';

  @override
  String get whoParticipated => 'Who participated?';

  @override
  String get participantSelectionDescription => 'Choose the family members who actually took part. Family missions require at least 2 participants.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get useCameraAsProof => 'Use the camera as proof';

  @override
  String get choosePhotoOrScreenshot => 'Choose Photo or Screenshot';

  @override
  String get chooseExistingImage => 'Choose an existing image from your device';

  @override
  String get missionImageTooLarge => 'That image is too large. Please choose a smaller image.';

  @override
  String get reviewYourProof => 'Review Your Proof';

  @override
  String get missionProofPrivacyNotice => 'Your image is sent securely to Google Gemini through Sila\'s server only to verify this mission. Sila stores the verdict, not a copy of the image.';

  @override
  String get missionProofConsent => 'I consent to AI verification of this image.';

  @override
  String participantsLabel(String names) {
    return 'Participants: $names';
  }

  @override
  String get explanationOptional => 'Explanation (optional)';

  @override
  String get missionExplanationHint => 'Add useful context that the image may not show clearly.';

  @override
  String get verifyProof => 'Verify Proof';

  @override
  String get aiCheckingMissionProof => 'AI is checking your mission proof...';

  @override
  String get couldNotVerifyMissionProof => 'Could not verify the mission proof. Please try again.';

  @override
  String get needClearerProof => 'We Need Clearer Proof';

  @override
  String get proofNotVerified => 'Proof Not Verified';

  @override
  String verificationFailureDescription(String reason) {
    return '$reason\n\nYou can submit another image or add a clearer explanation.';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get missionAlreadyRewarded => 'This mission has already been rewarded.';

  @override
  String get missionRewardSaveError => 'The proof was verified, but the reward could not be saved. Please try again.';

  @override
  String get familyMissionMinimumParticipants => 'A family mission needs at least 2 participants.';

  @override
  String get missionVerified => 'Mission Verified!';

  @override
  String familyMissionRewardSuccess(int tokens, String participants) {
    return '$tokens tokens were awarded to each participant.\n\n$participants\n\nYour family\'s weekly mission progress has been updated.';
  }

  @override
  String personalMissionRewardSuccess(int tokens) {
    return 'You earned $tokens tokens.\n\nYour weekly mission progress has been updated.';
  }

  @override
  String get nice => 'Nice!';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyChallenge => 'Challenge';

  @override
  String get yourMissions => 'Your Missions';

  @override
  String personalMissionsSubtitle(int count) {
    return '$count personal missions remaining this week';
  }

  @override
  String sharedMissionsSubtitle(int count) {
    return '$count shared missions remaining this week';
  }

  @override
  String get recentlyCompleted => 'Recently Completed';

  @override
  String get doMoreTogether => 'Do More Together';

  @override
  String missionsHeaderDescription(int count) {
    return '$count missions remain on this week\'s board. Verified completions stay complete until the board resets.';
  }

  @override
  String missionsCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed',
      one: '1 completed',
    );
    return '$_temp0';
  }

  @override
  String missionTokensEarnedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mission tokens earned',
      one: '1 mission token earned',
    );
    return '$_temp0';
  }

  @override
  String missionWeekWindow(String start, String end) {
    return 'This week • $start–$end';
  }

  @override
  String personalWeeklyProgress(int completed, int total) {
    return 'Personal progress • $completed/$total';
  }

  @override
  String familyWeeklyProgress(int completed, int total) {
    return 'Family progress • $completed/$total';
  }

  @override
  String get personalWeekComplete => 'Your personal missions are complete!';

  @override
  String get familyWeekComplete => 'Your family completed every shared mission!';

  @override
  String get missionsResetMonday => 'A fresh mission board arrives next Monday.';

  @override
  String get aiProofRequired => 'AI proof required';

  @override
  String get personalLabel => 'Personal';

  @override
  String get missionCategoryOutdoor => 'Outdoor';

  @override
  String get missionCategoryTogetherTime => 'Together Time';

  @override
  String get missionCategoryMemories => 'Memories';

  @override
  String get missionCategoryKindness => 'Kindness';

  @override
  String get missionCategoryConnection => 'Connection';

  @override
  String get missionCategoryFun => 'Fun';

  @override
  String get missionCategoryTeamwork => 'Teamwork';

  @override
  String missionTokenReward(int count) {
    return '+$count tokens';
  }

  @override
  String get aiProofFamilyReward => 'AI proof • reward for each participant';

  @override
  String get aiProofPersonalReward => 'AI proof • reward for you';

  @override
  String completedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get familyMissionLabel => 'Family Mission';

  @override
  String get personalMissionLabel => 'Personal Mission';

  @override
  String familyMissionDetailsReward(int tokens) {
    return 'Choose who participated. The mission can be claimed once by the family, and each participant earns $tokens tokens.';
  }

  @override
  String personalMissionDetailsReward(int tokens) {
    return 'Complete this yourself and earn $tokens tokens.';
  }

  @override
  String get proofGuidance => 'Proof guidance';

  @override
  String get cooldown => 'Cooldown';

  @override
  String missionCooldownDescription(int count) {
    return 'After completion, this mission cannot return for $count days.';
  }

  @override
  String get submitProof => 'Submit Proof';

  @override
  String get notYet => 'Not Yet';

  @override
  String get missionPersonalAppreciationTitle => 'Show Some Appreciation';

  @override
  String get missionPersonalAppreciationDescription => 'Tell one family member something specific that you genuinely appreciate about them.';

  @override
  String get missionPersonalAppreciationProofHint => 'Submit a relevant photo or screenshot and briefly explain what you said or did.';

  @override
  String get missionPersonalHelpTitle => 'Help Without Being Asked';

  @override
  String get missionPersonalHelpDescription => 'Do one genuinely helpful thing for a family member before they ask you.';

  @override
  String get missionPersonalHelpProofHint => 'Submit a relevant or before-and-after photo and explain what you helped with.';

  @override
  String get missionPersonalCallRelativeTitle => 'Call Someone You Love';

  @override
  String get missionPersonalCallRelativeDescription => 'Call or video chat with a relative you have not spoken to recently.';

  @override
  String get missionPersonalCallRelativeProofHint => 'A call screenshot is ideal. Avoid exposing private phone numbers when possible.';

  @override
  String get missionPersonalFamilyStoryTitle => 'Discover a Family Story';

  @override
  String get missionPersonalFamilyStoryDescription => 'Ask a family member to tell you a funny, meaningful, or memorable story from their past.';

  @override
  String get missionPersonalFamilyStoryProofHint => 'Submit a relevant photo and briefly explain what story you learned.';

  @override
  String get missionPersonalMakeDrinkTitle => 'Make Something for Someone';

  @override
  String get missionPersonalMakeDrinkDescription => 'Prepare a drink, snack, or small treat for a family member.';

  @override
  String get missionPersonalMakeDrinkProofHint => 'Submit a photo of what you prepared.';

  @override
  String get missionPersonalMemoryQuestionTitle => 'Ask About an Old Memory';

  @override
  String get missionPersonalMemoryQuestionDescription => 'Ask an older family member about a memorable moment from their childhood.';

  @override
  String get missionPersonalMemoryQuestionProofHint => 'Submit a relevant photo and use the explanation box to briefly describe what you learned.';

  @override
  String get missionPersonalSmallCleanupTitle => 'Fix One Messy Spot';

  @override
  String get missionPersonalSmallCleanupDescription => 'Choose one small messy area at home and organize it properly.';

  @override
  String get missionPersonalSmallCleanupProofHint => 'A before-and-after photo is the strongest proof.';

  @override
  String get missionPersonalKindMessageTitle => 'Send a Kind Message';

  @override
  String get missionPersonalKindMessageDescription => 'Send a thoughtful message to a family member just to make their day better.';

  @override
  String get missionPersonalKindMessageProofHint => 'Submit a screenshot with private or sensitive details hidden if necessary.';

  @override
  String get missionPersonalLearnRecipeTitle => 'Learn a Family Recipe';

  @override
  String get missionPersonalLearnRecipeDescription => 'Ask a relative how to make a family recipe and learn something about where it came from.';

  @override
  String get missionPersonalLearnRecipeProofHint => 'Submit a photo of the recipe, ingredients, preparation, or finished food.';

  @override
  String get missionPersonalMemorySaveTitle => 'Save a Family Memory';

  @override
  String get missionPersonalMemorySaveDescription => 'Choose one meaningful family photo and add it to your memories with a useful description.';

  @override
  String get missionPersonalMemorySaveProofHint => 'Submit the family photo or a screenshot showing the memory you saved.';

  @override
  String get missionPersonalLongHelpTitle => 'Take Over a Chore';

  @override
  String get missionPersonalLongHelpDescription => 'Take over a useful household chore for a family member and complete it properly.';

  @override
  String get missionPersonalLongHelpProofHint => 'Submit a relevant before, during, or after photo.';

  @override
  String get missionPersonalSurpriseTitle => 'Plan a Small Surprise';

  @override
  String get missionPersonalSurpriseDescription => 'Do something thoughtful and unexpected for someone in your family.';

  @override
  String get missionPersonalSurpriseProofHint => 'Submit reasonable proof and explain what the surprise was.';

  @override
  String get missionFamilyWalkTitle => 'Take a Family Walk';

  @override
  String get missionFamilyWalkDescription => 'Spend at least 20 minutes walking together and enjoy the time without rushing.';

  @override
  String get missionFamilyWalkProofHint => 'Submit a photo from the walk showing the activity or location.';

  @override
  String get missionFamilyMealTitle => 'Share a Meal Together';

  @override
  String get missionFamilyMealDescription => 'Sit together for a proper meal and keep phones away while you eat.';

  @override
  String get missionFamilyMealProofHint => 'Submit a photo showing the meal, table, or family activity.';

  @override
  String get missionFamilyPhotoTitle => 'Capture Today';

  @override
  String get missionFamilyPhotoDescription => 'Take a new family photo together and turn an ordinary day into a memory.';

  @override
  String get missionFamilyPhotoProofHint => 'Submit the new family photo created for this mission.';

  @override
  String get missionFamilyPlayTitle => 'Play Together';

  @override
  String get missionFamilyPlayDescription => 'Spend at least 30 minutes playing a game together.';

  @override
  String get missionFamilyPlayProofHint => 'Submit a photo showing the game setup or family activity.';

  @override
  String get missionFamilyCookTitle => 'Cook Something Together';

  @override
  String get missionFamilyCookDescription => 'Prepare a meal, dessert, or snack together instead of leaving all the work to one person.';

  @override
  String get missionFamilyCookProofHint => 'Submit a photo of the preparation or finished food.';

  @override
  String get missionFamilyGameNightTitle => 'Family Game Night';

  @override
  String get missionFamilyGameNightDescription => 'Set aside at least 45 minutes for everyone to play games together.';

  @override
  String get missionFamilyGameNightProofHint => 'Submit a photo of the game setup or family playing together.';

  @override
  String get missionFamilyScreenFreeTitle => 'One Screen-Free Hour';

  @override
  String get missionFamilyScreenFreeDescription => 'Spend a full hour together without phones, television, tablets, or computers.';

  @override
  String get missionFamilyScreenFreeProofHint => 'Submit a photo of what your family did during the screen-free time.';

  @override
  String get missionFamilyCleanupTitle => 'Team Cleanup';

  @override
  String get missionFamilyCleanupDescription => 'Choose one messy area and clean or organize it together from start to finish.';

  @override
  String get missionFamilyCleanupProofHint => 'A before-and-after photo is ideal.';

  @override
  String get missionFamilyOutdoorTitle => 'Outdoor Family Time';

  @override
  String get missionFamilyOutdoorDescription => 'Spend at least 45 minutes doing an outdoor activity together.';

  @override
  String get missionFamilyOutdoorProofHint => 'Submit a photo showing your outdoor activity or location.';

  @override
  String get missionFamilyOldPhotosTitle => 'Explore Old Family Photos';

  @override
  String get missionFamilyOldPhotosDescription => 'Look through older family photos together and talk about the stories behind them.';

  @override
  String get missionFamilyOldPhotosProofHint => 'Submit a photo showing the album, older photos, or memory activity.';

  @override
  String get missionFamilyDessertTitle => 'Make Dessert Together';

  @override
  String get missionFamilyDessertDescription => 'Choose a dessert and make it together from preparation to the final result.';

  @override
  String get missionFamilyDessertProofHint => 'Submit a preparation or finished-dessert photo.';

  @override
  String get missionFamilyPicnicTitle => 'Have a Family Picnic';

  @override
  String get missionFamilyPicnicDescription => 'Prepare something to eat and enjoy a picnic together away from your normal dining table.';

  @override
  String get missionFamilyPicnicProofHint => 'Submit a photo showing the picnic setup, food, or location.';

  @override
  String get missionFamilyVisitRelativeTitle => 'Visit a Relative';

  @override
  String get missionFamilyVisitRelativeDescription => 'Spend meaningful face-to-face time visiting a relative you do not see every day.';

  @override
  String get missionFamilyVisitRelativeProofHint => 'Submit respectful evidence from the visit without exposing unnecessary private information.';

  @override
  String get missionFamilyRecreatePhotoTitle => 'Recreate an Old Family Photo';

  @override
  String get missionFamilyRecreatePhotoDescription => 'Choose an older family picture and recreate its pose or scene together.';

  @override
  String get missionFamilyRecreatePhotoProofHint => 'Submit the recreated photo and explain which old photo inspired it.';

  @override
  String get missionFamilyKindnessProjectTitle => 'Complete a Kindness Project';

  @override
  String get missionFamilyKindnessProjectDescription => 'Work together on something genuinely helpful for another person without expecting a reward from them.';

  @override
  String get missionFamilyKindnessProjectProofHint => 'Submit safe and respectful proof of what your family made or did.';

  @override
  String get officialWins => 'Official Wins';

  @override
  String get dailyWins => 'Daily Wins';

  @override
  String get weeklyWins => 'Weekly Wins';

  @override
  String get monthlyWins => 'Monthly Wins';

  @override
  String get missionsCompleted => 'Missions completed';

  @override
  String get memoriesAdded => 'Memories Added';

  @override
  String get rankingPoints => 'Ranking Points';

  @override
  String get homeRewards => 'Rewards';

  @override
  String get homeRewardsDescription => 'Spend Tokens on family and digital rewards.';

  @override
  String get officialCompetitionRule => 'One official result per family per day. Quick Play results do not affect these rewards.';

  @override
  String dailyWinnerRewardSummary(int tokens, int points) {
    return 'Winner: +$tokens Tokens + $points Ranking Points';
  }

  @override
  String dailyRunnerUpRewardSummary(int points) {
    return 'Runner-up: +$points Ranking Points';
  }

  @override
  String get savingOfficialResult => 'Saving official result...';

  @override
  String get dailyOfficialCompleteEyebrow => 'Daily Challenge complete';

  @override
  String get familyChallengeCompleteTitle => 'Family challenge complete';

  @override
  String get dailyCompleteWithoutWinner => 'Your family showed up, played together, and completed today\'s official challenge.';

  @override
  String dailyCompleteWithWinner(String name) {
    return '$name takes today\'s family crown. Come back tomorrow for a fresh challenge.';
  }

  @override
  String tokenBonus(int count) {
    return '+$count Tokens';
  }

  @override
  String rankingPointBonus(int count) {
    return '+$count RP';
  }

  @override
  String get familyMoment => 'Family moment';

  @override
  String get tieDetected => 'Tie detected';

  @override
  String get tieRewardPendingDescription => 'No Tokens or Ranking Points have been awarded. Only the tied leaders advance to sudden death. No reward is granted until one winner remains.';

  @override
  String get startSuddenDeathTieBreak => 'Start Sudden-Death Tie-Break';

  @override
  String get latestResult => 'Latest Result';

  @override
  String pointsAbbreviation(int count) {
    return '$count pts';
  }

  @override
  String get weeklyCompetitionDescription => 'Four official games. Championship Points accumulate across every round.';

  @override
  String get championshipRewards => 'Championship rewards';

  @override
  String championRewardSummary(int tokens, int points) {
    return 'Champion: +$tokens Tokens + $points RP';
  }

  @override
  String runnerUpRewardSummary(int points) {
    return 'Runner-up: +$points RP';
  }

  @override
  String thirdPlaceRewardSummary(int points) {
    return 'Third place: +$points RP';
  }

  @override
  String get championshipScoringDescription => 'Individual rounds: 1st 10 • 2nd 7 • 3rd 5 • 4th 3 • participation 1\nTeam rounds: winning-team members +1 • losing-team members +0';

  @override
  String get thisWeeksGames => 'This week\'s games';

  @override
  String get roundComplete => 'Round complete';

  @override
  String get upNext => 'Up next';

  @override
  String get roundLocked => 'Locked until previous round is complete';

  @override
  String get savingRound => 'Saving round...';

  @override
  String playGameNumber(int number, String name) {
    return 'Play Game $number: $name';
  }

  @override
  String get finalizingChampionship => 'Finalizing championship...';

  @override
  String get finalizeWeeklyChampionship => 'Finalize Weekly Championship';

  @override
  String get championshipStandings => 'Championship Standings';

  @override
  String roundsPlayed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds played',
      one: '1 round played',
    );
    return '$_temp0';
  }

  @override
  String get weeklyOfficialCompleteEyebrow => 'Weekly Championship complete';

  @override
  String get newFamilyChampion => 'A new family champion';

  @override
  String get weeklyCompleteWithoutChampion => 'Four games, one shared week, and a family story worth remembering.';

  @override
  String weeklyCompleteWithChampion(String name) {
    return '$name is this week\'s Family Champion after four games together.';
  }

  @override
  String get weeklyCrown => 'Weekly crown';

  @override
  String get monthlyCompetitionDescription => 'Four family members. Two semifinals. One final. One champion.';

  @override
  String get monthlyRewards => 'Monthly rewards';

  @override
  String monthlyChampionRewardSummary(int tokens, int points) {
    return 'Champion: +$tokens Tokens + $points RP + Trophy';
  }

  @override
  String semifinalistRewardSummary(int points) {
    return 'Semifinalists: +$points RP';
  }

  @override
  String get chooseFourCompetitors => 'Choose exactly 4 competitors';

  @override
  String get startingMonthlyCup => 'Starting Monthly Cup...';

  @override
  String get startMonthlyCup => 'Start Monthly Cup';

  @override
  String get monthlyParticipantIncomplete => 'Monthly Cup participant data is incomplete.';

  @override
  String get monthlyCupBracket => 'Monthly Cup Bracket';

  @override
  String semifinalNumber(int number) {
    return 'Semifinal $number';
  }

  @override
  String get finalRound => 'FINAL';

  @override
  String gameNameLabel(String name) {
    return 'Game: $name';
  }

  @override
  String versusPlayers(String first, String second) {
    return '$first vs $second';
  }

  @override
  String winnerNameLabel(String name) {
    return 'Winner: $name';
  }

  @override
  String playNamedRound(String round) {
    return 'Play $round';
  }

  @override
  String get monthlyCupChampion => 'Monthly Cup Champion';

  @override
  String get champion => 'Champion';

  @override
  String get monthlyCompleteDescription => 'The family\'s biggest competition ends with a trophy and a memory for the cabinet.';

  @override
  String get cupTrophy => 'Cup trophy';

  @override
  String get tieBreak => 'Tie-Break';

  @override
  String suddenDeathRound(int number) {
    return 'Sudden Death • Round $number';
  }

  @override
  String get counting => 'Counting...';

  @override
  String passPhoneTo(String name) {
    return 'Pass the phone to $name';
  }

  @override
  String get stopAtFiveSeconds => 'Stop when you think exactly 5 seconds have passed.';

  @override
  String get goalFiveSeconds => 'Your goal is to stop as close as possible to exactly 5 seconds.';

  @override
  String get hiddenTimerDescription => 'The timer stays hidden. Closest result wins.';

  @override
  String get start => 'Start';

  @override
  String get stop => 'STOP';

  @override
  String tieBreakWinner(String name) {
    return '$name wins the tie-break!';
  }

  @override
  String secondsFromTarget(String seconds) {
    return 'Only $seconds seconds away from exactly 5.000 seconds.';
  }

  @override
  String get confirmWinner => 'Confirm Winner';

  @override
  String get stillTied => 'Still tied!';

  @override
  String tiedPlayersContinue(int count, int round) {
    return '$count players were equally close. Only those players continue to Round $round.';
  }

  @override
  String startTieBreakRound(int number) {
    return 'Start Tie-Break Round $number';
  }

  @override
  String get gameFamilyEyebrow => 'SILA FAMILY GAME';

  @override
  String get rounds => 'Rounds';

  @override
  String get roundsDescription => 'Choose a quick round or play a longer 3 or 5-round game.';

  @override
  String roundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds',
      one: '$count round',
    );
    return '$_temp0';
  }

  @override
  String get mustBeLoggedInToPlay => 'You must be logged in to play.';

  @override
  String get emojiFamilyRequired => 'Join or create a family before playing Emoji Guess.';

  @override
  String get couldNotLoadFamilyMembers => 'Could not load your family members.';

  @override
  String get familyMemberFallback => 'Family Member';

  @override
  String get emojiGuessSetupDescription => 'Build two teams and decode playful emoji clues before time runs out.';

  @override
  String get whoIsPlaying => 'Who is playing?';

  @override
  String get chooseAtLeastTwoPlayers => 'Choose at least 2 players for the family match.';

  @override
  String get chooseTeams => 'Choose teams';

  @override
  String get assignPlayersToTeams => 'Assign every selected player to Team A or Team B.';

  @override
  String get teamA => 'Team A';

  @override
  String get teamB => 'Team B';

  @override
  String get shuffleTeams => 'Shuffle Teams';

  @override
  String get category => 'Category';

  @override
  String get categoryMovies => 'Movies';

  @override
  String get categoryAnimals => 'Animals';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryPlaces => 'Places';

  @override
  String get categoryMixed => 'Mixed';

  @override
  String get matchPace => 'Match pace';

  @override
  String get puzzlesPerRound => 'Puzzles per round';

  @override
  String get timePerPuzzle => 'Time per puzzle';

  @override
  String secondsShort(int count) {
    return '$count sec';
  }

  @override
  String preparingNamedGame(String game) {
    return 'Preparing $game...';
  }

  @override
  String startNamedGame(String game) {
    return 'Start $game';
  }

  @override
  String teamTurn(String team) {
    return '$team\'s turn';
  }

  @override
  String stealTeam(String team) {
    return 'Steal — $team';
  }

  @override
  String roundPuzzleProgress(int round, int totalRounds, int puzzle, int totalPuzzles) {
    return 'Round $round of $totalRounds • Puzzle $puzzle of $totalPuzzles';
  }

  @override
  String secondsRemaining(int count) {
    return '$count s';
  }

  @override
  String hintLabel(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get typeYourAnswer => 'Type your answer';

  @override
  String get checking => 'Checking...';

  @override
  String get submitAnswer => 'Submit Answer';

  @override
  String teamScore(String team, int score) {
    return '$team: $score';
  }

  @override
  String get puzzleComplete => 'Puzzle Complete';

  @override
  String answerLabel(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get roundResults => 'Round Results';

  @override
  String get nextPuzzle => 'Next Puzzle';

  @override
  String roundNumberComplete(int number) {
    return 'Round $number Complete';
  }

  @override
  String get startTieBreaker => 'Start Tie-Breaker';

  @override
  String get seeFinalResults => 'See Final Results';

  @override
  String startRound(int number) {
    return 'Start Round $number';
  }

  @override
  String tieBreakerTeam(String team) {
    return 'Tie-Breaker — $team';
  }

  @override
  String teamWins(String team) {
    return '$team Wins!';
  }

  @override
  String returnToCompetition(String competition) {
    return 'Return to $competition';
  }

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToGames => 'Back to Games';

  @override
  String noStealAnswer(String answer) {
    return 'No steal.\n\nAnswer: $answer';
  }

  @override
  String teamGuessedCorrectly(String team, int points) {
    return '$team guessed correctly!\n\n+$points points';
  }

  @override
  String teamStolePuzzle(String team, int points) {
    return '$team stole the puzzle!\n\n+$points point';
  }

  @override
  String stealMissedAnswer(String answer) {
    return 'Steal missed.\n\nAnswer: $answer';
  }

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryFamilyFun => 'Family Fun';

  @override
  String get categoryFavorites => 'Favorites';

  @override
  String get categoryHabits => 'Habits';

  @override
  String get categoryMemories => 'Memories';

  @override
  String get categoryMostLikelyTo => 'Most Likely To';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryAtHome => 'At Home';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryActions => 'Actions';

  @override
  String get categoryObjects => 'Objects';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryFunny => 'Funny';

  @override
  String get categoryFriends => 'Friends';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryGeography => 'Geography';

  @override
  String get categoryHistory => 'History';

  @override
  String get categoryGeneralKnowledge => 'General Knowledge';

  @override
  String get categoryActivities => 'Activities';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryUaeHeritage => 'UAE & Heritage';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get pickCategory => 'Pick a category';

  @override
  String get couldNotReachAiOfflinePrompts => 'Could not reach AI. Using offline prompts instead.';

  @override
  String get couldNotReachAiOfflineQuestions => 'Could not reach AI. Using offline questions instead.';

  @override
  String get generatingPrompts => 'Generating prompts...';

  @override
  String get generatingQuestions => 'Generating questions...';

  @override
  String get startGame => 'Start Game';

  @override
  String get startCharades => 'Start Charades';

  @override
  String promptProgress(int current, int total) {
    return 'Prompt $current of $total';
  }

  @override
  String roundProgress(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String get gameProgress => 'Game progress';

  @override
  String get nextPrompt => 'Next Prompt';

  @override
  String get charadesRoundComplete => 'Charades round complete!';

  @override
  String get never => 'Never';

  @override
  String get iHave => 'I Have';

  @override
  String get roundCompleteCelebration => 'Round Complete!';

  @override
  String iHaveCount(int count) {
    return 'I Have: $count';
  }

  @override
  String neverCount(int count) {
    return 'Never: $count';
  }

  @override
  String get changeCategory => 'Change Category';

  @override
  String get truth => 'TRUTH';

  @override
  String get dare => 'DARE';

  @override
  String get done => 'Done';

  @override
  String truthsCompleted(int count) {
    return 'Truths completed: $count';
  }

  @override
  String daresCompleted(int count) {
    return 'Dares completed: $count';
  }

  @override
  String get charadesSetupDescription => 'Choose a theme and a 1, 3, or 5-round game, then act out each prompt without saying the answer.';

  @override
  String get neverSetupDescription => 'Pick a family-friendly theme and choose 1, 3, or 5 prompts for a quick round of surprising stories.';

  @override
  String get truthDareSetupDescription => 'Choose a playful theme and a 1, 3, or 5-round game of safe truths and family-friendly dares.';

  @override
  String get wouldRatherSetupDescription => 'Pick a category, choose 1, 3, or 5 rounds, then discover which playful choices your family makes.';

  @override
  String get wouldYouRatherPrompt => 'Would you rather...';

  @override
  String get chooseMostFunAnswer => 'Choose the answer that sounds the most fun to you.';

  @override
  String get tapAnswerToLock => 'Tap one answer to lock it in.';

  @override
  String youSelectedAnswer(String answer) {
    return 'You selected: $answer';
  }

  @override
  String get seeResults => 'See Results';

  @override
  String get nextRound => 'Next Round';

  @override
  String get greatJob => 'Great job!';

  @override
  String completedRoundsCategory(int rounds, String category) {
    return 'You completed $rounds rounds in the $category category.';
  }

  @override
  String get changeSettings => 'Change Settings';

  @override
  String get triviaFamilyRequired => 'Join or create a family before playing Trivia.';

  @override
  String get couldNotPrepareTrivia => 'Could not prepare Trivia. Please try again.';

  @override
  String get triviaSetupDescription => 'Build two teams, pick a category, and race through family-friendly questions.';

  @override
  String get questionsPerRound => 'Questions per round';

  @override
  String get timePerQuestion => 'Time per question';

  @override
  String questionRoundProgress(int round, int totalRounds, int question, int totalQuestions) {
    return 'Round $round of $totalRounds • Question $question of $totalQuestions';
  }

  @override
  String get questionComplete => 'Question Complete';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String noStealCorrectAnswer(String answer) {
    return 'No steal.\n\nCorrect answer: $answer';
  }

  @override
  String teamAnsweredCorrectly(String team, int points) {
    return '$team answered correctly!\n\n+$points points';
  }

  @override
  String teamStoleQuestion(String team, int points) {
    return '$team stole the question!\n\n+$points point';
  }

  @override
  String stealMissedCorrectAnswer(String answer) {
    return 'Steal missed.\n\nCorrect answer: $answer';
  }

  @override
  String get triviaTie => 'Trivia Tie!';

  @override
  String get tieBreaker => 'TIE-BREAKER';

  @override
  String get oneFinalQuestion => 'One final question decides the winner.';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get joinFamilyWishlist => 'Join a family to use Wishlist rewards.';

  @override
  String get newRequest => 'New Request';

  @override
  String get sent => 'Sent';

  @override
  String get received => 'Received';

  @override
  String get familyNotFound => 'Family not found.';

  @override
  String get noOtherFamilyRewardMembers => 'There are no other family members to request a reward from.';

  @override
  String wishlistRequestSent(String name) {
    return 'Wishlist request sent to $name.';
  }

  @override
  String get noSentRequests => 'No sent requests';

  @override
  String get noSentRequestsDescription => 'Wishlist requests you send to family members will appear here.';

  @override
  String get noReceivedRequests => 'No received requests';

  @override
  String get noReceivedRequestsDescription => 'When a family member requests a reward from you, it will appear here.';

  @override
  String get couldNotLoadWishlist => 'Could not load Wishlist requests.';

  @override
  String get requestedFrom => 'Requested from';

  @override
  String get requestedBy => 'Requested by';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get makeOffer => 'Make Offer';

  @override
  String get decline => 'Decline';

  @override
  String get confirmFulfillment => 'Confirm Fulfillment';

  @override
  String rewardMarkedFulfilled(String reward) {
    return '$reward marked as fulfilled.';
  }

  @override
  String rewardAddedToGoals(String reward) {
    return '$reward was added to your Rewards goals.';
  }

  @override
  String get offerRejected => 'Offer rejected.';

  @override
  String get wishlistRequestDeclined => 'Wishlist request declined.';

  @override
  String offerForReward(String reward) {
    return 'Offer for $reward';
  }

  @override
  String get offerRequirementsDescription => 'Set the progress they must complete after accepting to earn this reward.';

  @override
  String get tokensRequired => 'Tokens required';

  @override
  String get dailyChallengeWins => 'Daily Challenge wins';

  @override
  String get weeklyChampionshipWins => 'Weekly Championship wins';

  @override
  String get monthlyCupWins => 'Monthly Cup wins';

  @override
  String get sendOffer => 'Send Offer';

  @override
  String get addOfferRequirement => 'Add at least one requirement to the offer.';

  @override
  String offerSentTo(String name) {
    return 'Offer sent to $name.';
  }

  @override
  String get chooseRewardRecipient => 'Choose who you want to request this reward from.';

  @override
  String get rewardMinimumLength => 'Enter a reward with at least 3 characters.';

  @override
  String get whatWouldYouLikeToEarn => 'What would you like to earn?';

  @override
  String get chooseMemberForOffer => 'Choose a family member and ask them to make you an offer.';

  @override
  String get requestFrom => 'Request from';

  @override
  String get reward => 'Reward';

  @override
  String get rewardExample => 'Example: Family day out';

  @override
  String get optionalMessage => 'Message (optional)';

  @override
  String get wishlistMessageExample => 'Example: I would like to earn this as a long-term goal.';

  @override
  String get sending => 'Sending...';

  @override
  String get sendRequest => 'Send Request';

  @override
  String personLabel(String label, String name) {
    return '$label: $name';
  }

  @override
  String requirementTokens(int count) {
    return '$count Tokens';
  }

  @override
  String requirementDailyWins(int count) {
    return '$count Daily Challenge wins';
  }

  @override
  String requirementWeeklyWins(int count) {
    return '$count Weekly Championship wins';
  }

  @override
  String requirementMonthlyWins(int count) {
    return '$count Monthly Cup wins';
  }

  @override
  String requirementMissions(int count) {
    return '$count missions completed';
  }

  @override
  String get noRequirementsSet => 'No requirements set.';

  @override
  String get requirements => 'Requirements';

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusOfferMade => 'Offer Made';

  @override
  String get statusActiveGoal => 'Active Goal';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusRedeeming => 'Redeeming';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get wishlistRequests => 'Wishlist Requests';

  @override
  String get myGoals => 'My Goals';

  @override
  String get myGoalsDescription => 'Accepted Wishlist offers appear here and update as you make progress.';

  @override
  String get noActiveGoals => 'No active goals';

  @override
  String get noActiveGoalsDescription => 'Accept a Wishlist offer and your goal will appear here.';

  @override
  String get couldNotLoadGoals => 'Could not load your goals.';

  @override
  String redemptionRequestSent(String name) {
    return 'Redemption request sent to $name.';
  }

  @override
  String agreedWith(String name) {
    return 'Agreed with $name';
  }

  @override
  String get openedFromNotification => 'Opened from notification';

  @override
  String get allRequirementsCompleted => 'All requirements completed!';

  @override
  String get redeemReward => 'Redeem Reward';

  @override
  String get waitingForFulfillment => 'Waiting for the other family member to confirm fulfillment.';

  @override
  String get rewardCompleted => 'Reward completed.';

  @override
  String progressCount(int current, int required) {
    return '$current / $required';
  }

  @override
  String milestonesComplete(int complete, int total) {
    return '$complete of $total milestones complete';
  }

  @override
  String get goalInProgress => 'In progress';

  @override
  String get goalReadyToRedeem => 'Ready to redeem';

  @override
  String get goalAwaitingConfirmation => 'Awaiting confirmation';

  @override
  String get goalFulfilled => 'Fulfilled';

  @override
  String get couldNotLoadRewardsAccount => 'Could not load your Rewards account.';

  @override
  String get joinFamilyFirst => 'Join a family first';

  @override
  String get joinFamilyRewardsDescription => 'Join or create a family to use Wishlist goals and rewards.';

  @override
  String get yourTokens => 'Your Tokens';

  @override
  String get rewardsIntroTitle => 'Turn your progress into rewards';

  @override
  String get rewardsIntroDescription => 'Earn Tokens from competitions and family missions, then use them for family experiences or digital unlocks.';

  @override
  String get gameNoValidResult => 'The game finished without a valid player result.';

  @override
  String get dailyResultMismatch => 'The returned game result does not match today\'s challenge.';

  @override
  String get dailyTieRewardPending => 'The top score is tied. No Daily reward has been granted yet.';

  @override
  String get dailyAlreadyCompleted => 'Today\'s Daily Challenge has already been completed.';

  @override
  String dailyWinnerAnnouncement(String name, int tokens, int points) {
    return '$name won today\'s Daily Challenge! +$tokens Tokens and +$points Ranking Points.';
  }

  @override
  String get dailyOfficialSaveError => 'Could not save today\'s official result. Please try again.';

  @override
  String get weeklySignInRequired => 'You must be signed in to use Weekly Championship.';

  @override
  String get weeklyFamilyRequired => 'Join or create a family before playing Weekly Championship.';

  @override
  String get weeklyLoadError => 'Could not load this week\'s championship. Please try again.';

  @override
  String get weeklyResultMismatch => 'The returned result does not match this championship round.';

  @override
  String get weeklyRoundSaveError => 'Could not save this championship round. Please try again.';

  @override
  String weeklyWinnerAnnouncement(String name, int tokens, int points) {
    return '$name is this week\'s Family Champion! +$tokens Tokens and +$points Ranking Points.';
  }

  @override
  String get weeklyFinalizeError => 'Could not finalize the Weekly Championship. Please try again.';

  @override
  String competitionProgress(int completed, int total) {
    return '$completed of $total official rounds complete';
  }

  @override
  String get backToCompetitions => 'Back to Competitions';

  @override
  String get monthlySignInRequired => 'You must be signed in to use Monthly Cup.';

  @override
  String get monthlyFamilyRequired => 'Join or create a family before starting Monthly Cup.';

  @override
  String get monthlyLoadError => 'Could not load this month\'s cup. Please try again.';

  @override
  String get selectExactlyFourMembers => 'Select exactly 4 family members.';

  @override
  String get monthlyStartError => 'Could not start Monthly Cup. Please try again.';

  @override
  String get monthlyResultMismatch => 'The returned result does not match this Monthly Cup match.';

  @override
  String get monthlyMatchSaveError => 'Could not save this Monthly Cup match. Please try again.';

  @override
  String monthlyWinnerAnnouncement(String name, int tokens, int points) {
    return '$name won the Monthly Cup! +$tokens Tokens and +$points Ranking Points.';
  }

  @override
  String get monthlyFinalizeError => 'Could not finalize Monthly Cup. Please try again.';

  @override
  String competitorsSelected(int selected, int total) {
    return '$selected of $total competitors selected';
  }

  @override
  String get finalStandings => 'Final Standings';

  @override
  String get runnerUp => 'Runner-up';

  @override
  String get semifinalist => 'Semifinalist';

  @override
  String get matchHistory => 'Match History';

  @override
  String officialResultsTitle(String competition) {
    return '$competition Results';
  }

  @override
  String get officialGameResultsReady => 'Official game results are ready. Return to the competition to continue.';

  @override
  String get quickPlayLeaderboard => 'Quick Play Leaderboard';

  @override
  String get quickPlayResultsOnly => 'Session scores only — no Tokens or official Ranking Points change.';

  @override
  String gameCompleteTitle(String game) {
    return '$game Complete!';
  }

  @override
  String get backToQuickPlay => 'Back to Quick Play';

  @override
  String playerWins(String name) {
    return '$name Wins!';
  }

  @override
  String get gameTie => 'It\'s a tie!';

  @override
  String missionProgressSummary(int completed, int total) {
    return '$completed of $total missions completed';
  }

  @override
  String get captionFinalLeaderboard => 'Every vote counted. Here is the final local leaderboard.';

  @override
  String minimumPlayersForGame(String game, int count) {
    return '$game needs at least $count players.';
  }

  @override
  String minimumFamilyMembersForGame(String game, int count) {
    return '$game needs at least $count family members.';
  }

  @override
  String joinOrCreateFamilyBeforeGame(String game) {
    return 'Join or create a family before playing $game.';
  }

  @override
  String couldNotStartGame(String game) {
    return 'Could not start $game. Please try again.';
  }

  @override
  String get preparingGame => 'Preparing game...';

  @override
  String selectedPlayersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players selected',
      one: '1 player selected',
    );
    return '$_temp0';
  }

  @override
  String get everyoneElseLookAway => 'Everyone else should look away.';

  @override
  String iAmPlayer(String name) {
    return 'I\'m $name';
  }

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get viewFinalLeaderboard => 'View Final Leaderboard';

  @override
  String get impostorSetupTitle => 'Set up your mystery';

  @override
  String get impostorSetupDescription => 'Pick one category for every secret word, or keep everyone guessing with a random mix.';

  @override
  String get chooseAtLeastThreePlayers => 'Choose at least 3 family members who are together with you.';

  @override
  String get randomMix => 'Random mix';

  @override
  String get randomMixDescription => 'Every round can surprise you with a different category.';

  @override
  String selectedCategoryDescription(String category) {
    return 'All secret words will come from $category.';
  }

  @override
  String get youAreTheImpostor => 'You are the IMPOSTOR';

  @override
  String categoryLabel(String category) {
    return 'Category: $category';
  }

  @override
  String get impostorRoleInstructions => 'You do not know the secret word.\nBlend in and avoid getting caught.';

  @override
  String get secretWord => 'Secret word';

  @override
  String get rememberSecretWord => 'Remember it. Do not show anyone else.';

  @override
  String get hideMyRole => 'Hide My Role';

  @override
  String clueRoundNumber(int number) {
    return 'Clue Round $number';
  }

  @override
  String get takeTurnsGivingClues => 'Take turns giving one clue aloud.';

  @override
  String get clueRules => 'Do not say the secret word.\nDo not make your clue too obvious.';

  @override
  String get impostorBluffInstructions => 'The Impostor must bluff and try to blend in.';

  @override
  String get everyoneGaveClue => 'Everyone Gave a Clue';

  @override
  String get knowTheImpostorQuestion => 'Do you know who the Impostor is?';

  @override
  String clueRoundComplete(int number) {
    return 'Clue round $number is complete.';
  }

  @override
  String get anotherClueRound => 'Another Clue Round';

  @override
  String get startVoting => 'Start Voting';

  @override
  String get privateVoteInstructions => 'Your vote is private. Everyone else should look away.';

  @override
  String whoIsTheImpostor(String name) {
    return '$name, who is the Impostor?';
  }

  @override
  String get votingInstructions => 'Choose one family member. You cannot vote for yourself.';

  @override
  String get voteResults => 'Vote Results';

  @override
  String voteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get tieVoteAgain => 'Tie — Vote Again';

  @override
  String revealPlayer(String name) {
    return 'Reveal $name';
  }

  @override
  String innocentImpostorEscaped(String innocent, String impostor) {
    return '$innocent was innocent!\n\n$impostor was the Impostor and escaped detection.';
  }

  @override
  String get impostorWasCaught => 'The Impostor Was Caught!';

  @override
  String playerIsImpostor(String name) {
    return '$name is the Impostor.';
  }

  @override
  String get impostorFinalChance => 'You have one final chance.\nGuess the secret word to steal the round.';

  @override
  String get submitGuess => 'Submit Guess';

  @override
  String get enterGuessFirst => 'Enter your guess first.';

  @override
  String caughtButGuessedCorrectly(String name, String word) {
    return '$name was caught, but guessed “$word” correctly and stole the round!';
  }

  @override
  String incorrectImpostorGuess(String name, String guess, String word) {
    return '$name guessed “$guess”.\n\nThe secret word was “$word”.\n\nThe family wins this round!';
  }

  @override
  String get impostorWins => 'Impostor Wins!';

  @override
  String get familyWins => 'Family Wins!';

  @override
  String secretWordLabel(String word) {
    return 'Secret word: $word';
  }

  @override
  String get drawingTurnEachRound => 'Every selected artist gets one drawing turn in each round.';

  @override
  String artistDrawingPrompt(String name) {
    return '$name, your drawing prompt is:';
  }

  @override
  String get rememberDrawingPrompt => 'Remember the prompt. Do not show it to the other players.';

  @override
  String get startDrawing => 'Start Drawing';

  @override
  String get drawingTimeUp => 'Time\'s up!\n\nNobody guessed the drawing this round.';

  @override
  String playerIsDrawing(String name) {
    return '$name is drawing';
  }

  @override
  String get guessAloud => 'Everyone else: guess aloud!';

  @override
  String get brush => 'Brush:';

  @override
  String get thin => 'Thin';

  @override
  String get medium => 'Medium';

  @override
  String get thick => 'Thick';

  @override
  String get undo => 'Undo';

  @override
  String get eraser => 'Eraser';

  @override
  String get eraserOn => 'Eraser On';

  @override
  String get clear => 'Clear';

  @override
  String get someoneGuessedIt => 'Someone Guessed It';

  @override
  String get whoGuessedIt => 'Who guessed it?';

  @override
  String get chooseCorrectGuesser => 'Choose the family member who guessed the drawing correctly.';

  @override
  String drawingCorrectPoints(String guesser, String artist) {
    return '$guesser guessed correctly!\n\n$artist +1 point\n$guesser +1 point';
  }

  @override
  String promptLabel(String prompt) {
    return 'Prompt: $prompt';
  }

  @override
  String get nextArtist => 'Next Artist';

  @override
  String officialMatchInvalidPlayers(String game) {
    return 'This official $game match does not have enough valid family members.';
  }

  @override
  String get timePerTurn => 'Time per turn';

  @override
  String playerSecretWord(String name) {
    return '$name, your word is:';
  }

  @override
  String get dontSayHeading => 'DON\'T SAY:';

  @override
  String get rememberWordCard => 'Remember the card. Don\'t let anyone else see it.';

  @override
  String get startTurn => 'Start Turn';

  @override
  String get turnTimeUp => 'Time\'s up! No points this turn.';

  @override
  String playerIsDescribing(String name) {
    return '$name is describing';
  }

  @override
  String get skip => 'Skip';

  @override
  String get turnSkipped => 'Turn skipped. No points awarded.';

  @override
  String get chooseSecretWordGuesser => 'Choose the player who guessed the secret word correctly.';

  @override
  String clueGiverPointResult(String guesser, String clueGiver) {
    return '$guesser guessed correctly!\n\n$clueGiver +1 point';
  }

  @override
  String sharedPointResult(String guesser, String clueGiver) {
    return '$guesser guessed correctly!\n\n$clueGiver +1 point\n$guesser +1 point';
  }

  @override
  String get turnComplete => 'Turn Complete';

  @override
  String get answerAlreadyUsed => 'That answer was already used this round! Try another one.';

  @override
  String get answerDoesNotFitCategory => 'That does not fit the category. Try again!';

  @override
  String reasonTryAgain(String reason) {
    return '$reason Try again!';
  }

  @override
  String get couldNotCheckAnswer => 'Could not check that answer. Please try again.';

  @override
  String get chooseTogetherPlayers => 'Choose the family members who are together with you. Everyone will share this phone.';

  @override
  String get bombSetupInstructions => 'Answer quickly, pass the phone, and do not repeat an answer.';

  @override
  String get generatingCategories => 'Generating categories...';

  @override
  String playerTurn(String name) {
    return '$name\'s turn';
  }

  @override
  String get sayTypePass => 'Say your answer aloud, type it below, then immediately pass the phone.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get checkingAnswer => 'Checking answer...';

  @override
  String get typeSpokenAnswer => 'Type the answer you just said';

  @override
  String get submitAndPassPhone => 'Submit & Pass Phone';

  @override
  String get bombHiddenTimer => 'The bomb can explode at any moment. The timer is hidden!';

  @override
  String answersUsedThisRound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers used this round',
      one: '1 answer used this round',
      zero: 'No answers used this round',
    );
    return '$_temp0';
  }

  @override
  String get boom => 'BOOM!';

  @override
  String playerHeldBomb(String name) {
    return '$name was holding the bomb!';
  }

  @override
  String get bombSurvivorPoint => 'Everyone else earns 1 point for surviving the round.';

  @override
  String get choosePlayers => 'Choose Players';

  @override
  String get chooseQuickPlayMembers => 'Choose the family members who are together for this Quick Play session.';

  @override
  String get chooseGame => 'Choose Game';

  @override
  String get memoryChallenge => 'Memory Challenge';

  @override
  String get memoryNeedsPhoto => 'Your family needs at least one memory with a photo before playing.';

  @override
  String get memoryChallengeCreateError => 'We could not create a Memory Challenge right now. Please try again.';

  @override
  String get familyMemoryFallback => 'Family Memory';

  @override
  String get howWellRemember => 'How well do you remember?';

  @override
  String get memoryChallengeSetupDescription => 'Sila uses your family photos and stories to create unique questions from moments you shared together.';

  @override
  String get creatingChallenge => 'Creating your challenge...';

  @override
  String get startMemoryChallenge => 'Start Memory Challenge';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get correct => 'Correct!';

  @override
  String correctAnswerLabel(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get nextMemory => 'Next Memory';

  @override
  String get memoryChallengeComplete => 'Memory Challenge Complete!';

  @override
  String scoreProgress(int score, int total) {
    return 'Score: $score / $total';
  }

  @override
  String get couldNotLoadCaptionBattle => 'Could not load Caption Battle';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get captionBattleSetupDescription => 'Everyone captions the same family photo. Then the captions are shuffled and the family votes anonymously.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get captionRulePhoto => 'A real family Memory photo appears each round.';

  @override
  String get captionRuleWrite => 'Each player secretly writes one caption.';

  @override
  String get captionRuleShuffle => 'Captions are shuffled so authors stay hidden.';

  @override
  String get captionRuleVote => 'Everyone votes, but cannot vote for themselves.';

  @override
  String get captionRulePoint => 'Each vote is worth 1 local Quick Play point.';

  @override
  String get promptVariety => 'Prompt variety';

  @override
  String get promptVarietyDescription => 'Choose the kind of creative challenge your family wants.';

  @override
  String get captionStyleSurprise => 'Surprise Me';

  @override
  String get captionStyleStorytelling => 'Storytelling';

  @override
  String get captionStyleHeadlines => 'Headlines & Posts';

  @override
  String get captionStyleWild => 'Wild Ideas';

  @override
  String get familyPhotos => 'Family photos';

  @override
  String get noPhotoMemories => 'No Memories with photos were found.';

  @override
  String photoMemoriesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photo memories available.',
      one: '1 photo memory available.',
    );
    return '$_temp0';
  }

  @override
  String get addPhotoMemoryFirst => 'Add a Memory with a photo first, then return here.';

  @override
  String captionBattleRoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds.',
      one: '1 round.',
    );
    return 'This game will play $_temp0';
  }

  @override
  String get captionRoundPhotoDescription => 'Each round uses a different family photo. More photos unlock the 3 and 5-round options.';

  @override
  String get selectAtLeastTwoFamilyMembers => 'Select at least 2 family members.';

  @override
  String get captionBattleNeedsPhoto => 'Caption Battle needs at least one Memory with a photo.';

  @override
  String get quickPlayNoRanking => 'Quick Play only • No Tokens or global ranking';

  @override
  String takeThePhone(String name) {
    return '$name, take the phone';
  }

  @override
  String get keepCaptionPrivate => 'Make sure nobody else can see your caption.';

  @override
  String get imReady => 'I\'m Ready';

  @override
  String get yourChallenge => 'Your challenge';

  @override
  String get writeYourCaption => 'Write your caption';

  @override
  String get writeCaptionFirst => 'Write a caption before continuing.';

  @override
  String get submitFinalCaption => 'Submit Final Caption';

  @override
  String get privateCaptionVote => 'Vote privately for your favorite caption. You will not be able to vote for your own.';

  @override
  String get showCaptions => 'Show Captions';

  @override
  String chooseFavoriteCaption(String name) {
    return '$name, choose your favorite';
  }

  @override
  String get captionAuthorsHidden => 'Authors stay hidden until everyone votes.';

  @override
  String get cannotVoteOwnCaption => 'You cannot vote for your own caption.';

  @override
  String get captionReveal => 'Caption reveal';

  @override
  String get finalLeaderboard => 'Final Leaderboard';

  @override
  String developerFamilyMemory(int number) {
    return 'Developer Family Memory $number';
  }

  @override
  String subjectPrivateAnswer(String name) {
    return 'Everyone else should look away while $name chooses a private answer.';
  }

  @override
  String guesserPrivateGuess(String guesser, String subject) {
    return '$guesser will privately guess what $subject chose.';
  }

  @override
  String get votesArePrivate => 'Votes are private. Everyone else should look away.';

  @override
  String chooseRealAnswer(String name) {
    return '$name, choose your real answer';
  }

  @override
  String get predictTheirChoice => 'Everyone else will try to predict what you chose.';

  @override
  String whatDidPlayerChoose(String name) {
    return 'What did $name choose?';
  }

  @override
  String makePrivateGuess(String name) {
    return '$name, make your private guess.';
  }

  @override
  String playerChose(String name) {
    return '$name chose:';
  }

  @override
  String get nobodyGuessedCorrectly => 'Nobody guessed correctly!';

  @override
  String playersGuessedCorrectly(String names) {
    return '$names guessed correctly!';
  }

  @override
  String get onePointEach => '+1 point each';

  @override
  String choosePrivately(String name) {
    return '$name, choose privately.';
  }

  @override
  String get submitPrivateVote => 'Submit Private Vote';

  @override
  String playerReceivedMostVotes(String name) {
    return '$name received the most votes!';
  }

  @override
  String get nextVote => 'Next Vote';

  @override
  String get couldNotGenerateMissions => 'Could not prepare Secret Missions. Please try again in a moment.';

  @override
  String get couldNotGenerateNextRound => 'Could not prepare the next round. Please try again.';

  @override
  String get missionTimeUp => 'Time is up! Time to reveal and judge the missions.';

  @override
  String get finishRoundEarlyTitle => 'Finish round early?';

  @override
  String get finishRoundEarlyDescription => 'The timer will stop and everyone will move to mission judging.';

  @override
  String get keepPlaying => 'Keep Playing';

  @override
  String get finishRound => 'Finish Round';

  @override
  String get chooseMissionPlayers => 'Choose the family members playing together on this phone.';

  @override
  String secretMissionSetupSummary(int rounds) {
    String _temp0 = intl.Intl.pluralLogic(
      rounds,
      locale: localeName,
      other: '$rounds rounds',
      one: '1 round',
    );
    return '$_temp0 • 10 minutes per round • 1 secret mission per player each round.';
  }

  @override
  String get secretMissionSetupInstructions => 'Complete your mission naturally without letting the others figure it out.';

  @override
  String generatingRound(int number) {
    return 'Generating Round $number...';
  }

  @override
  String playerProgress(int current, int total) {
    return 'Player $current of $total';
  }

  @override
  String get keepScreenPrivate => 'Make sure nobody else can see the screen.';

  @override
  String get revealMyMission => 'Reveal My Mission';

  @override
  String get yourSecretMission => 'YOUR SECRET MISSION';

  @override
  String get rememberMission => 'Remember it. Do not tell anyone.';

  @override
  String get hideMissionStartRound => 'Hide Mission & Start 10-Minute Round';

  @override
  String get hideMissionPassPhone => 'Hide Mission & Pass Phone';

  @override
  String get missionsAreLive => 'Missions are live!';

  @override
  String get missionsLiveInstructions => 'Put the phone down and act naturally. Complete your mission without making it obvious.';

  @override
  String get timeRemaining => 'TIME REMAINING';

  @override
  String get missionAutoJudge => 'The round will automatically move to judging when the timer reaches 00:00.';

  @override
  String get finishRoundEarly => 'Finish Round Early';

  @override
  String judgeProgress(int current, int total) {
    return 'Judge $current of $total';
  }

  @override
  String get missionCompletedQuestion => 'Did they successfully complete the mission during this round?';

  @override
  String get notCompleted => 'Not Completed';

  @override
  String get completedPlusOne => 'Completed +1';

  @override
  String roundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds remaining',
      one: '1 round remaining',
      zero: 'No rounds remaining',
    );
    return '$_temp0';
  }

  @override
  String get missionCompletedThisRound => 'Mission completed this round';

  @override
  String get missionNotCompletedThisRound => 'Mission not completed this round';

  @override
  String get previewPlayer => 'Preview Player';

  @override
  String get monthlyInvalidWinner => 'The match returned a winner who was not one of the two selected competitors. Please replay the match.';

  @override
  String get myDigitalRewards => 'My Digital Rewards';

  @override
  String get tokenHistory => 'Token History';

  @override
  String get unlockRewardTitle => 'Unlock reward?';

  @override
  String unlockRewardMessage(int cost, String reward) {
    return 'Spend $cost Tokens to permanently unlock \"$reward\"?';
  }

  @override
  String get unlock => 'Unlock';

  @override
  String rewardUnlocked(String reward) {
    return '$reward unlocked!';
  }

  @override
  String rewardEquippedOnSila(String reward) {
    return '$reward equipped across Sila.';
  }

  @override
  String rewardUnequipped(String reward) {
    return '$reward unequipped.';
  }

  @override
  String get collectionLoadFailed => 'Your collection could not be loaded';

  @override
  String get restartAndTryAgain => 'Please restart the app and try again.';

  @override
  String get checkConnectionTryAgain => 'Check your connection and try again.';

  @override
  String get noDigitalRewards => 'No digital rewards yet';

  @override
  String get noDigitalRewardsDescription => 'Unlock cosmetics from Rewards and they will appear here.';

  @override
  String get yourSilaStyle => 'Your Sila style';

  @override
  String get silaStyleDescription => 'Equip one reward from each category. Changes appear everywhere immediately.';

  @override
  String legacyRewardsSafe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count legacy rewards kept safe',
      one: '1 legacy reward kept safe',
    );
    return '$_temp0';
  }

  @override
  String get legacyRewardsDescription => 'These purchases remain owned but are no longer in the active catalog.';

  @override
  String get currentlyEquipped => 'Currently equipped';

  @override
  String get ownedPermanently => 'Owned permanently';

  @override
  String get updating => 'Updating…';

  @override
  String get equip => 'Equip';

  @override
  String get unequip => 'Unequip';

  @override
  String get digitalRewards => 'Digital Rewards';

  @override
  String get digitalRewardsDescription => 'Unlock permanent Sila cosmetics instantly. No approval needed.';

  @override
  String get digitalRewardsLoadFailed => 'Digital Rewards could not be loaded';

  @override
  String get digitalRewardSignInRequired => 'Sign in again to manage your Sila rewards.';

  @override
  String get digitalRewardUnavailable => 'This reward is not available right now.';

  @override
  String get digitalRewardUserNotFound => 'We could not find your Sila account. Please sign in again.';

  @override
  String get digitalRewardFamilyRequired => 'Join or create a family before unlocking rewards.';

  @override
  String get digitalRewardFamilyNotFound => 'We could not find your family. Please check your family settings.';

  @override
  String get digitalRewardNotFamilyMember => 'Your family membership needs to be refreshed before unlocking rewards.';

  @override
  String get digitalRewardAlreadyOwned => 'This reward is already in your collection.';

  @override
  String get digitalRewardInsufficientTokens => 'Keep playing together to earn enough Family Tokens for this reward.';

  @override
  String get digitalRewardNotOwned => 'Unlock this reward before equipping it.';

  @override
  String get digitalRewardInvalid => 'This reward needs to be refreshed before it can be used.';

  @override
  String get digitalRewardUpdateFailed => 'Your reward could not be updated. No Tokens were spent.';

  @override
  String get profileFrames => 'Profile Frames';

  @override
  String get profileBadges => 'Profile Badges';

  @override
  String get profileThemes => 'Profile Themes';

  @override
  String get celebrationEffects => 'Celebration Effects';

  @override
  String get nameplates => 'Nameplates';

  @override
  String get silaWardrobe => 'Sila Wardrobe';

  @override
  String get silaOutfits => 'Sila Outfits';

  @override
  String get silaAuras => 'Sila Auras';

  @override
  String tokensAmount(int count) {
    return '$count Tokens';
  }

  @override
  String get limited => 'Limited';

  @override
  String get permanent => 'Permanent';

  @override
  String needMoreTokens(int count) {
    return 'Need $count more Tokens';
  }

  @override
  String buyForTokens(int count) {
    return 'Buy for $count';
  }

  @override
  String get noTokenActivity => 'No Token activity yet';

  @override
  String get tokenActivityDescription => 'Token earnings and spending will appear here.';

  @override
  String get tokenHistoryLoadFailed => 'Could not load Token history.';

  @override
  String get tokenEarned => 'Earned';

  @override
  String get tokenSpent => 'Spent';

  @override
  String get tokenRefunded => 'Refunded';

  @override
  String get tokenAdjusted => 'Adjusted';

  @override
  String get codeBreakerTitle => 'Code Breaker';

  @override
  String get codeBreakerDescription => 'Crack the hidden code using logic. Fewer attempts and faster solves earn more points.';

  @override
  String get chooseExactlyTwoPlayers => 'Choose exactly 2 players.';

  @override
  String get codeBreakerRoundsDescription => 'Both players crack a new code in every round.';

  @override
  String get startCodeBreaker => 'Start Code Breaker';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get codeEasyDescription => '3-symbol codes with no repeated symbols.';

  @override
  String get codeMediumDescription => '4-symbol codes with a larger symbol pool.';

  @override
  String get codeHardDescription => '5-symbol codes where symbols may repeat.';

  @override
  String difficultyValue(String difficulty) {
    return '$difficulty Difficulty';
  }

  @override
  String get otherPlayerLookAway => 'The other player should look away until this turn is finished.';

  @override
  String playerRound(String name, int round) {
    return '$name — Round $round';
  }

  @override
  String codeDifficultySummary(String difficulty, int length) {
    return '$difficulty • $length-symbol code';
  }

  @override
  String get chooseSymbols => 'Choose symbols';

  @override
  String get tryCode => 'Try Code';

  @override
  String attemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String get previousGuesses => 'Previous Guesses';

  @override
  String correctPositions(int count) {
    return '✅ $count in the correct position';
  }

  @override
  String misplacedSymbols(int count) {
    return '🔄 $count correct but in the wrong position';
  }

  @override
  String get codeCracked => 'Code Cracked!';

  @override
  String secondsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String pointsEarned(int count) {
    return '+$count points';
  }

  @override
  String passToPlayer(String name) {
    return 'Pass to $name';
  }

  @override
  String roundDifficultySummary(int rounds, String difficulty) {
    String _temp0 = intl.Intl.pluralLogic(
      rounds,
      locale: localeName,
      other: '$rounds rounds',
      one: '1 round',
    );
    return '$_temp0 • $difficulty';
  }

  @override
  String attemptTimeSummary(int attempts, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      attempts,
      locale: localeName,
      other: '$attempts attempts',
      one: '1 attempt',
    );
    return '$_temp0 • $seconds s';
  }

  @override
  String get returnToCompetitionAction => 'Return to Competition';

  @override
  String get riskItTitle => 'Risk It';

  @override
  String get riskItDescription => 'Build a points pot, bank it safely, or risk everything for a bigger score.';

  @override
  String get riskItRoundsDescription => 'Both players get one private turn per round.';

  @override
  String get startRiskIt => 'Start Risk It';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get preparingAiQuestions => 'AI is preparing your questions...';

  @override
  String get privateTurnLookAway => 'The other player should look away during this turn.';

  @override
  String roundDifficulty(int round, String difficulty) {
    return 'Round $round • $difficulty';
  }

  @override
  String get currentPot => 'CURRENT POT';

  @override
  String questionWorth(int points) {
    return 'This question is worth +$points';
  }

  @override
  String get unbankedPot => 'Unbanked Pot';

  @override
  String nextCorrectWorth(int points) {
    return 'Next correct answer: +$points';
  }

  @override
  String bankPoints(int points) {
    return 'Bank $points Points';
  }

  @override
  String get riskItAction => 'RISK IT';

  @override
  String get riskWarning => 'One wrong answer and your entire unbanked pot is lost.';

  @override
  String get bust => 'BUST!';

  @override
  String get pointsBanked => 'Points Banked!';

  @override
  String playerLostPot(String name) {
    return '$name lost the unbanked pot.';
  }

  @override
  String playerBankedPoints(String name, int points) {
    return '$name banked $points points.';
  }

  @override
  String get seeRoundResults => 'See Round Results';

  @override
  String playerScore(String name, int score) {
    return '$name: $score';
  }

  @override
  String riskFinalSummary(int rounds, String difficulty, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      rounds,
      locale: localeName,
      other: '$rounds rounds',
      one: '1 round',
    );
    return '$_temp0 • $difficulty • $category';
  }

  @override
  String get couldNotPrepareAiQuestions => 'Could not prepare the AI questions. Please try again.';

  @override
  String get attackOrDefendTitle => 'Attack or Defend';

  @override
  String get attackOrDefendDescription => 'Answer AI challenges, build energy, attack your rival, and defend your hearts.';

  @override
  String get whoIsBattling => 'Who is battling?';

  @override
  String get bestOf => 'Best Of';

  @override
  String get bestOfDescription => 'Best of 1, 3, or 5 battles. The match ends as soon as someone reaches the required wins.';

  @override
  String get startBattle => 'Start Battle';

  @override
  String get preparingAiBattle => 'AI is preparing your battle...';

  @override
  String battleBestOf(int battle, int rounds) {
    return 'Battle $battle • Best of $rounds';
  }

  @override
  String playerIsAttacking(String name) {
    return '$name is attacking!';
  }

  @override
  String playerMustBlock(String name) {
    return '$name must answer correctly to block the attack.';
  }

  @override
  String get otherPlayerLookAwayShort => 'The other player should look away.';

  @override
  String get defendAction => '🛡️ DEFEND!';

  @override
  String get earnEnergyAction => '⚡ EARN ENERGY';

  @override
  String get shieldActive => '🛡️ Shield';

  @override
  String chooseYourMove(String name) {
    return '$name, choose your move';
  }

  @override
  String energyAvailable(int count) {
    return 'Energy available: ⚡ $count';
  }

  @override
  String get attackMove => '⚔️ Attack';

  @override
  String get attackMoveDescription => 'Costs 1 energy • Defender gets 10 seconds';

  @override
  String get shieldMove => '🛡️ Shield';

  @override
  String get shieldMoveDescription => 'Costs 1 energy • Blocks your next failed defense';

  @override
  String get powerAttackMove => '🔥 Power Attack';

  @override
  String get powerAttackMoveDescription => 'Costs 2 energy • Defender gets 7 seconds';

  @override
  String get superAttackMove => '💥 Super Attack';

  @override
  String get superAttackMoveDescription => 'Costs 3 energy • 5 seconds • 2 damage if missed';

  @override
  String get saveEnergyEndTurn => 'Save Energy & End Turn';

  @override
  String battleNumberComplete(int number) {
    return 'Battle $number Complete!';
  }

  @override
  String startBattleNumber(int number) {
    return 'Start Battle $number';
  }

  @override
  String playerWinsBattle(String name) {
    return '$name wins the battle!';
  }

  @override
  String battleFinalSummary(int rounds, String difficulty, String category) {
    return 'Best of $rounds • $difficulty • $category';
  }

  @override
  String get couldNotPrepareAiBattle => 'Could not prepare the AI battle. Please try again.';

  @override
  String get duelGames => 'Duel Games';

  @override
  String get duelGamesSubtitle => 'Head-to-head games built specifically for 2 players.';

  @override
  String get familyGames => 'Family Games';

  @override
  String get familyGamesSubtitle => 'Play together with 2 or more family members.';

  @override
  String get partyGamesSectionSubtitle => 'Casual games made for laughs and group fun.';

  @override
  String get logicDuel => 'LOGIC DUEL';

  @override
  String get battleDuel => 'BATTLE DUEL';

  @override
  String get highStakesDuel => 'HIGH-STAKES DUEL';
}
