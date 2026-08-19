import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:kinquest/core/config/api_config.dart';

class FamilyImpostorRound {
  const FamilyImpostorRound({required this.category, required this.word});

  final String category;
  final String word;

  factory FamilyImpostorRound.fromJson(Map<String, dynamic> json) {
    return FamilyImpostorRound(
      category: json['category'] as String,
      word: json['word'] as String,
    );
  }
}

class FamilyImpostorAiService {
  const FamilyImpostorAiService();

  static const List<String> categories = [
    'Food',
    'Places',
    'Animals',
    'Objects',
    'Activities',
    'Movies',
    'Sports',
    'Travel',
    'Nature',
    'School',
    'Home',
    'Music',
    'Technology',
    'UAE & Heritage',
  ];

  static const Map<String, List<String>> _offlineWords = {
    'Food': [
      'Machboos',
      'Pizza',
      'Dates',
      'Pancakes',
      'Shawarma',
      'Pasta',
      'Mango',
      'Popcorn',
      'Ice Cream',
      'Falafel',
    ],
    'Places': [
      'Beach',
      'Museum',
      'Library',
      'Park',
      'Airport',
      'Zoo',
      'School',
      'Mall',
      'Desert',
      'Farm',
    ],
    'Animals': [
      'Camel',
      'Dolphin',
      'Cat',
      'Falcon',
      'Turtle',
      'Elephant',
      'Penguin',
      'Rabbit',
      'Horse',
      'Lion',
    ],
    'Objects': [
      'Umbrella',
      'Backpack',
      'Lantern',
      'Camera',
      'Pillow',
      'Spoon',
      'Bicycle',
      'Clock',
      'Key',
      'Balloon',
    ],
    'Activities': [
      'Swimming',
      'Baking',
      'Painting',
      'Camping',
      'Gardening',
      'Dancing',
      'Reading',
      'Cycling',
      'Fishing',
      'Hiking',
    ],
    'Movies': [
      'Superhero',
      'Princess',
      'Robot',
      'Pirate',
      'Dragon',
      'Detective',
      'Astronaut',
      'Wizard',
      'Dinosaur',
      'Explorer',
    ],
    'Sports': [
      'Football',
      'Basketball',
      'Swimming',
      'Tennis',
      'Cycling',
      'Volleyball',
      'Cricket',
      'Running',
      'Archery',
      'Bowling',
    ],
    'Travel': [
      'Passport',
      'Suitcase',
      'Airplane',
      'Map',
      'Hotel',
      'Train',
      'Taxi',
      'Souvenir',
      'Ticket',
      'Adventure',
    ],
    'Nature': [
      'Rainbow',
      'Mountain',
      'Ocean',
      'Cloud',
      'Waterfall',
      'Moon',
      'Forest',
      'Flower',
      'Star',
      'River',
    ],
    'School': [
      'Pencil',
      'Teacher',
      'Homework',
      'Recess',
      'Notebook',
      'Classroom',
      'Bus',
      'Art',
      'Science',
      'Library',
    ],
    'Home': [
      'Sofa',
      'Kitchen',
      'Bedroom',
      'Garden',
      'Doorbell',
      'Fridge',
      'Balcony',
      'Table',
      'Shower',
      'Television',
    ],
    'Music': [
      'Drums',
      'Piano',
      'Guitar',
      'Microphone',
      'Singer',
      'Concert',
      'Rhythm',
      'Violin',
      'Song',
      'Headphones',
    ],
    'Technology': [
      'Robot',
      'Tablet',
      'Keyboard',
      'Drone',
      'Video Call',
      'Charger',
      'Smartwatch',
      'Camera',
      'Game Console',
      'Laptop',
    ],
    'UAE & Heritage': [
      'Falcon',
      'Dhow',
      'Majlis',
      'Dates',
      'Burj Khalifa',
      'Desert',
      'Camel',
      'Al Sadu',
      'Dallah',
      'Oasis',
    ],
  };

  static const Map<String, String> _arabicCategoryLabels = {
    'Food': 'طعام',
    'Places': 'أماكن',
    'Animals': 'حيوانات',
    'Objects': 'أشياء',
    'Activities': 'أنشطة',
    'Movies': 'أفلام',
    'Sports': 'رياضة',
    'Travel': 'سفر',
    'Nature': 'طبيعة',
    'School': 'مدرسة',
    'Home': 'المنزل',
    'Music': 'موسيقى',
    'Technology': 'تقنية',
    'UAE & Heritage': 'الإمارات والتراث',
  };

  static const Map<String, List<String>> _offlineArabicWords = {
    'Food': [
      'مجبوس',
      'بيتزا',
      'تمر',
      'فطائر',
      'شاورما',
      'معكرونة',
      'مانجو',
      'فشار',
      'مثلجات',
      'فلافل',
    ],
    'Places': [
      'شاطئ',
      'متحف',
      'مكتبة',
      'حديقة',
      'مطار',
      'حديقة حيوانات',
      'مدرسة',
      'مركز تجاري',
      'صحراء',
      'مزرعة',
    ],
    'Animals': [
      'جمل',
      'دلفين',
      'قطة',
      'صقر',
      'سلحفاة',
      'فيل',
      'بطريق',
      'أرنب',
      'حصان',
      'أسد',
    ],
    'Objects': [
      'مظلة',
      'حقيبة ظهر',
      'فانوس',
      'كاميرا',
      'وسادة',
      'ملعقة',
      'دراجة',
      'ساعة',
      'مفتاح',
      'بالون',
    ],
    'Activities': [
      'سباحة',
      'خبز',
      'رسم',
      'تخييم',
      'بستنة',
      'رقص',
      'قراءة',
      'ركوب الدراجة',
      'صيد',
      'مشي جبلي',
    ],
    'Movies': [
      'بطل خارق',
      'أميرة',
      'روبوت',
      'قرصان',
      'تنين',
      'محقق',
      'رائد فضاء',
      'ساحر',
      'ديناصور',
      'مستكشف',
    ],
    'Sports': [
      'كرة القدم',
      'كرة السلة',
      'سباحة',
      'تنس',
      'دراجات',
      'كرة الطائرة',
      'كريكيت',
      'جري',
      'رماية',
      'بولينغ',
    ],
    'Travel': [
      'جواز سفر',
      'حقيبة سفر',
      'طائرة',
      'خريطة',
      'فندق',
      'قطار',
      'سيارة أجرة',
      'تذكار',
      'تذكرة',
      'مغامرة',
    ],
    'Nature': [
      'قوس قزح',
      'جبل',
      'محيط',
      'سحابة',
      'شلال',
      'قمر',
      'غابة',
      'زهرة',
      'نجمة',
      'نهر',
    ],
    'School': [
      'قلم رصاص',
      'معلم',
      'واجب منزلي',
      'استراحة',
      'دفتر',
      'فصل دراسي',
      'حافلة',
      'فن',
      'علوم',
      'مكتبة',
    ],
    'Home': [
      'أريكة',
      'مطبخ',
      'غرفة نوم',
      'حديقة',
      'جرس الباب',
      'ثلاجة',
      'شرفة',
      'طاولة',
      'دش',
      'تلفاز',
    ],
    'Music': [
      'طبول',
      'بيانو',
      'غيتار',
      'ميكروفون',
      'مغنٍ',
      'حفل موسيقي',
      'إيقاع',
      'كمان',
      'أغنية',
      'سماعات',
    ],
    'Technology': [
      'روبوت',
      'جهاز لوحي',
      'لوحة مفاتيح',
      'طائرة مسيرة',
      'مكالمة فيديو',
      'شاحن',
      'ساعة ذكية',
      'كاميرا',
      'جهاز ألعاب',
      'حاسوب محمول',
    ],
    'UAE & Heritage': [
      'صقر',
      'محمل شراعي',
      'مجلس',
      'تمر',
      'برج خليفة',
      'صحراء',
      'جمل',
      'السدو',
      'دلة',
      'واحة',
    ],
  };

  Future<List<FamilyImpostorRound>> generateRounds({
    int count = 5,
    String? category,
    required String languageCode,
  }) async {
    final roundCount = count.clamp(1, 10);
    final selectedCategory = categories.contains(category) ? category : null;

    try {
      final response = await http
          .post(
            ApiConfig.endpoint('/api/family-impostor'),
            headers: await ApiConfig.authenticatedJsonHeaders(),
            body: jsonEncode({
              'rounds': roundCount,
              'category': ?selectedCategory,
              'language': languageCode,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to generate Family Impostor rounds');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final roundData = data['rounds'] as List<dynamic>;
      final generatedRounds = roundData
          .map(
            (item) =>
                FamilyImpostorRound.fromJson(item as Map<String, dynamic>),
          )
          .where(
            (round) =>
                round.category.trim().isNotEmpty &&
                round.word.trim().isNotEmpty,
          )
          .take(roundCount)
          .toList();

      if (generatedRounds.length == roundCount) {
        return generatedRounds;
      }
    } catch (_) {
      // A local round bank keeps family play available when the AI is offline.
    }

    return offlineRounds(
      count: roundCount,
      category: selectedCategory,
      languageCode: languageCode,
    );
  }

  static List<FamilyImpostorRound> offlineRounds({
    int count = 5,
    String? category,
    Random? random,
    String languageCode = 'en',
  }) {
    final roundCount = count.clamp(1, 10);
    final selectedCategory = categories.contains(category) ? category : null;
    final candidates = <FamilyImpostorRound>[];
    final isArabic = languageCode == 'ar';
    final wordBank = isArabic ? _offlineArabicWords : _offlineWords;

    String displayCategory(String canonicalCategory) => isArabic
        ? _arabicCategoryLabels[canonicalCategory] ?? canonicalCategory
        : canonicalCategory;

    if (selectedCategory != null) {
      candidates.addAll(
        wordBank[selectedCategory]!.map(
          (word) => FamilyImpostorRound(
            category: displayCategory(selectedCategory),
            word: word,
          ),
        ),
      );
    } else {
      final seenWords = <String>{};
      for (final categoryEntry in wordBank.entries) {
        for (final word in categoryEntry.value) {
          if (seenWords.add(word.toLowerCase())) {
            candidates.add(
              FamilyImpostorRound(
                category: displayCategory(categoryEntry.key),
                word: word,
              ),
            );
          }
        }
      }
    }

    candidates.shuffle(random ?? Random.secure());
    return candidates.take(roundCount).toList();
  }
}
