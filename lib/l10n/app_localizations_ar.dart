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
  String get uaeFamilyYearThemeDescription => 'ألوان عائلية دافئة مستوحاة من الإمارات';

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

  @override
  String get welcomePrivateFamilySpace => 'مساحة عائلية خاصة للقصص المشتركة والتحديات الممتعة واللحظات التي تبقي الجميع على تواصل.';

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
  String get deleteMemoryQuestion => 'حذف الذكرى؟';

  @override
  String get deleteMemoryWarning => 'ستتم إزالة هذه الذكرى نهائيًا من ذكريات عائلتك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get memoryNotFound => 'لم يتم العثور على الذكرى.';

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
    return 'تم منح $tokens من الرموز لكل مشارك.\n\n$participants\n\nتمت إضافة مهمة عائلية مشتركة جديدة.';
  }

  @override
  String personalMissionRewardSuccess(int tokens) {
    return 'ربحت $tokens من الرموز.\n\nتمت إضافة مهمة شخصية جديدة.';
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
    return '$count مهام شخصية لك';
  }

  @override
  String sharedMissionsSubtitle(int count) {
    return '$count مهام مشتركة — أكملوا كل مهمة مرة واحدة كعائلة';
  }

  @override
  String get recentlyCompleted => 'أُنجزت مؤخرًا';

  @override
  String get doMoreTogether => 'أنجزوا المزيد معًا';

  @override
  String missionsHeaderDescription(int count) {
    return '$count مهام نشطة بإثبات يتحقق منه الذكاء الاصطناعي ومكافآت عادلة وتحديات جديدة مع تقدمكم.';
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
}
