import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class DontSayItCard {
  const DontSayItCard({required this.word, required this.forbiddenWords});

  final String word;
  final List<String> forbiddenWords;

  factory DontSayItCard.fromJson(Map<String, dynamic> json) {
    return DontSayItCard(
      word: json['word'] as String,
      forbiddenWords: List<String>.from(
        json['forbiddenWords'] as List<dynamic>,
      ),
    );
  }
}

class DontSayItAiService {
  const DontSayItAiService();

  Future<List<DontSayItCard>> generateCards({
    required int count,
    required String languageCode,
  }) async {
    final response = await http
        .post(
          ApiConfig.endpoint('/api/dont-say-it'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({'count': count, 'language': languageCode}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to generate Don\'t Say It cards');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final cards = data['cards'] as List<dynamic>;

    return cards
        .map((item) => DontSayItCard.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<DontSayItCard> offlineCards({
    required int count,
    required String languageCode,
    Random? random,
  }) {
    final cards = languageCode == 'ar'
        ? <DontSayItCard>[
            const DontSayItCard(
              word: 'شاطئ',
              forbiddenWords: ['بحر', 'رمل', 'سباحة'],
            ),
            const DontSayItCard(
              word: 'مجبوس',
              forbiddenWords: ['أرز', 'طعام', 'دجاج'],
            ),
            const DontSayItCard(
              word: 'صقر',
              forbiddenWords: ['طائر', 'يطير', 'ريش'],
            ),
            const DontSayItCard(
              word: 'مدرسة',
              forbiddenWords: ['طالب', 'معلم', 'درس'],
            ),
            const DontSayItCard(
              word: 'هاتف',
              forbiddenWords: ['اتصال', 'شاشة', 'تطبيق'],
            ),
            const DontSayItCard(
              word: 'عيد ميلاد',
              forbiddenWords: ['كعكة', 'هدية', 'شموع'],
            ),
            const DontSayItCard(
              word: 'كرة قدم',
              forbiddenWords: ['هدف', 'ملعب', 'لاعب'],
            ),
            const DontSayItCard(
              word: 'سفر',
              forbiddenWords: ['طائرة', 'حقيبة', 'فندق'],
            ),
          ]
        : <DontSayItCard>[
            const DontSayItCard(
              word: 'Beach',
              forbiddenWords: ['Sea', 'Sand', 'Swim'],
            ),
            const DontSayItCard(
              word: 'Machboos',
              forbiddenWords: ['Rice', 'Food', 'Chicken'],
            ),
            const DontSayItCard(
              word: 'Falcon',
              forbiddenWords: ['Bird', 'Fly', 'Feathers'],
            ),
            const DontSayItCard(
              word: 'School',
              forbiddenWords: ['Student', 'Teacher', 'Lesson'],
            ),
            const DontSayItCard(
              word: 'Phone',
              forbiddenWords: ['Call', 'Screen', 'App'],
            ),
            const DontSayItCard(
              word: 'Birthday',
              forbiddenWords: ['Cake', 'Gift', 'Candles'],
            ),
            const DontSayItCard(
              word: 'Football',
              forbiddenWords: ['Goal', 'Pitch', 'Player'],
            ),
            const DontSayItCard(
              word: 'Travel',
              forbiddenWords: ['Plane', 'Suitcase', 'Hotel'],
            ),
          ];
    cards.shuffle(random ?? Random.secure());
    return List<DontSayItCard>.generate(
      count,
      (index) => cards[index % cards.length],
    );
  }
}
