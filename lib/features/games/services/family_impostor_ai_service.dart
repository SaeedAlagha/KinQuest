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

  Future<List<FamilyImpostorRound>> generateRounds({
    int count = 5,
    String? category,
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

    return offlineRounds(count: roundCount, category: selectedCategory);
  }

  static List<FamilyImpostorRound> offlineRounds({
    int count = 5,
    String? category,
    Random? random,
  }) {
    final roundCount = count.clamp(1, 10);
    final selectedCategory = categories.contains(category) ? category : null;
    final candidates = <FamilyImpostorRound>[];

    if (selectedCategory != null) {
      candidates.addAll(
        _offlineWords[selectedCategory]!.map(
          (word) => FamilyImpostorRound(category: selectedCategory, word: word),
        ),
      );
    } else {
      final seenWords = <String>{};
      for (final categoryEntry in _offlineWords.entries) {
        for (final word in categoryEntry.value) {
          if (seenWords.add(word.toLowerCase())) {
            candidates.add(
              FamilyImpostorRound(category: categoryEntry.key, word: word),
            );
          }
        }
      }
    }

    candidates.shuffle(random ?? Random.secure());
    return candidates.take(roundCount).toList();
  }
}
