// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'صلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceDescription => 'اختر مظهر صلة في جميع أنحاء التطبيق';

  @override
  String get selectAppearance => 'اختر سمة صلة';

  @override
  String get silaLightTheme => 'صلة الفاتح';

  @override
  String get silaLightThemeDescription => 'مظهر مشرق وهادئ ومألوف';

  @override
  String get darkTheme => 'الوضع الداكن';

  @override
  String get darkThemeDescription => 'ألوان مريحة للأوقات المسائية';

  @override
  String get uaeFamilyYearTheme => 'عام الأسرة الإماراتي 2026';

  @override
  String get uaeFamilyYearThemeDescription => 'أقواس تراثية ودفء المجلس وألوان تجسّد وحدتنا';

  @override
  String get spaceTheme => 'العائلة الكونية';

  @override
  String get spaceThemeDescription => 'مغامرات بين النجوم ومدارات مضيئة وسحر الفضاء';

  @override
  String get khalifaUniversityTheme => 'مختبر جامعة خليفة للمستقبل';

  @override
  String get khalifaUniversityThemeDescription => 'هوية ابتكار زرقاء ودقيقة مستوحاة من جامعة خليفة';

  @override
  String get desertNightsTheme => 'ليالي الصحراء';

  @override
  String get desertNightsThemeDescription => 'كثبان تحت ضوء القمر وغروب نحاسي وسماء ليلية فاخرة';

  @override
  String get pearlLagoonTheme => 'بحيرة اللؤلؤ';

  @override
  String get pearlLagoonThemeDescription => 'لآلئ مضيئة ولمسات مرجانية ومياه خليجية هادئة';

  @override
  String get themeStudio => 'استوديو السمات';

  @override
  String get themeStudioDescription => 'اجمعوا رموز العائلة معًا وافتحوا المظهر الذي تحبه العائلة كلها.';

  @override
  String themeTokenBalance(int tokens) {
    return '$tokens من رموز العائلة';
  }

  @override
  String get themeIncluded => 'متضمنة';

  @override
  String get themeOwned => 'مملوكة';

  @override
  String themeTokenPrice(int tokens) {
    return '$tokens رمزًا';
  }

  @override
  String unlockThemeTitle(String theme) {
    return 'فتح $theme؟';
  }

  @override
  String unlockThemeMessage(int tokens) {
    return 'هل تريد إنفاق $tokens من رموز العائلة لفتح هذه السمة بشكل دائم؟';
  }

  @override
  String unlockForTokens(int tokens) {
    return 'فتح مقابل $tokens';
  }

  @override
  String get notEnoughTokensTitle => 'واصلوا اللعب معًا';

  @override
  String notEnoughTokensMessage(int cost, int balance) {
    return 'تكلفة هذه السمة $cost رمزًا، ورصيد عائلتك الحالي $balance.';
  }

  @override
  String themeUnlocked(String theme) {
    return 'أصبحت سمة $theme ملككم الآن!';
  }

  @override
  String get themeUnlockFailed => 'تعذر فتح السمة، ولم يتم خصم أي رمز.';

  @override
  String get signInToUnlockThemes => 'سجّل الدخول وانضم إلى عائلة لفتح سمات المكافآت.';

  @override
  String get themeUnlockBenefit => 'فتح لمرة واحدة • وتبقى مع حسابك على أجهزتك';

  @override
  String get close => 'إغلاق';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get manageReminders => 'إدارة التذكيرات والتنبيهات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get passwordAccountSecurity => 'كلمة المرور وأمان الحساب';

  @override
  String get allowSilaReminders => 'السماح بتذكيرات صلة';

  @override
  String get dailyChallenge => 'التحدي اليومي';

  @override
  String get dailyChallengeReminder => 'ذكرني بالتحدي العائلي اليومي';

  @override
  String get familyMissions => 'المهام العائلية';

  @override
  String get familyMissionsReminder => 'ذكرني بالمهام العائلية';

  @override
  String get competitions => 'المنافسات';

  @override
  String get competitionReminder => 'تذكيرات البطولة الأسبوعية والكأس الشهري';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyDescription => 'محتوى عائلتك مرتبط بحسابك المسجل وعائلتك.';

  @override
  String get accountEmail => 'البريد الإلكتروني للحساب';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get sendPasswordReset => 'إرسال رسالة لإعادة تعيين كلمة المرور';

  @override
  String get passwordResetSent => 'تم إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get noEmailAvailable => 'لا يوجد بريد إلكتروني متاح لهذا الحساب.';

  @override
  String get couldNotSendReset => 'تعذر إرسال رسالة إعادة تعيين كلمة المرور.';

  @override
  String get couldNotLoadNotifications => 'تعذر تحميل تفضيلات الإشعارات.';

  @override
  String get couldNotSaveNotifications => 'تعذر حفظ تفضيلات الإشعارات.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSila => 'صلة';

  @override
  String get navMemories => 'الذكريات';

  @override
  String get navPlay => 'اللعب';

  @override
  String get navMissions => 'المهام';

  @override
  String get navRewards => 'المكافآت';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get developerFamilyPreview => 'معاينة عائلة المطوّر • بيانات تجريبية فقط';

  @override
  String get exit => 'خروج';

  @override
  String get noUserSignedIn => 'لا يوجد مستخدم مسجّل الدخول حاليًا.';

  @override
  String get silaMember => 'عضو في صلة';

  @override
  String get noFamilyJoined => 'لم تنضم إلى عائلة';

  @override
  String get yourFamily => 'عائلتك';

  @override
  String get developerPreviewMemoryReadOnly => 'معاينة المطوّر للعرض فقط. لم تتم إضافة أي ذكرى.';

  @override
  String get todaysDailyChallenge => 'تحدي اليوم';

  @override
  String get dailyChallengeHomeDescription => 'أكملوا تحدي العائلة اليومي واكسبوا رموزًا إضافية.';

  @override
  String get growingInUnity => 'ننمو بوحدتنا';

  @override
  String get smallMomentsStrongerBonds => 'لحظات صغيرة، روابط أقوى';

  @override
  String get homeBondDescription => 'اصنعوا ذكرى أو العبوا معًا—طرق بسيطة لتبقوا قريبين كل يوم.';

  @override
  String get addMemory => 'أضف ذكرى';

  @override
  String get addMemoryDescription => 'احفظ صورة أو فيديو أو قصة من اليوم.';

  @override
  String get challengeFamily => 'تحدَّ العائلة';

  @override
  String get challengeFamilyDescription => 'ابدأ منافسة ودية وشاركوا الضحك.';

  @override
  String welcomeName(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get silaFamilySpace => 'مساحة صلة العائلية • SILA';

  @override
  String get rootsBondsGrowth => 'جذور • روابط • نمو';

  @override
  String familyMembersConnected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count من أفراد العائلة مرتبطون بالقصص واللعب واللحظات المشتركة.',
      many: '$count فردًا من العائلة مرتبطون بالقصص واللعب واللحظات المشتركة.',
      few: '$count أفراد من العائلة مرتبطون بالقصص واللعب واللحظات المشتركة.',
      two: 'فردان من العائلة متصلان بالقصص واللعب واللحظات المشتركة.',
      one: 'فرد واحد من العائلة متصل بالقصص واللعب واللحظات المشتركة.',
      zero: 'لا يوجد أفراد مرتبطون بعد.',
    );
    return '$_temp0';
  }

  @override
  String get familyOverview => 'نظرة على العائلة';

  @override
  String get familyMembers => 'أفراد العائلة';

  @override
  String get familyTokens => 'رموز العائلة';

  @override
  String get games => 'الألعاب';

  @override
  String get gamesEyebrow => 'عام الأسرة • روابط تنمو باللعب';

  @override
  String get gamesHeading => 'اختاروا لعبتكم العائلية المفضلة';

  @override
  String get gamesDescription => 'شاركوا ضحكة سريعة أو سؤالًا عميقًا أو تحديًا يقرّب جميع الأجيال.';

  @override
  String get familyQuiz => 'اختبار العائلة';

  @override
  String get familyQuizDescription => 'شاركوا إجابات حقيقية واكتشفوا مدى معرفة أفراد العائلة بعضهم ببعض.';

  @override
  String get connectedPlay => 'لعب يقوّي الروابط';

  @override
  String get trivia => 'معلومات عامة';

  @override
  String get triviaDescription => 'تحدّوا عائلتكم بالأسئلة وتنافسوا لتحقيق أعلى نتيجة.';

  @override
  String get knowledge => 'معرفة';

  @override
  String get emojiGuess => 'خمّن الإيموجي';

  @override
  String get emojiGuessDescription => 'فكّوا رموز الإيموجي وتنافسوا لتحقيق أعلى نتيجة.';

  @override
  String get guessingGame => 'لعبة تخمين';

  @override
  String get partyGames => 'ألعاب جماعية';

  @override
  String get partyGamesDescription => 'ألعاب عائلية سريعة مليئة بالضحك والمرح.';

  @override
  String get fourGamesInside => '٤ ألعاب بالداخل';

  @override
  String get familyImpostor => 'الدخيل بين العائلة';

  @override
  String get familyImpostorDescription => 'اكتشفوا الدخيل الخفي عبر التلميحات والنقاش وتصويت العائلة.';

  @override
  String get socialDeduction => 'استنتاج اجتماعي';

  @override
  String get secretMission => 'مهمة سرية';

  @override
  String get secretMissionDescription => 'أنجز مهمة خفية من دون أن تكتشف عائلتك ما تفعله.';

  @override
  String get secretChallenge => 'تحدٍّ سري';

  @override
  String get captionBattle => 'معركة التعليقات';

  @override
  String get captionBattleDescription => 'اكتبوا تعليقات على صور العائلة وصوّتوا بسرية وتوّجوا الأكثر طرافة.';

  @override
  String get photoParty => 'مرح الصور';

  @override
  String get passTheBomb => 'مرّر القنبلة';

  @override
  String get passTheBombDescription => 'أجب بسرعة ومرّر الهاتف وتجنّب أن تكون ممسكًا به عند انتهاء المؤقت الخفي.';

  @override
  String get fastFamilyFun => 'مرح عائلي سريع';

  @override
  String get drawAndGuess => 'ارسم وخمّن';

  @override
  String get drawAndGuessDescription => 'ارسم تلميحات يولدها الذكاء الاصطناعي بينما تحاول عائلتك التخمين.';

  @override
  String get creativePlay => 'لعب إبداعي';

  @override
  String get dontSayIt => 'لا تقلها';

  @override
  String get dontSayItDescription => 'صِف الكلمة السرية من دون نطق أي من الكلمات الممنوعة.';

  @override
  String get wordChallenge => 'تحدي الكلمات';

  @override
  String get openGame => 'افتح اللعبة';

  @override
  String get preview => 'معاينة';

  @override
  String get wouldYouRather => 'ماذا تفضّل؟';

  @override
  String get wouldYouRatherDescription => 'اختر بين خيارين مرحين.';

  @override
  String get charades => 'التمثيل الصامت';

  @override
  String get charadesDescription => 'مثّل تلميحات مبتكرة أمام جميع أفراد العائلة.';

  @override
  String get neverHaveIEver => 'لم أفعلها من قبل';

  @override
  String get neverHaveIEverDescription => 'شاركوا مواقف ومفاجآت عائلية لطيفة.';

  @override
  String get truthOrDare => 'صراحة أم تحدٍّ';

  @override
  String get truthOrDareDescription => 'اختر سؤال صراحة لطيفًا أو تحديًا ممتعًا.';

  @override
  String get partyGamesHeading => 'ألعاب سريعة. ضحكات كبيرة.';

  @override
  String get partyGamesSubtitle => 'اختر لعبة ومرّر الجهاز بينكم—من دون إعداد مسبق.';

  @override
  String get gameFutureUpdate => 'سيتم تنفيذ هذه اللعبة في تحديث قادم.';

  @override
  String get playTogether => 'العبوا معًا';

  @override
  String get playTogetherDescription => 'اجتمعوا واختاروا طريقة اللعب ثم اختاروا لعبة.';

  @override
  String get quickPlay => 'لعب سريع';

  @override
  String get quickPlayDescription => 'اختاروا أي لعبة والعبوا معًا على هاتف واحد، من دون رموز أو ترتيب رسمي.';

  @override
  String get quickPlayReward => 'للمرح فقط • من دون رموز';

  @override
  String get dailyChallengeCompetitionDescription => 'تنافسوا في لعبة اليوم المختارة. يحصل الفائز على رموز.';

  @override
  String get dailyChallengeCompetitionReward => 'رموز للفائز';

  @override
  String get weeklyChampionship => 'البطولة الأسبوعية';

  @override
  String get weeklyChampionshipDescription => 'تنافسوا عبر عدة جولات ليصبح أحدكم بطل العائلة لهذا الأسبوع.';

  @override
  String get weeklyChampionshipReward => 'أمنية عائلية';

  @override
  String get monthlyCup => 'الكأس الشهري';

  @override
  String get monthlyCupDescription => 'أكبر منافسة شهرية للعائلة. اربحوا كأسًا ورموزًا إضافية.';

  @override
  String get monthlyCupReward => 'كأس ورموز إضافية';

  @override
  String rewardLabel(String reward) {
    return 'الجائزة: $reward';
  }

  @override
  String get view => 'عرض';

  @override
  String get familyTrophyCabinet => 'خزانة جوائز العائلة';

  @override
  String get familyTrophyCabinetDescription => 'سيظهر هنا أبطال البطولات الأسبوعية والشهرية السابقة.';

  @override
  String get leaderboard => 'لوحة المتصدرين';

  @override
  String get leaderboardSignIn => 'سجّل الدخول لعرض لوحة متصدري عائلتك.';

  @override
  String get leaderboardJoinFamily => 'انضم إلى عائلة أو أنشئ واحدة لعرض لوحة المتصدرين.';

  @override
  String get leaderboardLoadError => 'تعذر تحميل لوحة متصدري العائلة.';

  @override
  String get leaderboardNoMembers => 'لم يتم العثور على أفراد في العائلة.';

  @override
  String get familyLeaderboard => 'لوحة متصدري العائلة';

  @override
  String get familyMember => 'فرد من العائلة';

  @override
  String tokenCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رمز',
      many: '$count رمزًا',
      few: '$count رموز',
      two: 'رمزان',
      one: 'رمز واحد',
      zero: 'لا رموز',
    );
    return '$_temp0';
  }

  @override
  String get developerFamilyLeaderboard => 'لوحة متصدري عائلة المطوّر';

  @override
  String get competitionFutureUpdate => 'سيتم تنفيذ نظام هذه المنافسة في تحديث قادم.';

  @override
  String get familyQuizDay => 'يوم اختبار العائلة';

  @override
  String get familyQuizDayDescription => 'اكتشفوا اليوم مدى معرفة أفراد عائلتكم بعضهم ببعض في اختبار العائلة.';

  @override
  String get memoryChallengeDay => 'يوم تحدي الذكريات';

  @override
  String get memoryChallengeDayDescription => 'عودوا إلى لحظاتكم العائلية واختبروا مدى تذكّركم لها.';

  @override
  String get familyMissionDay => 'يوم المهمة العائلية';

  @override
  String get familyMissionDayDescription => 'أنجزوا نشاطًا هادفًا معًا من المهام العائلية.';

  @override
  String get partyGameDay => 'يوم الألعاب الجماعية';

  @override
  String get partyGameDayDescription => 'اختاروا لعبة عائلية سريعة وشاركوا بعض الضحكات.';

  @override
  String get dailyChallengeSignInRequired => 'يجب تسجيل الدخول لاستخدام التحدي اليومي.';

  @override
  String get dailyChallengeFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل لعب التحدي اليومي.';

  @override
  String get dailyChallengeLoadError => 'تعذر تحميل تحدي اليوم. يرجى المحاولة مجددًا.';

  @override
  String get dailyChallengeCompleteMessage => 'اكتمل التحدي اليومي! ربحت ١٠ رموز.';

  @override
  String get dailyChallengeAlreadyClaimed => 'لقد حصلت بالفعل على مكافأة تحدي اليوم.';

  @override
  String get dailyChallengeSaveError => 'تعذر إكمال التحدي اليومي. يرجى المحاولة مجددًا.';

  @override
  String get todaysFamilyChallenge => 'تحدي العائلة اليوم';

  @override
  String get dailyReward => 'المكافأة اليومية';

  @override
  String get dailyRewardDescription => '+١٠ رموز وتقدّم في سلسلة الأيام';

  @override
  String get dailyChallengeCompleted => 'أكملت تحدي اليوم. عد غدًا لتحدٍّ جديد!';

  @override
  String get playTodaysChallenge => 'العب تحدي اليوم';

  @override
  String get savingCompletion => 'جارٍ حفظ الإنجاز...';

  @override
  String get iCompletedIt => 'أكملت التحدي';

  @override
  String get openChallengeBeforeClaiming => 'افتح تحدي اليوم قبل طلب المكافأة.';

  @override
  String get welcomePrivateFamilySpace => 'مساحة عائلية خاصة للقصص المشتركة والتحديات الممتعة واللحظات التي تبقي الجميع على تواصل.';

  @override
  String get mascotName => 'صلة';

  @override
  String get mascotSemanticLabel => 'صلة، رفيق عائلتك';

  @override
  String get mascotWelcomeMessage => 'مرحبًا! أنا صلة. سأساعد عائلتكم على اللعب وصنع الذكريات والتقارب.';

  @override
  String mascotHomeMessage(String name) {
    return 'هل أنت مستعد للحظة عائلية جميلة يا $name؟';
  }

  @override
  String get mascotGameSetupMessage => 'سأرشدكم خطوة بخطوة. اختاروا الإعدادات ولنبدأ اللعب!';

  @override
  String get mascotThinkingMessage => 'أجهّز شيئًا مميزًا لعائلتكم...';

  @override
  String get mascotOopsMessage => 'لم تنجح هذه المحاولة بعد. لنجرب معًا مرة أخرى!';

  @override
  String get mascotCelebrationMessage => 'عمل جماعي رائع! كل لحظة تجمعكم تجعل رابطتكم أقوى.';

  @override
  String get silaStudioTitle => 'استوديو صلة';

  @override
  String get silaStudioSubtitle => 'اجعلوا رفيق العائلة مميزًا بطريقتكم.';

  @override
  String get silaStudioTapHint => 'اضغطوا على صلة أو اختاروا حركة لتشاهدوه ينبض بالحياة.';

  @override
  String get silaStudioCloset => 'الخزانة';

  @override
  String get silaStudioClosetDescription => 'جرّبوا التنسيقات قبل فتحها نهائيًا بعملات العائلة.';

  @override
  String get silaStudioHeadwear => 'أغطية الرأس';

  @override
  String get silaStudioOutfits => 'الأزياء';

  @override
  String get silaStudioAuras => 'الهالات';

  @override
  String get silaStudioOwned => 'مملوك';

  @override
  String get silaStudioEquipped => 'مجهّز';

  @override
  String get silaStudioEquip => 'تجهيز';

  @override
  String get silaStudioUnequip => 'إزالة';

  @override
  String silaStudioUnlock(int tokens) {
    return 'افتح مقابل $tokens';
  }

  @override
  String silaStudioNotEnoughTokens(int tokens) {
    return 'تحتاج $tokens عملة إضافية';
  }

  @override
  String get silaStudioPermanent => 'دائم';

  @override
  String get silaStudioTryOn => 'تجربة';

  @override
  String get silaStudioReactionHover => 'تحليق';

  @override
  String get silaStudioReactionReady => 'جاهز للعب';

  @override
  String get silaStudioReactionThink => 'تفكير';

  @override
  String get silaStudioReactionCelebrate => 'احتفال';

  @override
  String get silaStudioWelcomeMessage => 'أهلًا بكم في استوديو صلة! نسّقوا مظهري وجرّبوا حركاتي وخذوني إلى لعبتكم التالية.';

  @override
  String get silaStudioUpdateSuccess => 'مظهر صلة الجديد جاهز في كل مكان.';

  @override
  String get silaStudioUnlockSuccess => 'تم الفتح والتجهيز! لدى صلة مظهر جديد.';

  @override
  String get silaStudioLoadError => 'تعذر تحميل خزانة صلة. حاولوا مرة أخرى.';

  @override
  String get silaGameCoachMessage => 'أنا معكم—العبوا بإنصاف وشجّعوا بحماس واستمتعوا معًا!';

  @override
  String get uaeYearOfFamily2026 => 'عام الأسرة في الإمارات ٢٠٢٦';

  @override
  String get everyBondHelpsFamilyGrow => 'كل رابطة تساعد العائلة على النمو';

  @override
  String get silaEverydayMoments => 'تحوّل صلة اللحظات اليومية إلى جذور أقوى وروابط أقرب ونمو مشترك.';

  @override
  String get familyMomentsStayPrivate => 'تبقى لحظات عائلتك داخل عائلتك.';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get welcomeBackToSila => 'مرحبًا بعودتك إلى صلة';

  @override
  String get loginDescription => 'عُد إلى دائرتك العائلية وتابع من حيث توقفت.';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailAddressHint => 'name@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get passwordRecoveryComing => 'ستتم إضافة استعادة كلمة المرور عبر Firebase.';

  @override
  String get loggingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get enterDeveloperFamily => 'الدخول إلى عائلة المطوّر';

  @override
  String get debugPreviewDescription => 'معاينة تجريبية فقط • تستخدم بيانات عرض للقراءة فقط';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get createOne => 'أنشئ حسابًا';

  @override
  String get incorrectEmailOrPassword => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get accountDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get tooManyLoginAttempts => 'محاولات كثيرة جدًا. يرجى المحاولة لاحقًا.';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت. يرجى المحاولة مجددًا.';

  @override
  String get couldNotLogIn => 'تعذر تسجيل الدخول. يرجى المحاولة مجددًا.';

  @override
  String get joinSila => 'انضم إلى صلة';

  @override
  String get signupDescription => 'أنشئ حسابك وقرّب دائرتك العائلية.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get dateOfBirthHint => 'يوم/شهر/سنة';

  @override
  String get passwordRequirements => '٨ أحرف أو أكثر، وحرف إنجليزي كبير وصغير ورقم';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get acceptTerms => 'أوافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dateOfBirthRequired => 'تاريخ الميلاد مطلوب.';

  @override
  String get selectValidDateOfBirth => 'اختر تاريخ ميلاد صالحًا.';

  @override
  String get dateOfBirthFuture => 'لا يمكن أن يكون تاريخ الميلاد في المستقبل.';

  @override
  String get acceptTermsRequired => 'يجب الموافقة على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get emailAlreadyInUse => 'يوجد حساب مرتبط بهذا البريد الإلكتروني.';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get couldNotCreateAccount => 'تعذر إنشاء حسابك. يرجى المحاولة مجددًا.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مجددًا.';

  @override
  String get familySetup => 'إعداد العائلة';

  @override
  String get connectWithFamily => 'تواصل مع عائلتك';

  @override
  String get createOrJoinFamily => 'أنشئ مجموعة عائلية جديدة أو انضم إلى مجموعة موجودة.';

  @override
  String get createFamily => 'إنشاء عائلة';

  @override
  String get joinFamily => 'الانضمام إلى عائلة';

  @override
  String get createFamilyGroup => 'أنشئ مجموعتك العائلية';

  @override
  String get createFamilyDescription => 'اختر اسمًا لعائلتك وادعُ أقاربك للانضمام.';

  @override
  String get createFamilyLoginRequired => 'يجب تسجيل الدخول لإنشاء عائلة.';

  @override
  String get familyCreated => 'تم إنشاء العائلة بنجاح.';

  @override
  String get couldNotCreateFamily => 'تعذر إنشاء العائلة. يرجى المحاولة مجددًا.';

  @override
  String get alreadyInFamily => 'غادر عائلتك الحالية قبل إنشاء عائلة أخرى.';

  @override
  String get familyImageComing => 'ستتم إضافة رفع صورة العائلة لاحقًا.';

  @override
  String get familyName => 'اسم العائلة';

  @override
  String get familyNameHint => 'عائلة صلة';

  @override
  String get familyDescriptionOptional => 'وصف العائلة (اختياري)';

  @override
  String get familyDescriptionHint => 'رسالة قصيرة عن عائلتك';

  @override
  String get creatingFamily => 'جارٍ إنشاء العائلة...';

  @override
  String get yourInvitationCode => 'رمز دعوتك';

  @override
  String get shareInvitationCode => 'شارك هذا الرمز مع أقاربك ليتمكنوا من الانضمام إلى عائلتك.';

  @override
  String get copyingComing => 'سيتم تفعيل النسخ قريبًا.';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get continueToHome => 'المتابعة إلى الرئيسية';

  @override
  String get joinYourFamily => 'انضم إلى عائلتك';

  @override
  String get joinFamilyDescription => 'أدخل رمز الدعوة المكوّن من ستة أحرف الذي شاركته عائلتك.';

  @override
  String get joinFamilyLoginRequired => 'يجب تسجيل الدخول للانضمام إلى عائلة.';

  @override
  String get invitationCodeNotFound => 'لم يتم العثور على رمز الدعوة.';

  @override
  String get alreadyFamilyMember => 'أنت فرد في هذه العائلة بالفعل.';

  @override
  String get leaveCurrentFamilyFirst => 'غادر عائلتك الحالية قبل الانضمام إلى عائلة أخرى.';

  @override
  String get couldNotJoinFamily => 'تعذر الانضمام إلى العائلة. يرجى المحاولة مجددًا.';

  @override
  String get invitationCode => 'رمز الدعوة';

  @override
  String get invitationCodeHint => 'A7K9Q2';

  @override
  String get joiningFamily => 'جارٍ الانضمام إلى العائلة...';

  @override
  String get validationFullNameRequired => 'الاسم الكامل مطلوب.';

  @override
  String get validationNameMinLength => 'يجب أن يحتوي الاسم على حرفين على الأقل.';

  @override
  String get validationNameMaxLength => 'لا يمكن أن يزيد الاسم على ٤٠ حرفًا.';

  @override
  String get validationNameLettersOnly => 'يمكن أن يحتوي الاسم على أحرف فقط.';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب.';

  @override
  String get validationEmailNoSpaces => 'لا يمكن أن يحتوي البريد الإلكتروني على مسافات.';

  @override
  String get validationEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get validationPasswordMinLength => 'يجب أن تحتوي كلمة المرور على ٨ أحرف على الأقل.';

  @override
  String get validationPasswordUppercase => 'يجب أن تحتوي كلمة المرور على حرف إنجليزي كبير.';

  @override
  String get validationPasswordLowercase => 'يجب أن تحتوي كلمة المرور على حرف إنجليزي صغير.';

  @override
  String get validationPasswordNumber => 'يجب أن تحتوي كلمة المرور على رقم.';

  @override
  String get validationConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور.';

  @override
  String get validationPasswordsMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get validationFamilyNameRequired => 'اسم العائلة مطلوب.';

  @override
  String get validationFamilyNameMinLength => 'يجب أن يحتوي اسم العائلة على حرفين على الأقل.';

  @override
  String get validationFamilyNameMaxLength => 'لا يمكن أن يزيد اسم العائلة على ٤٠ حرفًا.';

  @override
  String get validationFamilyNameInvalid => 'يحتوي اسم العائلة على أحرف غير صالحة.';

  @override
  String get validationInvitationCodeRequired => 'رمز الدعوة مطلوب.';

  @override
  String get validationInvitationCodeLength => 'يجب أن يتكوّن رمز الدعوة من ٦ أحرف بالضبط.';

  @override
  String get validationInvitationCodeCharacters => 'يمكن أن يحتوي رمز الدعوة على أحرف وأرقام فقط.';

  @override
  String get memoriesTitle => 'الذكريات';

  @override
  String get memoryTitleGeneric => 'ذكرى';

  @override
  String get memoriesFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة لعرض الذكريات.';

  @override
  String get memoriesLoadError => 'تعذر تحميل الذكريات.';

  @override
  String get noMemoriesYet => 'لا توجد ذكريات بعد';

  @override
  String get memoriesEmptyDescription => 'احفظوا الصور ومقاطع الفيديو والقصص من لحظاتكم العائلية.';

  @override
  String get addFirstMemory => 'أضف أول ذكرى';

  @override
  String get developerMemoriesTitle => 'ذكريات عائلة المطوّر';

  @override
  String get developerMemoriesDescription => 'لحظات تجريبية لمراجعة التجربة. لا يتم حفظها في Firebase.';

  @override
  String get developerMemoriesReadOnly => 'معاينة المطوّر للقراءة فقط. لم يتم تغيير أي بيانات.';

  @override
  String get previewPicnicTitle => 'نزهة عائلية في حديقة مشرف';

  @override
  String get previewPicnicDescription => 'ظهيرة مشمسة مليئة بالألعاب والقصص والضحكات.';

  @override
  String get previewPicnicDetails => '٠٢/٠٨/٢٠٢٦ • دبي';

  @override
  String get previewLunchTitle => 'غداء الجمعة معًا';

  @override
  String get previewLunchDescription => 'شاركتنا الجدة وصفتها العائلية المفضلة.';

  @override
  String get previewLunchDetails => '٣١/٠٧/٢٠٢٦ • المنزل';

  @override
  String get previewSunsetTitle => 'نزهة وقت الغروب';

  @override
  String get previewSunsetDescription => 'شاهدنا الغروب وخططنا ليومنا العائلي القادم.';

  @override
  String get previewSunsetDetails => '٢٥/٠٧/٢٠٢٦ • كورنيش أبوظبي';

  @override
  String get addMemoryTitle => 'إضافة ذكرى';

  @override
  String get captureFamilyMoment => 'التقط لحظة عائلية';

  @override
  String get addMemoryScreenDescription => 'أضف صورة واحفظ لحظة يمكن لعائلتك استعادتها معًا.';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get photoTooLarge => 'لا يزال حجم الصورة كبيرًا جدًا. يرجى اختيار صورة أخرى.';

  @override
  String get memoryDateRequired => 'تاريخ الذكرى مطلوب.';

  @override
  String get selectValidMemoryDate => 'اختر تاريخًا صالحًا للذكرى.';

  @override
  String get saveMemorySignInRequired => 'يجب تسجيل الدخول لحفظ ذكرى.';

  @override
  String get addMemoryFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل إضافة الذكريات.';

  @override
  String get memorySaved => 'تم حفظ الذكرى بنجاح.';

  @override
  String get couldNotSaveMemoryTryAgain => 'تعذر حفظ هذه الذكرى. يرجى المحاولة مرة أخرى.';

  @override
  String couldNotSaveMemory(String error) {
    return 'تعذر حفظ الذكرى: $error';
  }

  @override
  String get memoryTitleLabel => 'عنوان الذكرى';

  @override
  String get memoryTitleHint => 'يوم في حديقة الحيوان';

  @override
  String get memoryDescriptionLabel => 'الوصف';

  @override
  String get memoryDescriptionHint => 'احكِ القصة وراء هذه الذكرى';

  @override
  String get memoryDateLabel => 'التاريخ';

  @override
  String get memoryDateHint => 'يوم/شهر/سنة';

  @override
  String get memoryLocationOptional => 'الموقع (اختياري)';

  @override
  String get memoryLocationHint => 'حديقة حيوانات العين';

  @override
  String get saveMemory => 'حفظ الذكرى';

  @override
  String get editMemory => 'تعديل الذكرى';

  @override
  String get enterMemoryTitle => 'أدخل عنوانًا للذكرى.';

  @override
  String get couldNotSaveMemoryChangesTryAgain => 'تعذر حفظ هذه التغييرات. يرجى المحاولة مرة أخرى.';

  @override
  String couldNotSaveMemoryChanges(String error) {
    return 'تعذر حفظ التغييرات: $error';
  }

  @override
  String get titleLabel => 'العنوان';

  @override
  String get storyLabel => 'القصة';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get chooseDate => 'اختر التاريخ';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get deleteMemoryQuestion => 'حذف الذكرى؟';

  @override
  String get deleteMemoryWarning => 'ستتم إزالة هذه الذكرى نهائيًا من ذكريات عائلتك.';

  @override
  String get deletingMemory => 'جارٍ حذف الذكرى...';

  @override
  String get couldNotDeleteMemory => 'تعذر حذف هذه الذكرى. يرجى المحاولة مرة أخرى.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get memoryNotFound => 'لم يتم العثور على الذكرى.';

  @override
  String get memoryDetailsLoadError => 'تعذر تحميل هذه الذكرى. يرجى المحاولة مرة أخرى.';

  @override
  String get noDate => 'لا يوجد تاريخ';

  @override
  String get editMemoryTooltip => 'تعديل الذكرى';

  @override
  String get deleteMemoryTooltip => 'حذف الذكرى';

  @override
  String get validationMemoryTitleRequired => 'عنوان الذكرى مطلوب.';

  @override
  String get validationMemoryTitleMinLength => 'يجب أن يحتوي عنوان الذكرى على حرفين على الأقل.';

  @override
  String get validationMemoryTitleMaxLength => 'لا يمكن أن يزيد عنوان الذكرى على ٦٠ حرفًا.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get editProfileTooltip => 'تعديل الملف الشخصي';

  @override
  String get personalDetails => 'بياناتك الشخصية';

  @override
  String get personalDetailsDescription => 'اجعل اسمك واضحًا لتعرف عائلتك من يلعب ويساهم.';

  @override
  String get emailManagedSecurely => 'تتم إدارة بريد تسجيل الدخول من خلال أمان الحساب.';

  @override
  String get saveProfile => 'حفظ الملف الشخصي';

  @override
  String get savingProfile => 'جارٍ حفظ الملف الشخصي...';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String get couldNotLoadProfile => 'تعذر تحميل ملفك الشخصي. يرجى المحاولة مرة أخرى.';

  @override
  String get couldNotSaveProfile => 'تعذر حفظ ملفك الشخصي. يرجى المحاولة مرة أخرى.';

  @override
  String get developerPreviewReadOnly => 'معاينة المطوّر للقراءة فقط. لم يتم تغيير أي بيانات.';

  @override
  String get profileFamilySection => 'العائلة';

  @override
  String get statistics => 'الإحصاءات';

  @override
  String get rewards => 'المكافآت';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get familyWishes => 'أمنيات العائلة';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get silaDeveloper => 'مطوّر صلة';

  @override
  String get developerFamilyName => 'عائلة المطوّر';

  @override
  String familyNameLabel(String name) {
    return 'العائلة: $name';
  }

  @override
  String get noFamilyJoinedYet => 'لم تنضم إلى عائلة بعد';

  @override
  String get gamesPlayed => 'الألعاب التي لعبتها';

  @override
  String get wins => 'مرات الفوز';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String profileDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'لا أيام',
    );
    return '$_temp0';
  }

  @override
  String get memoryKeeper => 'حافظ الذكريات';

  @override
  String get memoryKeeperDescription => 'احفظ ١٠٠ ذكرى عائلية.';

  @override
  String get quizMaster => 'خبير الاختبارات';

  @override
  String get quizMasterDescription => 'اربح ٢٠ اختبارًا عائليًا.';

  @override
  String get teamPlayer => 'روح الفريق';

  @override
  String get teamPlayerDescription => 'أكمل ٣٠ مهمة عائلية.';

  @override
  String get noFamilyWishesYet => 'لا توجد أمنيات عائلية بعد';

  @override
  String get familyWishesEmptyDescription => 'ستظهر هنا أمنيات العائلة المكتسبة من المنافسات الكبرى.';

  @override
  String get noTrophiesYet => 'لا توجد كؤوس بعد';

  @override
  String get trophiesEmptyDescription => 'ستظهر هنا كؤوس البطولات الأسبوعية والشهرية.';

  @override
  String get couldNotLoadTrophies => 'تعذر تحميل كؤوس العائلة. يرجى المحاولة مرة أخرى.';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get appSettingsDescription => 'اللغة والإشعارات والتفضيلات';

  @override
  String get youHaveNotJoinedFamily => 'لم تنضم إلى عائلة بعد.';

  @override
  String get inviteCodeLabel => 'رمز الدعوة';

  @override
  String get copyInviteCode => 'نسخ رمز الدعوة';

  @override
  String get familyInviteCodeCopied => 'تم نسخ رمز دعوة العائلة.';

  @override
  String profileFamilyMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرد من العائلة',
      many: '$count فردًا من العائلة',
      few: '$count أفراد من العائلة',
      two: 'فردان من العائلة',
      one: 'فرد واحد من العائلة',
      zero: 'لا يوجد أفراد في العائلة',
    );
    return '$_temp0';
  }

  @override
  String get shareFamilyInviteCode => 'شارك هذا الرمز مع أقاربك ليتمكنوا من الانضمام إلى هذه العائلة.';

  @override
  String get manageFamily => 'إدارة العائلة';

  @override
  String get familyManagement => 'إدارة العائلة';

  @override
  String get familyManagementDescription => 'ادعُ أقاربك وتعرّف على الصلاحيات وحافظ على تنظيم مجموعتك العائلية.';

  @override
  String get familyLoadError => 'تعذر تحميل عائلتك. يرجى المحاولة مرة أخرى.';

  @override
  String get familyMembersLoadError => 'تعذر تحميل أفراد العائلة. يرجى المحاولة مرة أخرى.';

  @override
  String get createOrJoinFamilyAction => 'إنشاء عائلة أو الانضمام إليها';

  @override
  String get inviteRelatives => 'دعوة الأقارب';

  @override
  String get familyInviteDescription => 'شارك هذا الرمز الخاص فقط مع الأقارب الذين تريد ضمهم إلى مساحة عائلتك.';

  @override
  String get familyMembersTitle => 'أفراد العائلة';

  @override
  String get familyMembersDescription => 'توضّح الأدوار ما يمكن لكل شخص إدارته في مساحة العائلة.';

  @override
  String get familyRoles => 'أدوار العائلة';

  @override
  String get familyRoleOwner => 'المالك';

  @override
  String get familyRoleAdmin => 'مسؤول المكافآت';

  @override
  String get familyRoleMember => 'فرد';

  @override
  String get familyOwnerDescription => 'يدير بيانات العائلة وأفرادها وأدوارها وملكيتها.';

  @override
  String get familyAdminDescription => 'يمكنه مراجعة طلبات مكافآت العائلة والموافقة عليها.';

  @override
  String get familyMemberDescription => 'يمكنه المشاركة في ألعاب العائلة ومهامها وذكرياتها وأنشطتها المشتركة.';

  @override
  String familyMemberYou(String name) {
    return '$name (أنت)';
  }

  @override
  String get memberActions => 'إجراءات الفرد';

  @override
  String get editFamily => 'تعديل العائلة';

  @override
  String get editFamilyDetails => 'تعديل بيانات العائلة';

  @override
  String get saveFamily => 'حفظ العائلة';

  @override
  String get familyUpdated => 'تم تحديث بيانات العائلة.';

  @override
  String get couldNotUpdateFamily => 'تعذر تحديث العائلة. يرجى المحاولة مرة أخرى.';

  @override
  String get makeAdmin => 'تعيين مسؤول للمكافآت';

  @override
  String get removeAdmin => 'إزالة صلاحية مسؤول المكافآت';

  @override
  String get adminRoleUpdated => 'تم تحديث دور الفرد في العائلة.';

  @override
  String get couldNotUpdateAdminRole => 'تعذر تحديث هذا الدور. يرجى المحاولة مرة أخرى.';

  @override
  String get transferOwnership => 'نقل الملكية';

  @override
  String transferOwnershipQuestion(String name) {
    return 'تعيين $name مالكًا للعائلة؟';
  }

  @override
  String get transferOwnershipWarning => 'سيحصل هذا الفرد على جميع صلاحيات إدارة العائلة وستصبح أنت فردًا عاديًا. ويمكن للمالك الجديد تغيير ذلك لاحقًا.';

  @override
  String get ownershipTransferred => 'تم نقل ملكية العائلة.';

  @override
  String get couldNotTransferOwnership => 'تعذر نقل الملكية. يرجى المحاولة مرة أخرى.';

  @override
  String get removeMember => 'إزالة الفرد';

  @override
  String removeMemberQuestion(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get removeMemberWarning => 'سيفقد هذا الفرد الوصول إلى محتوى العائلة الخاص ويمكنه الانضمام إلى عائلة أخرى أو إنشاء واحدة.';

  @override
  String get familyMemberRemoved => 'تمت إزالة فرد العائلة.';

  @override
  String get couldNotRemoveMember => 'تعذرت إزالة فرد العائلة. يرجى المحاولة مرة أخرى.';

  @override
  String get leaveFamily => 'مغادرة العائلة';

  @override
  String get leaveFamilyQuestion => 'مغادرة هذه العائلة؟';

  @override
  String get leaveFamilyWarning => 'ستفقد الوصول إلى محتوى هذه العائلة الخاص. ويمكنك الانضمام مجددًا لاحقًا باستخدام رمز دعوة.';

  @override
  String get leftFamilySuccessfully => 'لقد غادرت العائلة.';

  @override
  String get couldNotLeaveFamily => 'تعذرت مغادرة العائلة. يرجى المحاولة مرة أخرى.';

  @override
  String get transferBeforeLeaving => 'انقل الملكية للمغادرة';

  @override
  String get ownerCannotLeave => 'انقل الملكية أولًا';

  @override
  String get ownerCannotLeaveDescription => 'يحمي المالك مساحة العائلة. انقل الملكية إلى فرد آخر قبل المغادرة. وإذا كنت الفرد الوحيد، فادعُ قريبًا موثوقًا أولًا.';

  @override
  String get gotIt => 'حسنًا';

  @override
  String get developerFamilyDescription => 'مساحة خاصة ودافئة للعب والمشاركة والنمو معًا.';

  @override
  String get developerFamilyMemberName => 'مريم';

  @override
  String get developerFamilyMemberTwoName => 'عمر';

  @override
  String get missionsSignInRequired => 'يجب تسجيل الدخول لعرض المهام.';

  @override
  String get missionsFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل إكمال المهام.';

  @override
  String get missionsLoadError => 'تعذر تحميل المهام العائلية. يرجى المحاولة مجددًا.';

  @override
  String get missionGeneric => 'مهمة';

  @override
  String get you => 'أنت';

  @override
  String get whoParticipated => 'من شارك؟';

  @override
  String get participantSelectionDescription => 'اختر أفراد العائلة الذين شاركوا فعلًا. تتطلب المهام العائلية مشاركين اثنين على الأقل.';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get useCameraAsProof => 'استخدم الكاميرا لإثبات الإنجاز';

  @override
  String get choosePhotoOrScreenshot => 'اختيار صورة أو لقطة شاشة';

  @override
  String get chooseExistingImage => 'اختر صورة موجودة من جهازك';

  @override
  String get missionImageTooLarge => 'حجم الصورة كبير جدًا. يرجى اختيار صورة أصغر.';

  @override
  String get reviewYourProof => 'راجع إثباتك';

  @override
  String get missionProofPrivacyNotice => 'تُرسل صورتك بأمان إلى Google Gemini عبر خادم صلة للتحقق من هذه المهمة فقط. تحفظ صلة نتيجة التحقق، وليس نسخة من الصورة.';

  @override
  String get missionProofConsent => 'أوافق على التحقق من هذه الصورة باستخدام الذكاء الاصطناعي.';

  @override
  String participantsLabel(String names) {
    return 'المشاركون: $names';
  }

  @override
  String get explanationOptional => 'شرح (اختياري)';

  @override
  String get missionExplanationHint => 'أضف معلومات مفيدة قد لا تظهر بوضوح في الصورة.';

  @override
  String get verifyProof => 'التحقق من الإثبات';

  @override
  String get aiCheckingMissionProof => 'يتحقق الذكاء الاصطناعي من إثبات المهمة...';

  @override
  String get couldNotVerifyMissionProof => 'تعذر التحقق من إثبات المهمة. يرجى المحاولة مجددًا.';

  @override
  String get needClearerProof => 'نحتاج إلى إثبات أوضح';

  @override
  String get proofNotVerified => 'لم يتم التحقق من الإثبات';

  @override
  String verificationFailureDescription(String reason) {
    return '$reason\n\nيمكنك إرسال صورة أخرى أو إضافة شرح أوضح.';
  }

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get missionAlreadyRewarded => 'تم منح مكافأة هذه المهمة بالفعل.';

  @override
  String get missionRewardSaveError => 'تم التحقق من الإثبات، لكن تعذر حفظ المكافأة. يرجى المحاولة مجددًا.';

  @override
  String get familyMissionMinimumParticipants => 'تحتاج المهمة العائلية إلى مشاركين اثنين على الأقل.';

  @override
  String get missionVerified => 'تم التحقق من المهمة!';

  @override
  String familyMissionRewardSuccess(int tokens, String participants) {
    return 'تم منح $tokens من الرموز لكل مشارك.\n\n$participants\n\nتم تحديث تقدم مهام عائلتك لهذا الأسبوع.';
  }

  @override
  String personalMissionRewardSuccess(int tokens) {
    return 'ربحت $tokens من الرموز.\n\nتم تحديث تقدم مهامك لهذا الأسبوع.';
  }

  @override
  String get nice => 'رائع!';

  @override
  String get difficultyEasy => 'سهلة';

  @override
  String get difficultyMedium => 'متوسطة';

  @override
  String get difficultyChallenge => 'تحدٍّ';

  @override
  String get yourMissions => 'مهامك';

  @override
  String personalMissionsSubtitle(int count) {
    return 'تبقى لك $count من المهام الشخصية هذا الأسبوع';
  }

  @override
  String sharedMissionsSubtitle(int count) {
    return 'تبقت $count من المهام المشتركة هذا الأسبوع';
  }

  @override
  String get recentlyCompleted => 'أُنجزت مؤخرًا';

  @override
  String get doMoreTogether => 'أنجزوا المزيد معًا';

  @override
  String missionsHeaderDescription(int count) {
    return 'تبقت $count من المهام في لوحة هذا الأسبوع. تبقى المهام الموثقة مكتملة حتى تتجدد اللوحة.';
  }

  @override
  String missionsCompletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة منجزة',
      many: '$count مهمة منجزة',
      few: '$count مهام منجزة',
      two: 'مهمتان منجزتان',
      one: 'مهمة واحدة منجزة',
      zero: 'لم تُنجز أي مهمة',
    );
    return '$_temp0';
  }

  @override
  String missionTokensEarnedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رمز مهمة مكتسب',
      many: '$count رمز مهمة مكتسبًا',
      few: '$count رموز مهام مكتسبة',
      two: 'رمزا مهمة مكتسبان',
      one: 'رمز مهمة واحد مكتسب',
      zero: 'لم تُكتسب رموز من المهام',
    );
    return '$_temp0';
  }

  @override
  String missionWeekWindow(String start, String end) {
    return 'هذا الأسبوع • $start–$end';
  }

  @override
  String personalWeeklyProgress(int completed, int total) {
    return 'التقدم الشخصي • $completed/$total';
  }

  @override
  String familyWeeklyProgress(int completed, int total) {
    return 'تقدم العائلة • $completed/$total';
  }

  @override
  String get personalWeekComplete => 'أكملت جميع مهامك الشخصية!';

  @override
  String get familyWeekComplete => 'أكملت عائلتك جميع المهام المشتركة!';

  @override
  String get missionsResetMonday => 'تصل لوحة مهام جديدة يوم الاثنين المقبل.';

  @override
  String get aiProofRequired => 'إثبات بالذكاء الاصطناعي مطلوب';

  @override
  String get personalLabel => 'شخصية';

  @override
  String get missionCategoryOutdoor => 'في الخارج';

  @override
  String get missionCategoryTogetherTime => 'وقت معًا';

  @override
  String get missionCategoryMemories => 'ذكريات';

  @override
  String get missionCategoryKindness => 'لطف';

  @override
  String get missionCategoryConnection => 'تواصل';

  @override
  String get missionCategoryFun => 'مرح';

  @override
  String get missionCategoryTeamwork => 'عمل جماعي';

  @override
  String missionTokenReward(int count) {
    return '+$count رموز';
  }

  @override
  String get aiProofFamilyReward => 'إثبات بالذكاء الاصطناعي • مكافأة لكل مشارك';

  @override
  String get aiProofPersonalReward => 'إثبات بالذكاء الاصطناعي • مكافأة لك';

  @override
  String completedOn(String date) {
    return 'أُنجزت في $date';
  }

  @override
  String get familyMissionLabel => 'مهمة عائلية';

  @override
  String get personalMissionLabel => 'مهمة شخصية';

  @override
  String familyMissionDetailsReward(int tokens) {
    return 'اختر من شارك. يمكن للعائلة الحصول على مكافأة المهمة مرة واحدة، ويحصل كل مشارك على $tokens من الرموز.';
  }

  @override
  String personalMissionDetailsReward(int tokens) {
    return 'أكمل هذه المهمة بنفسك واربح $tokens من الرموز.';
  }

  @override
  String get proofGuidance => 'إرشادات الإثبات';

  @override
  String get cooldown => 'فترة الانتظار';

  @override
  String missionCooldownDescription(int count) {
    return 'بعد إكمالها، لن تعود هذه المهمة لمدة $count أيام.';
  }

  @override
  String get submitProof => 'إرسال الإثبات';

  @override
  String get notYet => 'ليس الآن';

  @override
  String get missionPersonalAppreciationTitle => 'أظهر تقديرك';

  @override
  String get missionPersonalAppreciationDescription => 'أخبر أحد أفراد عائلتك بشيء محدد تقدّره فيه بصدق.';

  @override
  String get missionPersonalAppreciationProofHint => 'أرسل صورة أو لقطة شاشة ذات صلة واشرح بإيجاز ما قلته أو فعلته.';

  @override
  String get missionPersonalHelpTitle => 'ساعد من دون أن يُطلب منك';

  @override
  String get missionPersonalHelpDescription => 'قم بشيء مفيد حقًا لأحد أفراد عائلتك قبل أن يطلبه منك.';

  @override
  String get missionPersonalHelpProofHint => 'أرسل صورة ذات صلة أو صورة قبل وبعد واشرح ما ساعدت فيه.';

  @override
  String get missionPersonalCallRelativeTitle => 'اتصل بشخص تحبه';

  @override
  String get missionPersonalCallRelativeDescription => 'اتصل أو أجرِ مكالمة فيديو مع قريب لم تتحدث معه منذ مدة.';

  @override
  String get missionPersonalCallRelativeProofHint => 'لقطة شاشة للمكالمة هي الإثبات الأنسب. تجنّب إظهار أرقام الهواتف الخاصة قدر الإمكان.';

  @override
  String get missionPersonalFamilyStoryTitle => 'اكتشف قصة عائلية';

  @override
  String get missionPersonalFamilyStoryDescription => 'اطلب من أحد أفراد عائلتك أن يروي لك قصة طريفة أو مؤثرة أو لا تُنسى من ماضيه.';

  @override
  String get missionPersonalFamilyStoryProofHint => 'أرسل صورة ذات صلة واشرح بإيجاز القصة التي تعلّمتها.';

  @override
  String get missionPersonalMakeDrinkTitle => 'حضّر شيئًا لشخص تحبه';

  @override
  String get missionPersonalMakeDrinkDescription => 'حضّر مشروبًا أو وجبة خفيفة أو حلوى صغيرة لأحد أفراد عائلتك.';

  @override
  String get missionPersonalMakeDrinkProofHint => 'أرسل صورة لما حضّرته.';

  @override
  String get missionPersonalMemoryQuestionTitle => 'اسأل عن ذكرى قديمة';

  @override
  String get missionPersonalMemoryQuestionDescription => 'اسأل فردًا أكبر سنًا في العائلة عن لحظة مميزة من طفولته.';

  @override
  String get missionPersonalMemoryQuestionProofHint => 'أرسل صورة ذات صلة واستخدم خانة الشرح لوصف ما تعلّمته بإيجاز.';

  @override
  String get missionPersonalSmallCleanupTitle => 'رتّب مكانًا فوضويًا';

  @override
  String get missionPersonalSmallCleanupDescription => 'اختر مساحة صغيرة غير مرتبة في المنزل ونظّمها جيدًا.';

  @override
  String get missionPersonalSmallCleanupProofHint => 'صورة قبل الترتيب وبعده هي أقوى إثبات.';

  @override
  String get missionPersonalKindMessageTitle => 'أرسل رسالة لطيفة';

  @override
  String get missionPersonalKindMessageDescription => 'أرسل رسالة محبة إلى أحد أفراد عائلتك لتجعل يومه أجمل.';

  @override
  String get missionPersonalKindMessageProofHint => 'أرسل لقطة شاشة بعد إخفاء التفاصيل الخاصة أو الحساسة عند الحاجة.';

  @override
  String get missionPersonalLearnRecipeTitle => 'تعلّم وصفة عائلية';

  @override
  String get missionPersonalLearnRecipeDescription => 'اسأل قريبًا عن طريقة إعداد وصفة عائلية وتعرّف إلى قصتها وأصلها.';

  @override
  String get missionPersonalLearnRecipeProofHint => 'أرسل صورة للوصفة أو المكونات أو خطوات التحضير أو الطبق النهائي.';

  @override
  String get missionPersonalMemorySaveTitle => 'احفظ ذكرى عائلية';

  @override
  String get missionPersonalMemorySaveDescription => 'اختر صورة عائلية مميزة وأضفها إلى ذكرياتك مع وصف مفيد.';

  @override
  String get missionPersonalMemorySaveProofHint => 'أرسل الصورة العائلية أو لقطة شاشة توضح الذكرى التي حفظتها.';

  @override
  String get missionPersonalLongHelpTitle => 'تولَّ مهمة منزلية';

  @override
  String get missionPersonalLongHelpDescription => 'تولَّ مهمة منزلية مفيدة بدلًا من أحد أفراد عائلتك وأكملها جيدًا.';

  @override
  String get missionPersonalLongHelpProofHint => 'أرسل صورة ذات صلة قبل المهمة أو أثناءها أو بعدها.';

  @override
  String get missionPersonalSurpriseTitle => 'خطط لمفاجأة صغيرة';

  @override
  String get missionPersonalSurpriseDescription => 'افعل شيئًا لطيفًا وغير متوقع لشخص في عائلتك.';

  @override
  String get missionPersonalSurpriseProofHint => 'أرسل إثباتًا مناسبًا واشرح ماهية المفاجأة.';

  @override
  String get missionFamilyWalkTitle => 'اخرجوا في نزهة عائلية';

  @override
  String get missionFamilyWalkDescription => 'امشوا معًا لمدة ٢٠ دقيقة على الأقل واستمتعوا بالوقت من دون استعجال.';

  @override
  String get missionFamilyWalkProofHint => 'أرسل صورة من النزهة توضح النشاط أو المكان.';

  @override
  String get missionFamilyMealTitle => 'تناولوا وجبة معًا';

  @override
  String get missionFamilyMealDescription => 'اجلسوا معًا لتناول وجبة كاملة وأبعدوا الهواتف أثناء الطعام.';

  @override
  String get missionFamilyMealProofHint => 'أرسل صورة توضح الوجبة أو المائدة أو النشاط العائلي.';

  @override
  String get missionFamilyPhotoTitle => 'التقطوا صورة لليوم';

  @override
  String get missionFamilyPhotoDescription => 'التقطوا صورة عائلية جديدة معًا وحوّلوا يومًا عاديًا إلى ذكرى.';

  @override
  String get missionFamilyPhotoProofHint => 'أرسل الصورة العائلية الجديدة التي التقطتموها لهذه المهمة.';

  @override
  String get missionFamilyPlayTitle => 'العبوا معًا';

  @override
  String get missionFamilyPlayDescription => 'اقضوا ٣٠ دقيقة على الأقل في لعب لعبة معًا.';

  @override
  String get missionFamilyPlayProofHint => 'أرسل صورة توضح تجهيز اللعبة أو النشاط العائلي.';

  @override
  String get missionFamilyCookTitle => 'اطبخوا شيئًا معًا';

  @override
  String get missionFamilyCookDescription => 'حضّروا وجبة أو حلوى أو وجبة خفيفة معًا بدلًا من ترك العمل كله لشخص واحد.';

  @override
  String get missionFamilyCookProofHint => 'أرسل صورة من التحضير أو للطعام بعد اكتماله.';

  @override
  String get missionFamilyGameNightTitle => 'ليلة ألعاب عائلية';

  @override
  String get missionFamilyGameNightDescription => 'خصصوا ٤٥ دقيقة على الأقل ليلعب الجميع معًا.';

  @override
  String get missionFamilyGameNightProofHint => 'أرسل صورة لتجهيز اللعبة أو للعائلة وهي تلعب معًا.';

  @override
  String get missionFamilyScreenFreeTitle => 'ساعة بلا شاشات';

  @override
  String get missionFamilyScreenFreeDescription => 'اقضوا ساعة كاملة معًا من دون هواتف أو تلفاز أو أجهزة لوحية أو حواسيب.';

  @override
  String get missionFamilyScreenFreeProofHint => 'أرسل صورة لما فعلته عائلتك خلال الوقت الخالي من الشاشات.';

  @override
  String get missionFamilyCleanupTitle => 'نظافة جماعية';

  @override
  String get missionFamilyCleanupDescription => 'اختاروا مساحة غير مرتبة ونظفوها أو نظموها معًا من البداية إلى النهاية.';

  @override
  String get missionFamilyCleanupProofHint => 'صورة قبل التنظيف وبعده هي الإثبات الأنسب.';

  @override
  String get missionFamilyOutdoorTitle => 'وقت عائلي في الخارج';

  @override
  String get missionFamilyOutdoorDescription => 'اقضوا ٤٥ دقيقة على الأقل في نشاط خارجي معًا.';

  @override
  String get missionFamilyOutdoorProofHint => 'أرسل صورة توضح نشاطكم الخارجي أو مكانه.';

  @override
  String get missionFamilyOldPhotosTitle => 'استكشفوا صور العائلة القديمة';

  @override
  String get missionFamilyOldPhotosDescription => 'تصفحوا صور العائلة القديمة معًا وتحدثوا عن القصص التي تحملها.';

  @override
  String get missionFamilyOldPhotosProofHint => 'أرسل صورة توضح الألبوم أو الصور القديمة أو نشاط استعادة الذكريات.';

  @override
  String get missionFamilyDessertTitle => 'حضّروا حلوى معًا';

  @override
  String get missionFamilyDessertDescription => 'اختاروا حلوى وحضّروها معًا من البداية حتى النتيجة النهائية.';

  @override
  String get missionFamilyDessertProofHint => 'أرسل صورة من التحضير أو للحلوى بعد اكتمالها.';

  @override
  String get missionFamilyPicnicTitle => 'أقيموا نزهة عائلية';

  @override
  String get missionFamilyPicnicDescription => 'حضّروا طعامًا واستمتعوا بنزهة معًا بعيدًا عن مائدة الطعام المعتادة.';

  @override
  String get missionFamilyPicnicProofHint => 'أرسل صورة توضح تجهيز النزهة أو الطعام أو المكان.';

  @override
  String get missionFamilyVisitRelativeTitle => 'زوروا أحد الأقارب';

  @override
  String get missionFamilyVisitRelativeDescription => 'اقضوا وقتًا هادفًا وجهًا لوجه في زيارة قريب لا ترونه كل يوم.';

  @override
  String get missionFamilyVisitRelativeProofHint => 'أرسل إثباتًا محترمًا من الزيارة من دون إظهار معلومات خاصة لا داعي لها.';

  @override
  String get missionFamilyRecreatePhotoTitle => 'أعيدوا تمثيل صورة عائلية قديمة';

  @override
  String get missionFamilyRecreatePhotoDescription => 'اختاروا صورة عائلية قديمة وأعيدوا تمثيل وضعيتها أو مشهدها معًا.';

  @override
  String get missionFamilyRecreatePhotoProofHint => 'أرسل الصورة الجديدة واشرح أي صورة قديمة ألهمتها.';

  @override
  String get missionFamilyKindnessProjectTitle => 'أنجزوا مشروع عطاء';

  @override
  String get missionFamilyKindnessProjectDescription => 'تعاونوا على عمل مفيد حقًا لشخص آخر من دون انتظار مكافأة منه.';

  @override
  String get missionFamilyKindnessProjectProofHint => 'أرسل إثباتًا آمنًا ومحترمًا لما صنعته عائلتك أو فعلته.';

  @override
  String get officialWins => 'الانتصارات الرسمية';

  @override
  String get dailyWins => 'انتصارات التحدي اليومي';

  @override
  String get weeklyWins => 'انتصارات البطولة الأسبوعية';

  @override
  String get monthlyWins => 'انتصارات الكأس الشهري';

  @override
  String get missionsCompleted => 'المهمات المكتملة';

  @override
  String get memoriesAdded => 'الذكريات المضافة';

  @override
  String get rankingPoints => 'نقاط الترتيب';

  @override
  String get homeRewards => 'المكافآت';

  @override
  String get homeRewardsDescription => 'استخدم الرموز للحصول على مكافآت عائلية ورقمية.';

  @override
  String get officialCompetitionRule => 'نتيجة رسمية واحدة لكل عائلة يوميًا. نتائج اللعب السريع لا تؤثر في هذه المكافآت.';

  @override
  String dailyWinnerRewardSummary(int tokens, int points) {
    return 'الفائز: +$tokens رمزًا + $points نقطة ترتيب';
  }

  @override
  String dailyRunnerUpRewardSummary(int points) {
    return 'الوصيف: +$points نقطة ترتيب';
  }

  @override
  String get savingOfficialResult => 'جارٍ حفظ النتيجة الرسمية...';

  @override
  String get dailyOfficialCompleteEyebrow => 'اكتمل التحدي اليومي';

  @override
  String get familyChallengeCompleteTitle => 'اكتمل التحدي العائلي';

  @override
  String get dailyCompleteWithoutWinner => 'اجتمعت عائلتك ولعبت معًا وأكملت التحدي الرسمي لليوم.';

  @override
  String dailyCompleteWithWinner(String name) {
    return 'يتوج $name اليوم بلقب العائلة. عودوا غدًا لتحدٍ جديد.';
  }

  @override
  String tokenBonus(int count) {
    return '+$count رمزًا';
  }

  @override
  String rankingPointBonus(int count) {
    return '+$count نقطة ترتيب';
  }

  @override
  String get familyMoment => 'لحظة عائلية';

  @override
  String get tieDetected => 'تعادل في النتيجة';

  @override
  String get tieRewardPendingDescription => 'لم تُمنح أي رموز أو نقاط ترتيب. يتأهل المتصدرون المتعادلون فقط إلى الجولة الحاسمة، ولا تُمنح المكافأة حتى يتبقى فائز واحد.';

  @override
  String get startSuddenDeathTieBreak => 'ابدأ جولة كسر التعادل';

  @override
  String get latestResult => 'أحدث نتيجة';

  @override
  String pointsAbbreviation(int count) {
    return '$count نقطة';
  }

  @override
  String get weeklyCompetitionDescription => 'أربع ألعاب رسمية، وتتراكم نقاط البطولة عبر كل جولة.';

  @override
  String get championshipRewards => 'مكافآت البطولة';

  @override
  String championRewardSummary(int tokens, int points) {
    return 'البطل: +$tokens رمزًا + $points نقطة ترتيب';
  }

  @override
  String runnerUpRewardSummary(int points) {
    return 'الوصيف: +$points نقطة ترتيب';
  }

  @override
  String thirdPlaceRewardSummary(int points) {
    return 'المركز الثالث: +$points نقطة ترتيب';
  }

  @override
  String get championshipScoringDescription => 'الجولات الفردية: الأول 10 • الثاني 7 • الثالث 5 • الرابع 3 • المشاركة 1\nجولات الفرق: أعضاء الفريق الفائز +1 • أعضاء الفريق الآخر +0';

  @override
  String get thisWeeksGames => 'ألعاب هذا الأسبوع';

  @override
  String get roundComplete => 'اكتملت الجولة';

  @override
  String get upNext => 'التالي';

  @override
  String get roundLocked => 'مقفلة حتى تكتمل الجولة السابقة';

  @override
  String get savingRound => 'جارٍ حفظ الجولة...';

  @override
  String playGameNumber(int number, String name) {
    return 'العب اللعبة $number: $name';
  }

  @override
  String get finalizingChampionship => 'جارٍ اعتماد نتيجة البطولة...';

  @override
  String get finalizeWeeklyChampionship => 'اعتماد البطولة الأسبوعية';

  @override
  String get championshipStandings => 'ترتيب البطولة';

  @override
  String roundsPlayed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولات',
      two: 'جولتان',
      one: 'جولة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get weeklyOfficialCompleteEyebrow => 'اكتملت البطولة الأسبوعية';

  @override
  String get newFamilyChampion => 'بطل جديد للعائلة';

  @override
  String get weeklyCompleteWithoutChampion => 'أربع ألعاب وأسبوع مشترك وقصة عائلية تستحق أن تُحفظ.';

  @override
  String weeklyCompleteWithChampion(String name) {
    return 'يتوج $name بطلاً للعائلة هذا الأسبوع بعد أربع ألعاب معًا.';
  }

  @override
  String get weeklyCrown => 'لقب الأسبوع';

  @override
  String get monthlyCompetitionDescription => 'أربعة أفراد، ونصفا نهائي، ونهائي واحد، وبطل واحد.';

  @override
  String get monthlyRewards => 'مكافآت الشهر';

  @override
  String monthlyChampionRewardSummary(int tokens, int points) {
    return 'البطل: +$tokens رمزًا + $points نقطة ترتيب + كأس';
  }

  @override
  String semifinalistRewardSummary(int points) {
    return 'المتأهلون لنصف النهائي: +$points نقطة ترتيب';
  }

  @override
  String get chooseFourCompetitors => 'اختر 4 متنافسين بالضبط';

  @override
  String get startingMonthlyCup => 'جارٍ بدء الكأس الشهري...';

  @override
  String get startMonthlyCup => 'ابدأ الكأس الشهري';

  @override
  String get monthlyParticipantIncomplete => 'بيانات المشاركين في الكأس الشهري غير مكتملة.';

  @override
  String get monthlyCupBracket => 'مخطط الكأس الشهري';

  @override
  String semifinalNumber(int number) {
    return 'نصف النهائي $number';
  }

  @override
  String get finalRound => 'النهائي';

  @override
  String gameNameLabel(String name) {
    return 'اللعبة: $name';
  }

  @override
  String versusPlayers(String first, String second) {
    return '$first ضد $second';
  }

  @override
  String winnerNameLabel(String name) {
    return 'الفائز: $name';
  }

  @override
  String playNamedRound(String round) {
    return 'العب $round';
  }

  @override
  String get monthlyCupChampion => 'بطل الكأس الشهري';

  @override
  String get champion => 'البطل';

  @override
  String get monthlyCompleteDescription => 'تنتهي أكبر منافسات العائلة بكأس وذكرى جديدة في خزانة الإنجازات.';

  @override
  String get cupTrophy => 'كأس البطولة';

  @override
  String get tieBreak => 'كسر التعادل';

  @override
  String suddenDeathRound(int number) {
    return 'الجولة الحاسمة • الجولة $number';
  }

  @override
  String get counting => 'جارٍ العد...';

  @override
  String passPhoneTo(String name) {
    return 'مرر الهاتف إلى $name';
  }

  @override
  String get stopAtFiveSeconds => 'أوقف العد عندما تظن أن 5 ثوانٍ مرت بالضبط.';

  @override
  String get goalFiveSeconds => 'هدفك هو التوقف في أقرب وقت ممكن من 5 ثوانٍ بالضبط.';

  @override
  String get hiddenTimerDescription => 'يبقى المؤقت مخفيًا، ويفوز الأقرب.';

  @override
  String get start => 'ابدأ';

  @override
  String get stop => 'توقف';

  @override
  String tieBreakWinner(String name) {
    return 'يفوز $name بجولة كسر التعادل!';
  }

  @override
  String secondsFromTarget(String seconds) {
    return 'الفارق $seconds ثانية فقط عن 5.000 ثوانٍ بالضبط.';
  }

  @override
  String get confirmWinner => 'اعتماد الفائز';

  @override
  String get stillTied => 'التعادل مستمر!';

  @override
  String tiedPlayersContinue(int count, int round) {
    return 'تعادل $count لاعبين في القرب من الهدف. يتابع هؤلاء فقط إلى الجولة $round.';
  }

  @override
  String startTieBreakRound(int number) {
    return 'ابدأ جولة كسر التعادل $number';
  }

  @override
  String get gameFamilyEyebrow => 'لعبة عائلية من صلة';

  @override
  String get rounds => 'الجولات';

  @override
  String get roundsDescription => 'اختر جولة سريعة أو العب مباراة أطول من 3 أو 5 جولات.';

  @override
  String roundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولات',
      two: 'جولتان',
      one: 'جولة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get mustBeLoggedInToPlay => 'يجب تسجيل الدخول للعب.';

  @override
  String get emojiFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل لعب خمن الإيموجي.';

  @override
  String get couldNotLoadFamilyMembers => 'تعذر تحميل أفراد عائلتك.';

  @override
  String get familyMemberFallback => 'فرد من العائلة';

  @override
  String get emojiGuessSetupDescription => 'كوّن فريقين وفك رموز الإيموجي المرحة قبل انتهاء الوقت.';

  @override
  String get whoIsPlaying => 'من سيلعب؟';

  @override
  String get chooseAtLeastTwoPlayers => 'اختر لاعبين اثنين على الأقل للمباراة العائلية.';

  @override
  String get chooseTeams => 'اختر الفريقين';

  @override
  String get assignPlayersToTeams => 'وزّع كل لاعب محدد على الفريق أ أو الفريق ب.';

  @override
  String get teamA => 'الفريق أ';

  @override
  String get teamB => 'الفريق ب';

  @override
  String get shuffleTeams => 'توزيع عشوائي';

  @override
  String get category => 'الفئة';

  @override
  String get categoryMovies => 'أفلام';

  @override
  String get categoryAnimals => 'حيوانات';

  @override
  String get categoryFood => 'طعام';

  @override
  String get categoryPlaces => 'أماكن';

  @override
  String get categoryMixed => 'متنوع';

  @override
  String get matchPace => 'إيقاع المباراة';

  @override
  String get puzzlesPerRound => 'الألغاز في كل جولة';

  @override
  String get timePerPuzzle => 'وقت كل لغز';

  @override
  String secondsShort(int count) {
    return '$count ث';
  }

  @override
  String preparingNamedGame(String game) {
    return 'جارٍ تجهيز $game...';
  }

  @override
  String startNamedGame(String game) {
    return 'ابدأ $game';
  }

  @override
  String teamTurn(String team) {
    return 'دور $team';
  }

  @override
  String stealTeam(String team) {
    return 'فرصة السرقة — $team';
  }

  @override
  String roundPuzzleProgress(int round, int totalRounds, int puzzle, int totalPuzzles) {
    return 'الجولة $round من $totalRounds • اللغز $puzzle من $totalPuzzles';
  }

  @override
  String secondsRemaining(int count) {
    return '$count ث';
  }

  @override
  String hintLabel(String hint) {
    return 'تلميح: $hint';
  }

  @override
  String get typeYourAnswer => 'اكتب إجابتك';

  @override
  String get checking => 'جارٍ التحقق...';

  @override
  String get submitAnswer => 'إرسال الإجابة';

  @override
  String teamScore(String team, int score) {
    return '$team: $score';
  }

  @override
  String get puzzleComplete => 'اكتمل اللغز';

  @override
  String answerLabel(String answer) {
    return 'الإجابة: $answer';
  }

  @override
  String get roundResults => 'نتائج الجولة';

  @override
  String get nextPuzzle => 'اللغز التالي';

  @override
  String roundNumberComplete(int number) {
    return 'اكتملت الجولة $number';
  }

  @override
  String get startTieBreaker => 'ابدأ جولة كسر التعادل';

  @override
  String get seeFinalResults => 'عرض النتائج النهائية';

  @override
  String startRound(int number) {
    return 'ابدأ الجولة $number';
  }

  @override
  String tieBreakerTeam(String team) {
    return 'كسر التعادل — $team';
  }

  @override
  String teamWins(String team) {
    return 'يفوز $team!';
  }

  @override
  String returnToCompetition(String competition) {
    return 'العودة إلى $competition';
  }

  @override
  String get playAgain => 'العب مجددًا';

  @override
  String get backToGames => 'العودة إلى الألعاب';

  @override
  String noStealAnswer(String answer) {
    return 'لم تتم السرقة.\n\nالإجابة: $answer';
  }

  @override
  String teamGuessedCorrectly(String team, int points) {
    return 'أجاب $team بشكل صحيح!\n\n+$points نقطتان';
  }

  @override
  String teamStolePuzzle(String team, int points) {
    return 'نجح $team في سرقة اللغز!\n\n+$points نقطة';
  }

  @override
  String stealMissedAnswer(String answer) {
    return 'لم تنجح السرقة.\n\nالإجابة: $answer';
  }

  @override
  String get categoryFamily => 'العائلة';

  @override
  String get categoryFamilyFun => 'مرح عائلي';

  @override
  String get categoryFavorites => 'المفضلات';

  @override
  String get categoryHabits => 'العادات';

  @override
  String get categoryMemories => 'الذكريات';

  @override
  String get categoryMostLikelyTo => 'الأكثر احتمالًا';

  @override
  String get categoryTravel => 'السفر';

  @override
  String get categoryAtHome => 'في المنزل';

  @override
  String get categorySchool => 'المدرسة';

  @override
  String get categoryActions => 'حركات';

  @override
  String get categoryObjects => 'أشياء';

  @override
  String get categorySports => 'رياضة';

  @override
  String get categoryFunny => 'مضحك';

  @override
  String get categoryFriends => 'الأصدقاء';

  @override
  String get categoryScience => 'العلوم';

  @override
  String get categoryGeography => 'الجغرافيا';

  @override
  String get categoryHistory => 'التاريخ';

  @override
  String get categoryGeneralKnowledge => 'معلومات عامة';

  @override
  String get categoryActivities => 'أنشطة';

  @override
  String get categoryNature => 'الطبيعة';

  @override
  String get categoryHome => 'المنزل';

  @override
  String get categoryMusic => 'الموسيقى';

  @override
  String get categoryTechnology => 'التقنية';

  @override
  String get categoryUaeHeritage => 'الإمارات والتراث';

  @override
  String get chooseCategory => 'اختر فئة';

  @override
  String get pickCategory => 'اختر فئة';

  @override
  String get couldNotReachAiOfflinePrompts => 'تعذر الوصول إلى الذكاء الاصطناعي. سنستخدم تلميحات محفوظة بدلًا منه.';

  @override
  String get couldNotReachAiOfflineQuestions => 'تعذر الوصول إلى الذكاء الاصطناعي. سنستخدم أسئلة محفوظة بدلًا منه.';

  @override
  String get generatingPrompts => 'جارٍ تجهيز التلميحات...';

  @override
  String get generatingQuestions => 'جارٍ تجهيز الأسئلة...';

  @override
  String get startGame => 'ابدأ اللعبة';

  @override
  String get startCharades => 'ابدأ التمثيل الصامت';

  @override
  String promptProgress(int current, int total) {
    return 'التلميح $current من $total';
  }

  @override
  String roundProgress(int current, int total) {
    return 'الجولة $current من $total';
  }

  @override
  String get gameProgress => 'تقدم اللعبة';

  @override
  String get nextPrompt => 'التلميح التالي';

  @override
  String get charadesRoundComplete => 'اكتملت جولة التمثيل الصامت!';

  @override
  String get never => 'لم أفعل';

  @override
  String get iHave => 'فعلتها';

  @override
  String get roundCompleteCelebration => 'اكتملت الجولة!';

  @override
  String iHaveCount(int count) {
    return 'فعلتها: $count';
  }

  @override
  String neverCount(int count) {
    return 'لم أفعل: $count';
  }

  @override
  String get changeCategory => 'تغيير الفئة';

  @override
  String get truth => 'صراحة';

  @override
  String get dare => 'تحدٍّ';

  @override
  String get done => 'تم';

  @override
  String truthsCompleted(int count) {
    return 'أسئلة الصراحة المكتملة: $count';
  }

  @override
  String daresCompleted(int count) {
    return 'التحديات المكتملة: $count';
  }

  @override
  String get charadesSetupDescription => 'اختر موضوعًا ومباراة من جولة أو 3 أو 5 جولات، ثم مثّل كل تلميح من دون نطق الإجابة.';

  @override
  String get neverSetupDescription => 'اختر موضوعًا عائليًا لطيفًا وجولة من تلميح واحد أو 3 أو 5 تلميحات لقصص مفاجئة.';

  @override
  String get truthDareSetupDescription => 'اختر موضوعًا مرحًا ومباراة من جولة أو 3 أو 5 جولات من أسئلة الصراحة والتحديات العائلية الآمنة.';

  @override
  String get wouldRatherSetupDescription => 'اختر فئة وجولة أو 3 أو 5 جولات، ثم اكتشف الخيارات المرحة التي تفضلها عائلتك.';

  @override
  String get wouldYouRatherPrompt => 'ماذا تفضّل؟';

  @override
  String get chooseMostFunAnswer => 'اختر الإجابة التي تبدو أكثر متعة لك.';

  @override
  String get tapAnswerToLock => 'اضغط على إجابة لاعتمادها.';

  @override
  String youSelectedAnswer(String answer) {
    return 'اخترت: $answer';
  }

  @override
  String get seeResults => 'عرض النتائج';

  @override
  String get nextRound => 'الجولة التالية';

  @override
  String get greatJob => 'أحسنت!';

  @override
  String completedRoundsCategory(int rounds, String category) {
    return 'أكملت $rounds جولات ضمن فئة $category.';
  }

  @override
  String get changeSettings => 'تغيير الإعدادات';

  @override
  String get triviaFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل لعب المعلومات العامة.';

  @override
  String get couldNotPrepareTrivia => 'تعذر تجهيز لعبة المعلومات العامة. حاول مجددًا.';

  @override
  String get triviaSetupDescription => 'كوّن فريقين واختر فئة وتسابقوا عبر أسئلة عائلية ممتعة.';

  @override
  String get questionsPerRound => 'الأسئلة في كل جولة';

  @override
  String get timePerQuestion => 'وقت كل سؤال';

  @override
  String questionRoundProgress(int round, int totalRounds, int question, int totalQuestions) {
    return 'الجولة $round من $totalRounds • السؤال $question من $totalQuestions';
  }

  @override
  String get questionComplete => 'اكتمل السؤال';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String noStealCorrectAnswer(String answer) {
    return 'لم تتم السرقة.\n\nالإجابة الصحيحة: $answer';
  }

  @override
  String teamAnsweredCorrectly(String team, int points) {
    return 'أجاب $team بشكل صحيح!\n\n+$points نقطتان';
  }

  @override
  String teamStoleQuestion(String team, int points) {
    return 'نجح $team في سرقة السؤال!\n\n+$points نقطة';
  }

  @override
  String stealMissedCorrectAnswer(String answer) {
    return 'لم تنجح السرقة.\n\nالإجابة الصحيحة: $answer';
  }

  @override
  String get triviaTie => 'تعادل في المعلومات العامة!';

  @override
  String get tieBreaker => 'كسر التعادل';

  @override
  String get oneFinalQuestion => 'سؤال أخير واحد يحدد الفائز.';

  @override
  String get wishlist => 'قائمة الأمنيات';

  @override
  String get joinFamilyWishlist => 'انضم إلى عائلة لاستخدام مكافآت قائمة الأمنيات.';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get sent => 'المرسلة';

  @override
  String get received => 'المستلمة';

  @override
  String get familyNotFound => 'لم يتم العثور على العائلة.';

  @override
  String get noOtherFamilyRewardMembers => 'لا يوجد أفراد آخرون في العائلة لطلب مكافأة منهم.';

  @override
  String wishlistRequestSent(String name) {
    return 'تم إرسال طلب قائمة الأمنيات إلى $name.';
  }

  @override
  String get noSentRequests => 'لا توجد طلبات مرسلة';

  @override
  String get noSentRequestsDescription => 'ستظهر هنا طلبات قائمة الأمنيات التي ترسلها إلى أفراد العائلة.';

  @override
  String get noReceivedRequests => 'لا توجد طلبات مستلمة';

  @override
  String get noReceivedRequestsDescription => 'عندما يطلب منك أحد أفراد العائلة مكافأة، ستظهر هنا.';

  @override
  String get requestedFrom => 'طُلبت من';

  @override
  String get requestedBy => 'طُلبت بواسطة';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get makeOffer => 'تقديم عرض';

  @override
  String get decline => 'رفض الطلب';

  @override
  String get confirmFulfillment => 'تأكيد تقديم المكافأة';

  @override
  String rewardMarkedFulfilled(String reward) {
    return 'تم اعتماد تقديم $reward.';
  }

  @override
  String rewardAddedToGoals(String reward) {
    return 'تمت إضافة $reward إلى أهداف مكافآتك.';
  }

  @override
  String get offerRejected => 'تم رفض العرض.';

  @override
  String get wishlistRequestDeclined => 'تم رفض طلب قائمة الأمنيات.';

  @override
  String offerForReward(String reward) {
    return 'عرض من أجل $reward';
  }

  @override
  String get offerRequirementsDescription => 'حدد التقدم الذي يجب إنجازه بعد قبول العرض للحصول على هذه المكافأة.';

  @override
  String get tokensRequired => 'الرموز المطلوبة';

  @override
  String get dailyChallengeWins => 'انتصارات التحدي اليومي';

  @override
  String get weeklyChampionshipWins => 'انتصارات البطولة الأسبوعية';

  @override
  String get monthlyCupWins => 'انتصارات الكأس الشهري';

  @override
  String get sendOffer => 'إرسال العرض';

  @override
  String get addOfferRequirement => 'أضف شرطًا واحدًا على الأقل إلى العرض.';

  @override
  String offerSentTo(String name) {
    return 'تم إرسال العرض إلى $name.';
  }

  @override
  String get chooseRewardRecipient => 'اختر الشخص الذي تريد طلب هذه المكافأة منه.';

  @override
  String get rewardMinimumLength => 'اكتب مكافأة من 3 أحرف على الأقل.';

  @override
  String get whatWouldYouLikeToEarn => 'ما الذي تود الحصول عليه؟';

  @override
  String get chooseMemberForOffer => 'اختر فردًا من العائلة واطلب منه تقديم عرض لك.';

  @override
  String get requestFrom => 'اطلب من';

  @override
  String get reward => 'المكافأة';

  @override
  String get rewardExample => 'مثال: نزهة عائلية';

  @override
  String get optionalMessage => 'رسالة (اختيارية)';

  @override
  String get wishlistMessageExample => 'مثال: أود الحصول على هذه المكافأة كهدف طويل المدى.';

  @override
  String get sending => 'جارٍ الإرسال...';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String personLabel(String label, String name) {
    return '$label: $name';
  }

  @override
  String requirementTokens(int count) {
    return '$count رمزًا';
  }

  @override
  String requirementDailyWins(int count) {
    return '$count من انتصارات التحدي اليومي';
  }

  @override
  String requirementWeeklyWins(int count) {
    return '$count من انتصارات البطولة الأسبوعية';
  }

  @override
  String requirementMonthlyWins(int count) {
    return '$count من انتصارات الكأس الشهري';
  }

  @override
  String requirementMissions(int count) {
    return '$count من المهمات المكتملة';
  }

  @override
  String get noRequirementsSet => 'لم يتم تحديد متطلبات.';

  @override
  String get requirements => 'المتطلبات';

  @override
  String get statusRequested => 'تم الطلب';

  @override
  String get statusOfferMade => 'تم تقديم عرض';

  @override
  String get statusActiveGoal => 'هدف نشط';

  @override
  String get statusDeclined => 'مرفوض';

  @override
  String get statusRejected => 'لم يُقبل';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusRedeeming => 'قيد الاستلام';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get wishlistRequests => 'طلبات قائمة الأمنيات';

  @override
  String get myGoals => 'أهدافي';

  @override
  String get myGoalsDescription => 'تظهر عروض قائمة الأمنيات المقبولة هنا وتتحدث مع تقدمك.';

  @override
  String get noActiveGoals => 'لا توجد أهداف نشطة';

  @override
  String get noActiveGoalsDescription => 'اقبل عرضًا من قائمة الأمنيات وسيظهر هدفك هنا.';

  @override
  String redemptionRequestSent(String name) {
    return 'تم إرسال طلب الاستلام إلى $name.';
  }

  @override
  String agreedWith(String name) {
    return 'تم الاتفاق مع $name';
  }

  @override
  String get openedFromNotification => 'فُتح من الإشعار';

  @override
  String get allRequirementsCompleted => 'اكتملت جميع المتطلبات!';

  @override
  String get redeemReward => 'استلام المكافأة';

  @override
  String get waitingForFulfillment => 'بانتظار فرد العائلة الآخر لتأكيد تقديم المكافأة.';

  @override
  String get rewardCompleted => 'اكتملت المكافأة.';

  @override
  String progressCount(int current, int required) {
    return '$current / $required';
  }

  @override
  String milestonesComplete(int complete, int total) {
    return 'اكتمل $complete من أصل $total أهداف مرحلية';
  }

  @override
  String get goalInProgress => 'قيد التقدم';

  @override
  String get goalReadyToRedeem => 'جاهز للاستلام';

  @override
  String get goalAwaitingConfirmation => 'بانتظار التأكيد';

  @override
  String get goalFulfilled => 'تم تقديمه';

  @override
  String get couldNotLoadRewardsAccount => 'تعذر تحميل حساب المكافآت الخاص بك.';

  @override
  String get joinFamilyFirst => 'انضم إلى عائلة أولًا';

  @override
  String get joinFamilyRewardsDescription => 'انضم إلى عائلة أو أنشئ واحدة لاستخدام أهداف قائمة الأمنيات والمكافآت.';

  @override
  String get yourTokens => 'رموزك';

  @override
  String get rewardsIntroTitle => 'حوّل تقدمك إلى مكافآت';

  @override
  String get rewardsIntroDescription => 'اكسب الرموز من المنافسات والمهام العائلية، ثم استخدمها للحصول على تجارب عائلية أو عناصر رقمية.';

  @override
  String get gameNoValidResult => 'انتهت اللعبة دون نتيجة صالحة للاعبين.';

  @override
  String get dailyResultMismatch => 'لا تتطابق نتيجة اللعبة مع تحدي اليوم.';

  @override
  String get dailyTieRewardPending => 'تعادل أعلى رصيد، ولم تُمنح مكافأة التحدي اليومي بعد.';

  @override
  String get dailyAlreadyCompleted => 'اكتمل تحدي اليوم بالفعل.';

  @override
  String dailyWinnerAnnouncement(String name, int tokens, int points) {
    return 'فاز $name بتحدي اليوم! +$tokens رمزًا و+$points نقطة ترتيب.';
  }

  @override
  String get dailyOfficialSaveError => 'تعذر حفظ النتيجة الرسمية لليوم. حاول مجددًا.';

  @override
  String get weeklySignInRequired => 'يجب تسجيل الدخول لاستخدام البطولة الأسبوعية.';

  @override
  String get weeklyFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل لعب البطولة الأسبوعية.';

  @override
  String get weeklyLoadError => 'تعذر تحميل بطولة هذا الأسبوع. حاول مجددًا.';

  @override
  String get weeklyResultMismatch => 'لا تتطابق النتيجة مع جولة البطولة الحالية.';

  @override
  String get weeklyRoundSaveError => 'تعذر حفظ جولة البطولة. حاول مجددًا.';

  @override
  String weeklyWinnerAnnouncement(String name, int tokens, int points) {
    return 'تُوّج $name بطلًا للعائلة هذا الأسبوع! +$tokens رمزًا و+$points نقطة ترتيب.';
  }

  @override
  String get weeklyFinalizeError => 'تعذر اعتماد نتيجة البطولة الأسبوعية. حاول مجددًا.';

  @override
  String competitionProgress(int completed, int total) {
    return 'اكتملت $completed من أصل $total جولات رسمية';
  }

  @override
  String get backToCompetitions => 'العودة إلى المنافسات';

  @override
  String get monthlySignInRequired => 'يجب تسجيل الدخول لاستخدام الكأس الشهري.';

  @override
  String get monthlyFamilyRequired => 'انضم إلى عائلة أو أنشئ واحدة قبل بدء الكأس الشهري.';

  @override
  String get monthlyLoadError => 'تعذر تحميل كأس هذا الشهر. حاول مجددًا.';

  @override
  String get selectExactlyFourMembers => 'اختر 4 أفراد من العائلة بالضبط.';

  @override
  String get monthlyStartError => 'تعذر بدء الكأس الشهري. حاول مجددًا.';

  @override
  String get monthlyResultMismatch => 'لا تتطابق النتيجة مع مباراة الكأس الشهري الحالية.';

  @override
  String get monthlyMatchSaveError => 'تعذر حفظ مباراة الكأس الشهري. حاول مجددًا.';

  @override
  String monthlyWinnerAnnouncement(String name, int tokens, int points) {
    return 'فاز $name بالكأس الشهري! +$tokens رمزًا و+$points نقطة ترتيب.';
  }

  @override
  String get monthlyFinalizeError => 'تعذر اعتماد نتيجة الكأس الشهري. حاول مجددًا.';

  @override
  String competitorsSelected(int selected, int total) {
    return 'تم اختيار $selected من أصل $total متنافسين';
  }

  @override
  String get finalStandings => 'الترتيب النهائي';

  @override
  String get runnerUp => 'الوصيف';

  @override
  String get semifinalist => 'متأهل لنصف النهائي';

  @override
  String get matchHistory => 'سجل المباريات';

  @override
  String officialResultsTitle(String competition) {
    return 'نتائج $competition';
  }

  @override
  String get officialGameResultsReady => 'النتائج الرسمية جاهزة. عُد إلى المنافسة للمتابعة.';

  @override
  String get quickPlayLeaderboard => 'ترتيب اللعب السريع';

  @override
  String get quickPlayResultsOnly => 'نتائج هذه الجلسة فقط — لا تتغير الرموز أو نقاط الترتيب الرسمية.';

  @override
  String gameCompleteTitle(String game) {
    return 'اكتملت $game!';
  }

  @override
  String get backToQuickPlay => 'العودة إلى اللعب السريع';

  @override
  String playerWins(String name) {
    return 'يفوز $name!';
  }

  @override
  String get gameTie => 'تعادل!';

  @override
  String missionProgressSummary(int completed, int total) {
    return 'اكتملت $completed من أصل $total مهام';
  }

  @override
  String get captionFinalLeaderboard => 'تم احتساب كل الأصوات، وهذا هو الترتيب النهائي للجلسة.';

  @override
  String minimumPlayersForGame(String game, int count) {
    return 'تحتاج لعبة $game إلى $count لاعبين على الأقل.';
  }

  @override
  String minimumFamilyMembersForGame(String game, int count) {
    return 'تحتاج لعبة $game إلى $count أفراد من العائلة على الأقل.';
  }

  @override
  String joinOrCreateFamilyBeforeGame(String game) {
    return 'انضم إلى عائلة أو أنشئ واحدة قبل لعب $game.';
  }

  @override
  String couldNotStartGame(String game) {
    return 'تعذر بدء لعبة $game. حاول مجددًا.';
  }

  @override
  String get preparingGame => 'جارٍ تجهيز اللعبة...';

  @override
  String selectedPlayersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count لاعبين',
      two: 'تم اختيار لاعبين',
      one: 'تم اختيار لاعب واحد',
      zero: 'لم يتم اختيار لاعبين',
    );
    return '$_temp0';
  }

  @override
  String get everyoneElseLookAway => 'على الجميع أن ينظروا بعيدًا.';

  @override
  String iAmPlayer(String name) {
    return 'أنا $name';
  }

  @override
  String roundNumber(int number) {
    return 'الجولة $number';
  }

  @override
  String get viewFinalLeaderboard => 'عرض الترتيب النهائي';

  @override
  String get impostorSetupTitle => 'جهّزوا لغزكم';

  @override
  String get impostorSetupDescription => 'اختر فئة واحدة لكل الكلمات السرية، أو أبقِ الجميع في حيرة بمزيج عشوائي.';

  @override
  String get chooseAtLeastThreePlayers => 'اختر 3 أفراد من العائلة موجودين معك على الأقل.';

  @override
  String get randomMix => 'مزيج عشوائي';

  @override
  String get randomMixDescription => 'قد تفاجئكم كل جولة بفئة مختلفة.';

  @override
  String selectedCategoryDescription(String category) {
    return 'ستأتي جميع الكلمات السرية من فئة $category.';
  }

  @override
  String get youAreTheImpostor => 'أنت الدخيل';

  @override
  String categoryLabel(String category) {
    return 'الفئة: $category';
  }

  @override
  String get impostorRoleInstructions => 'أنت لا تعرف الكلمة السرية.\nاندمج مع الآخرين وتجنّب انكشافك.';

  @override
  String get secretWord => 'الكلمة السرية';

  @override
  String get rememberSecretWord => 'تذكّرها ولا تعرضها على أي شخص آخر.';

  @override
  String get hideMyRole => 'إخفاء دوري';

  @override
  String clueRoundNumber(int number) {
    return 'جولة التلميحات $number';
  }

  @override
  String get takeTurnsGivingClues => 'تناوبوا على قول تلميح واحد بصوت عالٍ.';

  @override
  String get clueRules => 'لا تقل الكلمة السرية.\nولا تجعل تلميحك واضحًا جدًا.';

  @override
  String get impostorBluffInstructions => 'على الدخيل التظاهر بالمعرفة ومحاولة الاندماج.';

  @override
  String get everyoneGaveClue => 'قدّم الجميع تلميحًا';

  @override
  String get knowTheImpostorQuestion => 'هل عرفتم من هو الدخيل؟';

  @override
  String clueRoundComplete(int number) {
    return 'اكتملت جولة التلميحات $number.';
  }

  @override
  String get anotherClueRound => 'جولة تلميحات أخرى';

  @override
  String get startVoting => 'بدء التصويت';

  @override
  String get privateVoteInstructions => 'تصويتك سري، وعلى الجميع أن ينظروا بعيدًا.';

  @override
  String whoIsTheImpostor(String name) {
    return '$name، من هو الدخيل؟';
  }

  @override
  String get votingInstructions => 'اختر فردًا واحدًا من العائلة، ولا يمكنك التصويت لنفسك.';

  @override
  String get voteResults => 'نتائج التصويت';

  @override
  String voteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصوات',
      two: 'صوتان',
      one: 'صوت واحد',
      zero: 'لا أصوات',
    );
    return '$_temp0';
  }

  @override
  String get tieVoteAgain => 'تعادل — صوّتوا مجددًا';

  @override
  String revealPlayer(String name) {
    return 'اكشف دور $name';
  }

  @override
  String innocentImpostorEscaped(String innocent, String impostor) {
    return 'كان $innocent بريئًا!\n\nكان $impostor هو الدخيل وتمكن من الإفلات.';
  }

  @override
  String get impostorWasCaught => 'تم اكتشاف الدخيل!';

  @override
  String playerIsImpostor(String name) {
    return '$name هو الدخيل.';
  }

  @override
  String get impostorFinalChance => 'لديك فرصة أخيرة.\nخمّن الكلمة السرية لتسرق الجولة.';

  @override
  String get submitGuess => 'إرسال التخمين';

  @override
  String get enterGuessFirst => 'أدخل تخمينك أولًا.';

  @override
  String caughtButGuessedCorrectly(String name, String word) {
    return 'تم اكتشاف $name، لكنه خمّن «$word» بشكل صحيح وسرق الجولة!';
  }

  @override
  String incorrectImpostorGuess(String name, String guess, String word) {
    return 'خمّن $name «$guess».\n\nكانت الكلمة السرية «$word».\n\nتفوز العائلة بهذه الجولة!';
  }

  @override
  String get impostorWins => 'يفوز الدخيل!';

  @override
  String get familyWins => 'تفوز العائلة!';

  @override
  String secretWordLabel(String word) {
    return 'الكلمة السرية: $word';
  }

  @override
  String get drawingTurnEachRound => 'يحصل كل رسام مختار على دور رسم واحد في كل جولة.';

  @override
  String artistDrawingPrompt(String name) {
    return '$name، المطلوب منك رسم:';
  }

  @override
  String get rememberDrawingPrompt => 'تذكّر المطلوب ولا تعرضه على اللاعبين الآخرين.';

  @override
  String get startDrawing => 'ابدأ الرسم';

  @override
  String get drawingTimeUp => 'انتهى الوقت!\n\nلم يخمّن أحد الرسمة في هذه الجولة.';

  @override
  String playerIsDrawing(String name) {
    return '$name يرسم الآن';
  }

  @override
  String get guessAloud => 'على الجميع التخمين بصوت عالٍ!';

  @override
  String get brush => 'الفرشاة:';

  @override
  String get thin => 'رفيعة';

  @override
  String get medium => 'متوسطة';

  @override
  String get thick => 'سميكة';

  @override
  String get undo => 'تراجع';

  @override
  String get eraser => 'ممحاة';

  @override
  String get eraserOn => 'الممحاة مفعّلة';

  @override
  String get clear => 'مسح';

  @override
  String get someoneGuessedIt => 'خمّنها أحدهم';

  @override
  String get whoGuessedIt => 'من خمّنها؟';

  @override
  String get chooseCorrectGuesser => 'اختر فرد العائلة الذي خمّن الرسمة بشكل صحيح.';

  @override
  String drawingCorrectPoints(String guesser, String artist) {
    return 'خمّن $guesser بشكل صحيح!\n\n$artist +1 نقطة\n$guesser +1 نقطة';
  }

  @override
  String promptLabel(String prompt) {
    return 'المطلوب: $prompt';
  }

  @override
  String get nextArtist => 'الرسام التالي';

  @override
  String officialMatchInvalidPlayers(String game) {
    return 'لا تحتوي مباراة $game الرسمية هذه على عدد كافٍ من أفراد العائلة الصالحين.';
  }

  @override
  String get timePerTurn => 'وقت كل دور';

  @override
  String playerSecretWord(String name) {
    return '$name، كلمتك هي:';
  }

  @override
  String get dontSayHeading => 'لا تقل:';

  @override
  String get rememberWordCard => 'تذكّر البطاقة ولا تدع أي شخص آخر يراها.';

  @override
  String get startTurn => 'ابدأ الدور';

  @override
  String get turnTimeUp => 'انتهى الوقت! لا نقاط في هذا الدور.';

  @override
  String playerIsDescribing(String name) {
    return '$name يصف الكلمة';
  }

  @override
  String get skip => 'تخطٍّ';

  @override
  String get turnSkipped => 'تم تخطي الدور دون منح نقاط.';

  @override
  String get chooseSecretWordGuesser => 'اختر اللاعب الذي خمّن الكلمة السرية بشكل صحيح.';

  @override
  String clueGiverPointResult(String guesser, String clueGiver) {
    return 'خمّن $guesser بشكل صحيح!\n\n$clueGiver +1 نقطة';
  }

  @override
  String sharedPointResult(String guesser, String clueGiver) {
    return 'خمّن $guesser بشكل صحيح!\n\n$clueGiver +1 نقطة\n$guesser +1 نقطة';
  }

  @override
  String get turnComplete => 'اكتمل الدور';

  @override
  String get answerAlreadyUsed => 'استُخدمت هذه الإجابة في الجولة! جرّب إجابة أخرى.';

  @override
  String get answerDoesNotFitCategory => 'هذه الإجابة لا تناسب الفئة. حاول مجددًا!';

  @override
  String reasonTryAgain(String reason) {
    return '$reason حاول مجددًا!';
  }

  @override
  String get couldNotCheckAnswer => 'تعذر التحقق من الإجابة. حاول مجددًا.';

  @override
  String get chooseTogetherPlayers => 'اختر أفراد العائلة الموجودين معك. سيشارك الجميع هذا الهاتف.';

  @override
  String get bombSetupInstructions => 'أجب بسرعة ومرّر الهاتف ولا تكرر أي إجابة.';

  @override
  String get generatingCategories => 'جارٍ تجهيز الفئات...';

  @override
  String playerTurn(String name) {
    return 'دور $name';
  }

  @override
  String get sayTypePass => 'قل إجابتك بصوت عالٍ واكتبها أدناه، ثم مرّر الهاتف فورًا.';

  @override
  String get yourAnswer => 'إجابتك';

  @override
  String get checkingAnswer => 'جارٍ التحقق من الإجابة...';

  @override
  String get typeSpokenAnswer => 'اكتب الإجابة التي قلتها للتو';

  @override
  String get submitAndPassPhone => 'إرسال وتمرير الهاتف';

  @override
  String get bombHiddenTimer => 'قد تنفجر القنبلة في أي لحظة، فالمؤقت مخفي!';

  @override
  String answersUsedThisRound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استُخدمت $count إجابات في هذه الجولة',
      two: 'استُخدمت إجابتان في هذه الجولة',
      one: 'استُخدمت إجابة واحدة في هذه الجولة',
      zero: 'لم تُستخدم إجابات في هذه الجولة',
    );
    return '$_temp0';
  }

  @override
  String get boom => 'بووم!';

  @override
  String playerHeldBomb(String name) {
    return 'كان $name يحمل القنبلة!';
  }

  @override
  String get bombSurvivorPoint => 'يحصل كل من نجا في الجولة على نقطة واحدة.';

  @override
  String get choosePlayers => 'اختر اللاعبين';

  @override
  String get chooseQuickPlayMembers => 'اختر أفراد العائلة الموجودين معك في جلسة اللعب السريع هذه.';

  @override
  String get chooseGame => 'اختر اللعبة';

  @override
  String get memoryChallenge => 'تحدي الذكريات';

  @override
  String get memoryNeedsPhoto => 'تحتاج عائلتك إلى ذكرى واحدة تحتوي على صورة على الأقل قبل اللعب.';

  @override
  String get memoryChallengeCreateError => 'تعذر إنشاء تحدي الذكريات الآن. حاول مجددًا.';

  @override
  String get familyMemoryFallback => 'ذكرى عائلية';

  @override
  String get howWellRemember => 'ما مدى قوة ذاكرتك؟';

  @override
  String get memoryChallengeSetupDescription => 'تستخدم صلة صور عائلتك وقصصها لإنشاء أسئلة فريدة من اللحظات التي شاركتموها معًا.';

  @override
  String get creatingChallenge => 'جارٍ إنشاء التحدي...';

  @override
  String get startMemoryChallenge => 'ابدأ تحدي الذكريات';

  @override
  String questionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get correct => 'إجابة صحيحة!';

  @override
  String correctAnswerLabel(String answer) {
    return 'الإجابة الصحيحة: $answer';
  }

  @override
  String get nextMemory => 'الذكرى التالية';

  @override
  String get memoryChallengeComplete => 'اكتمل تحدي الذكريات!';

  @override
  String scoreProgress(int score, int total) {
    return 'النتيجة: $score / $total';
  }

  @override
  String get couldNotLoadCaptionBattle => 'تعذر تحميل معركة التعليقات';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get captionBattleSetupDescription => 'يكتب الجميع تعليقًا على صورة العائلة نفسها، ثم تُخلط التعليقات وتصوّت العائلة بسرية.';

  @override
  String get howItWorks => 'طريقة اللعب';

  @override
  String get captionRulePhoto => 'تظهر صورة حقيقية من ذكريات العائلة في كل جولة.';

  @override
  String get captionRuleWrite => 'يكتب كل لاعب تعليقًا واحدًا بسرية.';

  @override
  String get captionRuleShuffle => 'تُخلط التعليقات لإخفاء أصحابها.';

  @override
  String get captionRuleVote => 'يصوّت الجميع، لكن لا يمكن لأي لاعب التصويت لنفسه.';

  @override
  String get captionRulePoint => 'يمنح كل صوت نقطة محلية واحدة في اللعب السريع.';

  @override
  String get promptVariety => 'تنوع التحديات';

  @override
  String get promptVarietyDescription => 'اختر نوع التحدي الإبداعي الذي تريده عائلتك.';

  @override
  String get captionStyleSurprise => 'فاجئني';

  @override
  String get captionStyleStorytelling => 'سرد القصص';

  @override
  String get captionStyleHeadlines => 'عناوين ومنشورات';

  @override
  String get captionStyleWild => 'أفكار جامحة';

  @override
  String get familyPhotos => 'صور العائلة';

  @override
  String get noPhotoMemories => 'لم يتم العثور على ذكريات تحتوي على صور.';

  @override
  String photoMemoriesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تتوفر $count ذكريات مصورة.',
      two: 'تتوفر ذكريان مصورتان.',
      one: 'تتوفر ذكرى مصورة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get addPhotoMemoryFirst => 'أضف ذكرى تحتوي على صورة أولًا، ثم عُد إلى هنا.';

  @override
  String captionBattleRoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولات.',
      two: 'جولتين.',
      one: 'جولة واحدة.',
    );
    return 'ستتضمن هذه اللعبة $_temp0';
  }

  @override
  String get captionRoundPhotoDescription => 'تستخدم كل جولة صورة عائلية مختلفة. وتفتح الصور الإضافية خيارات 3 و5 جولات.';

  @override
  String get selectAtLeastTwoFamilyMembers => 'اختر فردين من العائلة على الأقل.';

  @override
  String get captionBattleNeedsPhoto => 'تحتاج معركة التعليقات إلى ذكرى واحدة تحتوي على صورة على الأقل.';

  @override
  String get quickPlayNoRanking => 'لعب سريع فقط • من دون رموز أو ترتيب عام';

  @override
  String takeThePhone(String name) {
    return '$name، خذ الهاتف';
  }

  @override
  String get keepCaptionPrivate => 'تأكد من أن لا أحد يمكنه رؤية تعليقك.';

  @override
  String get imReady => 'أنا جاهز';

  @override
  String get yourChallenge => 'تحديك';

  @override
  String get writeYourCaption => 'اكتب تعليقك';

  @override
  String get writeCaptionFirst => 'اكتب تعليقًا قبل المتابعة.';

  @override
  String get submitFinalCaption => 'إرسال التعليق الأخير';

  @override
  String get privateCaptionVote => 'صوّت بسرية لتعليقك المفضل. لن تتمكن من التصويت لتعليقك.';

  @override
  String get showCaptions => 'عرض التعليقات';

  @override
  String chooseFavoriteCaption(String name) {
    return '$name، اختر تعليقك المفضل';
  }

  @override
  String get captionAuthorsHidden => 'يبقى أصحاب التعليقات مخفيين حتى يصوّت الجميع.';

  @override
  String get cannotVoteOwnCaption => 'لا يمكنك التصويت لتعليقك.';

  @override
  String get captionReveal => 'كشف التعليقات';

  @override
  String get finalLeaderboard => 'الترتيب النهائي';

  @override
  String developerFamilyMemory(int number) {
    return 'ذكرى عائلية تجريبية $number';
  }

  @override
  String subjectPrivateAnswer(String name) {
    return 'على الجميع أن ينظروا بعيدًا بينما يختار $name إجابة سرية.';
  }

  @override
  String guesserPrivateGuess(String guesser, String subject) {
    return 'سيخمّن $guesser بسرية ما اختاره $subject.';
  }

  @override
  String get votesArePrivate => 'الأصوات سرية، وعلى الجميع أن ينظروا بعيدًا.';

  @override
  String chooseRealAnswer(String name) {
    return '$name، اختر إجابتك الحقيقية';
  }

  @override
  String get predictTheirChoice => 'سيحاول الجميع توقع ما اخترته.';

  @override
  String whatDidPlayerChoose(String name) {
    return 'ماذا اختار $name؟';
  }

  @override
  String makePrivateGuess(String name) {
    return '$name، أدخل تخمينك السري.';
  }

  @override
  String playerChose(String name) {
    return 'اختار $name:';
  }

  @override
  String get nobodyGuessedCorrectly => 'لم يخمّن أحد بشكل صحيح!';

  @override
  String playersGuessedCorrectly(String names) {
    return 'خمّن $names بشكل صحيح!';
  }

  @override
  String get onePointEach => '+1 نقطة لكل لاعب';

  @override
  String choosePrivately(String name) {
    return '$name، اختر بسرية.';
  }

  @override
  String get submitPrivateVote => 'إرسال التصويت السري';

  @override
  String playerReceivedMostVotes(String name) {
    return 'حصل $name على أكبر عدد من الأصوات!';
  }

  @override
  String get nextVote => 'التصويت التالي';

  @override
  String get couldNotGenerateMissions => 'تعذر تجهيز المهام السرية. حاول مجددًا بعد قليل.';

  @override
  String get couldNotGenerateNextRound => 'تعذر تجهيز الجولة التالية. حاول مجددًا.';

  @override
  String get missionTimeUp => 'انتهى الوقت! حان وقت كشف المهام وتقييمها.';

  @override
  String get finishRoundEarlyTitle => 'إنهاء الجولة مبكرًا؟';

  @override
  String get finishRoundEarlyDescription => 'سيتوقف المؤقت وسينتقل الجميع إلى تقييم المهام.';

  @override
  String get keepPlaying => 'متابعة اللعب';

  @override
  String get finishRound => 'إنهاء الجولة';

  @override
  String get chooseMissionPlayers => 'اختر أفراد العائلة الذين سيلعبون معًا على هذا الهاتف.';

  @override
  String secretMissionSetupSummary(int rounds) {
    String _temp0 = intl.Intl.pluralLogic(
      rounds,
      locale: localeName,
      other: '$rounds جولات',
      two: 'جولتان',
      one: 'جولة واحدة',
    );
    return '$_temp0 • 10 دقائق لكل جولة • مهمة سرية واحدة لكل لاعب في كل جولة.';
  }

  @override
  String get secretMissionSetupInstructions => 'أنجز مهمتك بصورة طبيعية من دون أن يكتشفها الآخرون.';

  @override
  String generatingRound(int number) {
    return 'جارٍ تجهيز الجولة $number...';
  }

  @override
  String playerProgress(int current, int total) {
    return 'اللاعب $current من $total';
  }

  @override
  String get keepScreenPrivate => 'تأكد من أن لا أحد آخر يرى الشاشة.';

  @override
  String get revealMyMission => 'اكشف مهمتي';

  @override
  String get yourSecretMission => 'مهمتك السرية';

  @override
  String get rememberMission => 'تذكّرها ولا تخبر أحدًا.';

  @override
  String get hideMissionStartRound => 'إخفاء المهمة وبدء جولة 10 دقائق';

  @override
  String get hideMissionPassPhone => 'إخفاء المهمة وتمرير الهاتف';

  @override
  String get missionsAreLive => 'بدأت المهام!';

  @override
  String get missionsLiveInstructions => 'ضع الهاتف وتصرف بطبيعتك. أنجز مهمتك من دون أن تكون واضحة.';

  @override
  String get timeRemaining => 'الوقت المتبقي';

  @override
  String get missionAutoJudge => 'ستنتقل الجولة تلقائيًا إلى التقييم عندما يصل المؤقت إلى 00:00.';

  @override
  String get finishRoundEarly => 'إنهاء الجولة مبكرًا';

  @override
  String judgeProgress(int current, int total) {
    return 'التقييم $current من $total';
  }

  @override
  String get missionCompletedQuestion => 'هل نجح اللاعب في إنجاز المهمة خلال هذه الجولة؟';

  @override
  String get notCompleted => 'لم تكتمل';

  @override
  String get completedPlusOne => 'مكتملة +1';

  @override
  String roundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولات متبقية',
      two: 'جولتان متبقيتان',
      one: 'جولة واحدة متبقية',
      zero: 'لا جولات متبقية',
    );
    return '$_temp0';
  }

  @override
  String get missionCompletedThisRound => 'اكتملت المهمة في هذه الجولة';

  @override
  String get missionNotCompletedThisRound => 'لم تكتمل المهمة في هذه الجولة';

  @override
  String get previewPlayer => 'لاعب تجريبي';

  @override
  String get monthlyInvalidWinner => 'أعادت المباراة فائزًا ليس أحد المتنافسين المحددين. يُرجى إعادة المباراة.';
}
