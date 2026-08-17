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
  String get navMemories => 'الذكريات';

  @override
  String get navPlay => 'اللعب';

  @override
  String get navMissions => 'المهام';

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
}
