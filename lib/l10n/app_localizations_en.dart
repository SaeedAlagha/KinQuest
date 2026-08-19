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
  String get uaeFamilyYearThemeDescription => 'Warm family colors inspired by the UAE';

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

  @override
  String get welcomePrivateFamilySpace => 'A private family space for shared stories, playful challenges, and the moments that keep everyone connected.';

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
  String get passwordRecoveryComing => 'Password recovery will be added with Firebase.';

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
  String get deleteMemoryQuestion => 'Delete memory?';

  @override
  String get deleteMemoryWarning => 'This memory will be permanently removed from your family memories.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get memoryNotFound => 'Memory not found.';

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
    return '$tokens tokens were awarded to each participant.\n\n$participants\n\nA new shared family mission has been added.';
  }

  @override
  String personalMissionRewardSuccess(int tokens) {
    return 'You earned $tokens tokens.\n\nA new personal mission has been added.';
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
    return '$count personal missions just for you';
  }

  @override
  String sharedMissionsSubtitle(int count) {
    return '$count shared missions — complete each once as a family';
  }

  @override
  String get recentlyCompleted => 'Recently Completed';

  @override
  String get doMoreTogether => 'Do More Together';

  @override
  String missionsHeaderDescription(int count) {
    return '$count active missions, AI-verified proof, fair rewards, and new challenges as you progress.';
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
  String get missionsCompleted => 'Missions Completed';

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
}
