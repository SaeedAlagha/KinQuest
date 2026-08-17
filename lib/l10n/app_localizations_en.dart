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

  @override
  String get navHome => 'Home';

  @override
  String get navMemories => 'Memories';

  @override
  String get navPlay => 'Play';

  @override
  String get navMissions => 'Missions';

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
}
