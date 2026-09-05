import 'dart:math';

class OfflineQuizQuestion {
  const OfflineQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
}

abstract final class OfflineQuizBank {
  static List<OfflineQuizQuestion> questions({
    required String category,
    required int count,
    required String languageCode,
    Random? random,
  }) {
    if (count <= 0) return const [];

    final bank = languageCode.toLowerCase().startsWith('ar')
        ? _arabic
        : _english;
    final preferred = bank[category] ?? const <OfflineQuizQuestion>[];
    final general = bank['General Knowledge'] ?? const <OfflineQuizQuestion>[];
    final pool = category == 'Mixed'
        ? bank.values.expand((questions) => questions).toList()
        : <OfflineQuizQuestion>[...preferred, ...general];

    if (pool.isEmpty) {
      pool.addAll(bank.values.expand((questions) => questions));
    }

    pool.shuffle(random ?? Random.secure());
    return List<OfflineQuizQuestion>.generate(
      count,
      (index) => pool[index % pool.length],
      growable: false,
    );
  }

  static const Map<String, List<OfflineQuizQuestion>> _english = {
    'Science': [
      OfflineQuizQuestion(
        question: 'Which is the largest planet in our solar system?',
        options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which gas do plants absorb from the air?',
        options: ['Oxygen', 'Carbon dioxide', 'Helium', 'Hydrogen'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'At what temperature does water freeze in Celsius?',
        options: ['0°C', '10°C', '50°C', '100°C'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'Which organ pumps blood around the body?',
        options: ['Lungs', 'Brain', 'Heart', 'Stomach'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which planet is known as the Red Planet?',
        options: ['Mercury', 'Mars', 'Saturn', 'Neptune'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'What force pulls objects toward Earth?',
        options: ['Magnetism', 'Friction', 'Gravity', 'Electricity'],
        correctIndex: 2,
      ),
    ],
    'Geography': [
      OfflineQuizQuestion(
        question: 'What is the capital of the UAE?',
        options: ['Dubai', 'Sharjah', 'Abu Dhabi', 'Ajman'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which is the largest ocean?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctIndex: 3,
      ),
      OfflineQuizQuestion(
        question: 'On which continent is Egypt?',
        options: ['Africa', 'Europe', 'Asia', 'South America'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'In which city is the Burj Khalifa?',
        options: ['Abu Dhabi', 'Dubai', 'Al Ain', 'Fujairah'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'What is the capital of Japan?',
        options: ['Kyoto', 'Osaka', 'Tokyo', 'Nagoya'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'On which continent is the Sahara Desert?',
        options: ['Asia', 'Australia', 'Africa', 'Europe'],
        correctIndex: 2,
      ),
    ],
    'History': [
      OfflineQuizQuestion(
        question: 'In which year was the UAE founded?',
        options: ['1961', '1971', '1981', '1991'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'Which ancient civilization built the Giza pyramids?',
        options: ['Romans', 'Vikings', 'Egyptians', 'Aztecs'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Who was the first person to walk on the Moon?',
        options: [
          'Yuri Gagarin',
          'Neil Armstrong',
          'Buzz Aldrin',
          'John Glenn',
        ],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'What was the Silk Road mainly used for?',
        options: ['Trade', 'Sport', 'Farming', 'Space travel'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'What do museums preserve for future generations?',
        options: ['Weather', 'Historical objects', 'Traffic', 'Phone calls'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'Which invention helped books reach more people?',
        options: ['Compass', 'Printing press', 'Telescope', 'Steam engine'],
        correctIndex: 1,
      ),
    ],
    'Sports': [
      OfflineQuizQuestion(
        question: 'How many players from one football team are on the field?',
        options: ['9', '10', '11', '12'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which sport is played with a racket and a net?',
        options: ['Tennis', 'Swimming', 'Cycling', 'Archery'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'How often are the Summer Olympic Games normally held?',
        options: [
          'Every year',
          'Every 2 years',
          'Every 4 years',
          'Every 6 years',
        ],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'How many points is a shot beyond the basketball arc worth?',
        options: ['1', '2', '3', '4'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'A marathon is closest to which distance?',
        options: ['10 km', '21 km', '42 km', '100 km'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question:
            'Which football player may use hands inside the penalty area?',
        options: ['Striker', 'Goalkeeper', 'Winger', 'Midfielder'],
        correctIndex: 1,
      ),
    ],
    'Entertainment': [
      OfflineQuizQuestion(
        question: 'Which Frozen character has ice powers?',
        options: ['Anna', 'Elsa', 'Olaf', 'Kristoff'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'What is the name of the young lion in The Lion King?',
        options: ['Simba', 'Baloo', 'Nemo', 'Bambi'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'Which Toy Story character is a cowboy?',
        options: ['Buzz', 'Rex', 'Woody', 'Slinky'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which instrument has black and white keys?',
        options: ['Violin', 'Piano', 'Drum', 'Flute'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'What is Harry Potter’s school called?',
        options: ['Narnia', 'Hogwarts', 'Neverland', 'Oz'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'Which hero is the protector of Wakanda?',
        options: ['Black Panther', 'Superman', 'Aquaman', 'The Flash'],
        correctIndex: 0,
      ),
    ],
    'General Knowledge': [
      OfflineQuizQuestion(
        question: 'How many days are in one week?',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'How many colors are on the UAE flag?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which animal makes honey?',
        options: ['Butterfly', 'Bee', 'Ant', 'Beetle'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'How many sides does a triangle have?',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'How many months are in a year?',
        options: ['10', '11', '12', '13'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'Which animal is especially suited to desert travel?',
        options: ['Camel', 'Penguin', 'Dolphin', 'Panda'],
        correctIndex: 0,
      ),
    ],
  };

  static const Map<String, List<OfflineQuizQuestion>> _arabic = {
    'Science': [
      OfflineQuizQuestion(
        question: 'ما أكبر كوكب في مجموعتنا الشمسية؟',
        options: ['الأرض', 'المريخ', 'المشتري', 'الزهرة'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي غاز تمتصه النباتات من الهواء؟',
        options: ['الأكسجين', 'ثاني أكسيد الكربون', 'الهيليوم', 'الهيدروجين'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'عند أي درجة مئوية يتجمد الماء؟',
        options: ['0°', '10°', '50°', '100°'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'أي عضو يضخ الدم في الجسم؟',
        options: ['الرئتان', 'الدماغ', 'القلب', 'المعدة'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي كوكب يُعرف بالكوكب الأحمر؟',
        options: ['عطارد', 'المريخ', 'زحل', 'نبتون'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'ما القوة التي تجذب الأشياء نحو الأرض؟',
        options: ['المغناطيسية', 'الاحتكاك', 'الجاذبية', 'الكهرباء'],
        correctIndex: 2,
      ),
    ],
    'Geography': [
      OfflineQuizQuestion(
        question: 'ما عاصمة دولة الإمارات؟',
        options: ['دبي', 'الشارقة', 'أبوظبي', 'عجمان'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'ما أكبر محيط في العالم؟',
        options: ['الأطلسي', 'الهندي', 'المتجمد الشمالي', 'الهادئ'],
        correctIndex: 3,
      ),
      OfflineQuizQuestion(
        question: 'في أي قارة تقع مصر؟',
        options: ['أفريقيا', 'أوروبا', 'آسيا', 'أمريكا الجنوبية'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'في أي مدينة يقع برج خليفة؟',
        options: ['أبوظبي', 'دبي', 'العين', 'الفجيرة'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'ما عاصمة اليابان؟',
        options: ['كيوتو', 'أوساكا', 'طوكيو', 'ناغويا'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'في أي قارة تقع الصحراء الكبرى؟',
        options: ['آسيا', 'أستراليا', 'أفريقيا', 'أوروبا'],
        correctIndex: 2,
      ),
    ],
    'History': [
      OfflineQuizQuestion(
        question: 'في أي عام تأسست دولة الإمارات؟',
        options: ['1961', '1971', '1981', '1991'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'أي حضارة قديمة بنت أهرامات الجيزة؟',
        options: ['الرومان', 'الفايكنغ', 'المصريون القدماء', 'الأزتك'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'من أول إنسان مشى على سطح القمر؟',
        options: ['يوري غاغارين', 'نيل أرمسترونغ', 'باز ألدرن', 'جون غلين'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'فيمَ كان يُستخدم طريق الحرير أساسًا؟',
        options: ['التجارة', 'الرياضة', 'الزراعة', 'السفر الفضائي'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'ماذا تحفظ المتاحف للأجيال القادمة؟',
        options: ['الطقس', 'القطع التاريخية', 'المرور', 'المكالمات'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'أي اختراع ساعد على وصول الكتب إلى عدد أكبر من الناس؟',
        options: ['البوصلة', 'المطبعة', 'التلسكوب', 'المحرك البخاري'],
        correctIndex: 1,
      ),
    ],
    'Sports': [
      OfflineQuizQuestion(
        question: 'كم لاعبًا من فريق كرة قدم واحد يوجد في الملعب؟',
        options: ['9', '10', '11', '12'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي رياضة تُلعب بالمضرب والشبكة؟',
        options: ['التنس', 'السباحة', 'ركوب الدراجات', 'الرماية'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'كل كم سنة تُقام الألعاب الأولمبية الصيفية عادة؟',
        options: ['كل سنة', 'كل سنتين', 'كل 4 سنوات', 'كل 6 سنوات'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'كم نقطة تساوي الرمية من خارج قوس كرة السلة؟',
        options: ['1', '2', '3', '4'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'ما المسافة الأقرب لسباق الماراثون؟',
        options: ['10 كم', '21 كم', '42 كم', '100 كم'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي لاعب كرة قدم يمكنه استخدام يديه داخل منطقة الجزاء؟',
        options: ['المهاجم', 'حارس المرمى', 'الجناح', 'لاعب الوسط'],
        correctIndex: 1,
      ),
    ],
    'Entertainment': [
      OfflineQuizQuestion(
        question: 'أي شخصية في فيلم فروزن تملك قوى الجليد؟',
        options: ['آنا', 'إلسا', 'أولاف', 'كريستوف'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'ما اسم الأسد الصغير في فيلم الأسد الملك؟',
        options: ['سيمبا', 'بالو', 'نيمو', 'بامبي'],
        correctIndex: 0,
      ),
      OfflineQuizQuestion(
        question: 'أي شخصية في توي ستوري هي راعي بقر؟',
        options: ['باز', 'ريكس', 'وودي', 'سلينكي'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي آلة موسيقية لها مفاتيح سوداء وبيضاء؟',
        options: ['الكمان', 'البيانو', 'الطبل', 'الناي'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'ما اسم مدرسة هاري بوتر؟',
        options: ['نارنيا', 'هوغوورتس', 'نيفرلاند', 'أوز'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'أي بطل يحمي واكاندا؟',
        options: ['النمر الأسود', 'سوبرمان', 'أكوامان', 'فلاش'],
        correctIndex: 0,
      ),
    ],
    'General Knowledge': [
      OfflineQuizQuestion(
        question: 'كم يومًا في الأسبوع؟',
        options: ['5', '6', '7', '8'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'كم لونًا في علم دولة الإمارات؟',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي حيوان يصنع العسل؟',
        options: ['الفراشة', 'النحلة', 'النملة', 'الخنفساء'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'كم ضلعًا للمثلث؟',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
      ),
      OfflineQuizQuestion(
        question: 'كم شهرًا في السنة؟',
        options: ['10', '11', '12', '13'],
        correctIndex: 2,
      ),
      OfflineQuizQuestion(
        question: 'أي حيوان مناسب خصوصًا للسفر في الصحراء؟',
        options: ['الجمل', 'البطريق', 'الدلفين', 'الباندا'],
        correctIndex: 0,
      ),
    ],
  };
}
