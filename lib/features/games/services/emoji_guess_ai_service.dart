import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class EmojiGuessPuzzle {
  final String emojis;
  final String answer;
  final String hint;

  const EmojiGuessPuzzle({
    required this.emojis,
    required this.answer,
    required this.hint,
  });

  factory EmojiGuessPuzzle.fromJson(Map<String, dynamic> json) {
    return EmojiGuessPuzzle(
      emojis: json['emojis'] as String,
      answer: json['answer'] as String,
      hint: json['hint'] as String,
    );
  }
}

class EmojiGuessAiService {
  Future<List<EmojiGuessPuzzle>> generatePuzzles({
    required String category,
    required int count,
    required String languageCode,
  }) async {
    try {
      final response = await http
          .post(
            ApiConfig.endpoint('/api/emoji-guess'),
            headers: await ApiConfig.authenticatedJsonHeaders(),
            body: jsonEncode({
              'category': category,
              'count': count,
              'language': languageCode,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to generate Emoji Guess puzzles');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final puzzles = (data['puzzles'] as List<dynamic>)
          .map(
            (item) => EmojiGuessPuzzle.fromJson(item as Map<String, dynamic>),
          )
          .where(
            (puzzle) =>
                puzzle.emojis.trim().isNotEmpty &&
                puzzle.answer.trim().isNotEmpty &&
                puzzle.hint.trim().isNotEmpty,
          )
          .take(count)
          .toList();

      if (puzzles.length == count) return puzzles;
    } catch (_) {
      // A bilingual local bank keeps the family game playable when AI is down.
    }

    return offlinePuzzles(
      category: category,
      count: count,
      languageCode: languageCode,
    );
  }

  Future<bool> checkAnswer({
    required String expectedAnswer,
    required String playerAnswer,
    required String languageCode,
  }) async {
    final normalizedExpected = _normalize(expectedAnswer);
    final normalizedPlayer = _normalize(playerAnswer);

    if (normalizedExpected.isEmpty || normalizedPlayer.isEmpty) {
      return false;
    }

    if (normalizedExpected == normalizedPlayer) {
      return true;
    }
    if (normalizedExpected.contains(normalizedPlayer) ||
        normalizedPlayer.contains(normalizedExpected)) {
      return true;
    }

    final response = await http
        .post(
          ApiConfig.endpoint('/api/emoji-guess/check-answer'),
          headers: await ApiConfig.authenticatedJsonHeaders(),
          body: jsonEncode({
            'expectedAnswer': expectedAnswer,
            'playerAnswer': playerAnswer,
            'language': languageCode,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['match'] == true;
  }

  String _normalize(String value) {
    final ignoredWords = {'the', 'a', 'an'};

    final words = value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty && !ignoredWords.contains(word))
        .toList();

    return words.join(' ');
  }

  static List<EmojiGuessPuzzle> offlinePuzzles({
    required String category,
    required int count,
    required String languageCode,
    Random? random,
  }) {
    final bank = languageCode == 'ar' ? _arabicBank : _englishBank;
    final selected = category == 'Mixed'
        ? bank.values.expand((puzzles) => puzzles).toList()
        : List<EmojiGuessPuzzle>.from(bank[category] ?? bank['Movies']!);
    selected.shuffle(random ?? Random.secure());

    return List<EmojiGuessPuzzle>.generate(
      count,
      (index) => selected[index % selected.length],
      growable: false,
    );
  }

  static const Map<String, List<EmojiGuessPuzzle>> _englishBank = {
    'Movies': [
      EmojiGuessPuzzle(
        emojis: '🦁👑',
        answer: 'The Lion King',
        hint: 'An animated royal adventure',
      ),
      EmojiGuessPuzzle(
        emojis: '❄️👭',
        answer: 'Frozen',
        hint: 'Two sisters and an icy kingdom',
      ),
      EmojiGuessPuzzle(
        emojis: '🐼🥋',
        answer: 'Kung Fu Panda',
        hint: 'A martial arts hero',
      ),
      EmojiGuessPuzzle(
        emojis: '🐠🔍',
        answer: 'Finding Nemo',
        hint: 'An ocean search',
      ),
      EmojiGuessPuzzle(emojis: '🚗🏁', answer: 'Cars', hint: 'A racing story'),
      EmojiGuessPuzzle(
        emojis: '🤖🌱',
        answer: 'WALL-E',
        hint: 'A robot protects a plant',
      ),
    ],
    'Animals': [
      EmojiGuessPuzzle(
        emojis: '🐫🏜️',
        answer: 'Camel',
        hint: 'Lives comfortably in the desert',
      ),
      EmojiGuessPuzzle(
        emojis: '🐬🌊',
        answer: 'Dolphin',
        hint: 'A clever sea mammal',
      ),
      EmojiGuessPuzzle(
        emojis: '🦅🇦🇪',
        answer: 'Falcon',
        hint: 'A bird important to UAE heritage',
      ),
      EmojiGuessPuzzle(
        emojis: '🐧❄️',
        answer: 'Penguin',
        hint: 'A bird that loves the cold',
      ),
      EmojiGuessPuzzle(
        emojis: '🦒🌳',
        answer: 'Giraffe',
        hint: 'The tallest land animal',
      ),
      EmojiGuessPuzzle(
        emojis: '🐢🏖️',
        answer: 'Turtle',
        hint: 'Carries its home on its back',
      ),
    ],
    'Food': [
      EmojiGuessPuzzle(
        emojis: '🍕🧀',
        answer: 'Cheese Pizza',
        hint: 'A popular baked meal',
      ),
      EmojiGuessPuzzle(
        emojis: '🌴🍯',
        answer: 'Dates',
        hint: 'A sweet fruit loved in the UAE',
      ),
      EmojiGuessPuzzle(
        emojis: '🍔🍟',
        answer: 'Burger and Fries',
        hint: 'A classic fast-food pair',
      ),
      EmojiGuessPuzzle(
        emojis: '🥞🍯',
        answer: 'Pancakes',
        hint: 'A sweet breakfast stack',
      ),
      EmojiGuessPuzzle(
        emojis: '🍿🎬',
        answer: 'Popcorn',
        hint: 'A movie-night snack',
      ),
      EmojiGuessPuzzle(
        emojis: '🍦☀️',
        answer: 'Ice Cream',
        hint: 'A cold summer treat',
      ),
    ],
    'Places': [
      EmojiGuessPuzzle(
        emojis: '🏖️🌊',
        answer: 'Beach',
        hint: 'Sand beside the sea',
      ),
      EmojiGuessPuzzle(
        emojis: '📚🤫',
        answer: 'Library',
        hint: 'A quiet place full of books',
      ),
      EmojiGuessPuzzle(
        emojis: '✈️🧳',
        answer: 'Airport',
        hint: 'Where journeys take off',
      ),
      EmojiGuessPuzzle(
        emojis: '🏜️🐫',
        answer: 'Desert',
        hint: 'A wide landscape of sand',
      ),
      EmojiGuessPuzzle(
        emojis: '🦁🐘🎟️',
        answer: 'Zoo',
        hint: 'A place to visit many animals',
      ),
      EmojiGuessPuzzle(
        emojis: '🛝🌳',
        answer: 'Park',
        hint: 'An outdoor place to play',
      ),
    ],
  };

  static const Map<String, List<EmojiGuessPuzzle>> _arabicBank = {
    'Movies': [
      EmojiGuessPuzzle(
        emojis: '🦁👑',
        answer: 'الأسد الملك',
        hint: 'مغامرة كرتونية ملكية',
      ),
      EmojiGuessPuzzle(
        emojis: '❄️👭',
        answer: 'ملكة الثلج',
        hint: 'أختان ومملكة جليدية',
      ),
      EmojiGuessPuzzle(
        emojis: '🐼🥋',
        answer: 'كونغ فو باندا',
        hint: 'بطل في الفنون القتالية',
      ),
      EmojiGuessPuzzle(
        emojis: '🐠🔍',
        answer: 'البحث عن نيمو',
        hint: 'رحلة بحث في المحيط',
      ),
      EmojiGuessPuzzle(
        emojis: '🚗🏁',
        answer: 'سيارات',
        hint: 'قصة مليئة بالسباقات',
      ),
      EmojiGuessPuzzle(
        emojis: '🤖🌱',
        answer: 'وول إي',
        hint: 'روبوت يحمي نبتة صغيرة',
      ),
    ],
    'Animals': [
      EmojiGuessPuzzle(
        emojis: '🐫🏜️',
        answer: 'جمل',
        hint: 'يعيش براحة في الصحراء',
      ),
      EmojiGuessPuzzle(emojis: '🐬🌊', answer: 'دلفين', hint: 'حيوان بحري ذكي'),
      EmojiGuessPuzzle(
        emojis: '🦅🇦🇪',
        answer: 'صقر',
        hint: 'طائر مهم في تراث الإمارات',
      ),
      EmojiGuessPuzzle(
        emojis: '🐧❄️',
        answer: 'بطريق',
        hint: 'طائر يحب الأجواء الباردة',
      ),
      EmojiGuessPuzzle(emojis: '🦒🌳', answer: 'زرافة', hint: 'أطول حيوان بري'),
      EmojiGuessPuzzle(
        emojis: '🐢🏖️',
        answer: 'سلحفاة',
        hint: 'تحمل بيتها على ظهرها',
      ),
    ],
    'Food': [
      EmojiGuessPuzzle(
        emojis: '🍕🧀',
        answer: 'بيتزا بالجبن',
        hint: 'وجبة مخبوزة محبوبة',
      ),
      EmojiGuessPuzzle(
        emojis: '🌴🍯',
        answer: 'تمر',
        hint: 'فاكهة حلوة محبوبة في الإمارات',
      ),
      EmojiGuessPuzzle(
        emojis: '🍔🍟',
        answer: 'برغر وبطاطا',
        hint: 'وجبة سريعة شهيرة',
      ),
      EmojiGuessPuzzle(
        emojis: '🥞🍯',
        answer: 'فطائر',
        hint: 'طبقات حلوة للفطور',
      ),
      EmojiGuessPuzzle(
        emojis: '🍿🎬',
        answer: 'فشار',
        hint: 'وجبة خفيفة لليلة الأفلام',
      ),
      EmojiGuessPuzzle(
        emojis: '🍦☀️',
        answer: 'مثلجات',
        hint: 'حلوى باردة للصيف',
      ),
    ],
    'Places': [
      EmojiGuessPuzzle(
        emojis: '🏖️🌊',
        answer: 'شاطئ',
        hint: 'رمال بجانب البحر',
      ),
      EmojiGuessPuzzle(
        emojis: '📚🤫',
        answer: 'مكتبة',
        hint: 'مكان هادئ مليء بالكتب',
      ),
      EmojiGuessPuzzle(
        emojis: '✈️🧳',
        answer: 'مطار',
        hint: 'منه تبدأ الرحلات',
      ),
      EmojiGuessPuzzle(
        emojis: '🏜️🐫',
        answer: 'صحراء',
        hint: 'مساحة واسعة من الرمال',
      ),
      EmojiGuessPuzzle(
        emojis: '🦁🐘🎟️',
        answer: 'حديقة الحيوانات',
        hint: 'مكان لزيارة حيوانات كثيرة',
      ),
      EmojiGuessPuzzle(
        emojis: '🛝🌳',
        answer: 'حديقة',
        hint: 'مكان خارجي للعب',
      ),
    ],
  };
}
